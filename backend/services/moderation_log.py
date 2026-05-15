# backend/services/moderation_log.py
"""Privacy-preserving moderation decision logging.

Writes one record per decision to the `moderation_logs` collection. The raw
content is NEVER stored — only `content_hash` (SHA-256 of the original text,
computed by the engine). Failures don't raise: logging is best-effort and
must never break a user response.
"""

from __future__ import annotations

import asyncio
import logging
from typing import Any

from google.cloud import firestore

from core.firebase import db
from models.moderation import ModerationResult

logger = logging.getLogger(__name__)

LOGS_COLLECTION = "moderation_logs"

# Map per-layer latency keys (from ModerationResult.layer_latencies) to the
# *_ms keys used in the moderation_logs document. `keyword` is in-process,
# not an API call, but we track it alongside the others for completeness.
_LATENCY_KEYS: dict[str, str] = {
    "keyword": "keyword_ms",
    "openai": "openai_ms",
    "gemini": "gemini_ms",
    "vision": "vision_ms",
}


def _build_payload(
    *,
    result: ModerationResult,
    content_type: str,
    content_id: str | None,
    author_uid: str,
) -> dict[str, Any]:
    api_latencies: dict[str, float | None] = {
        key: None for key in _LATENCY_KEYS.values()
    }
    for layer, latency in (result.layer_latencies or {}).items():
        mapped = _LATENCY_KEYS.get(layer)
        if mapped is not None:
            api_latencies[mapped] = latency

    return {
        "content_hash": result.content_hash,
        "content_type": content_type,
        "content_id": content_id,
        "author_uid": author_uid,
        "verdict": "blocked" if result.blocked else "approved",
        "layer_triggered": result.layer,
        "category": result.category,
        "confidence": None,  # Reserved — set when layers expose this uniformly.
        "api_latencies": api_latencies,
        "total_latency_ms": result.latency_ms,
        "created_at": firestore.SERVER_TIMESTAMP,
    }


def _write_log(payload: dict[str, Any]) -> None:
    """Sync write into Firestore. Isolated so tests can patch a single seam."""
    db.collection(LOGS_COLLECTION).add(payload)


async def log_moderation_decision(
    result: ModerationResult,
    content_type: str,
    content_id: str | None,
    author_uid: str,
) -> None:
    """Persist a moderation decision. Fail-open."""
    payload = _build_payload(
        result=result,
        content_type=content_type,
        content_id=content_id,
        author_uid=author_uid,
    )
    try:
        await asyncio.to_thread(_write_log, payload)
    except Exception:
        logger.warning(
            "Failed to write moderation log (content_type=%s, content_id=%s)",
            content_type,
            content_id,
            exc_info=True,
        )
