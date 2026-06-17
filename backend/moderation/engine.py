# backend/moderation/engine.py
"""Unified moderation engine — orchestrates all cascade layers.

Cascade order (text-only; image moderation joins in a later step):
  1. Empty / whitespace short-circuit — no work, no API calls
  2. Keyword filter (in-process, fast)
  3. OpenAI Moderation API

First block wins; downstream layers are skipped to save latency and API spend.
Latency is recorded per-layer and overall.
"""

from __future__ import annotations

import hashlib
import logging
import time

from models.moderation import ModerationResult
from moderation.keyword_filter import check as keyword_check
from moderation.openai_moderation import check_with_openai
from moderation.vision import check_image_with_vision

logger = logging.getLogger(__name__)


def hash_content(text: str) -> str:
    """SHA-256 hex digest of the original text — used in moderation logs."""
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def _now_ms() -> float:
    return time.perf_counter() * 1000.0


async def moderate_text(text: str) -> ModerationResult:
    """Run text through the moderation cascade.

    Returns a `ModerationResult` with `blocked`, the triggering `layer`, and
    timing metadata. Empty / whitespace-only text passes without invoking any
    cascade layer.
    """
    start = _now_ms()
    content_hash = hash_content(text)
    layer_latencies: dict[str, float] = {}

    if not text or not text.strip():
        return ModerationResult(
            blocked=False,
            latency_ms=_now_ms() - start,
            layer_latencies=layer_latencies,
            content_hash=content_hash,
        )

    # ---- Layer 1: keyword filter (in-process, no I/O) ---------------------
    layer_start = _now_ms()
    keyword_verdict = keyword_check(text)
    layer_latencies["keyword"] = _now_ms() - layer_start

    if keyword_verdict.blocked:
        return ModerationResult(
            blocked=True,
            layer="keyword",
            category=keyword_verdict.category,
            reason=f"keyword match: {keyword_verdict.matched_word}",
            latency_ms=_now_ms() - start,
            layer_latencies=layer_latencies,
            content_hash=content_hash,
        )

    # ---- Layer 2: OpenAI Moderation API -----------------------------------
    layer_start = _now_ms()
    openai_verdict = await check_with_openai(text)
    layer_latencies["openai"] = _now_ms() - layer_start

    if openai_verdict.blocked:
        score = openai_verdict.score if openai_verdict.score is not None else 0.0
        return ModerationResult(
            blocked=True,
            layer="openai",
            category=openai_verdict.category,
            reason=f"openai score {score:.2f}",
            latency_ms=_now_ms() - start,
            layer_latencies=layer_latencies,
            content_hash=content_hash,
        )

    return ModerationResult(
        blocked=False,
        latency_ms=_now_ms() - start,
        layer_latencies=layer_latencies,
        content_hash=content_hash,
    )


async def moderate_image(image_url: str) -> ModerationResult:
    """Run an image URL through the Vision SafeSearch layer.

    Returns a ``ModerationResult`` with ``layer="vision"`` when blocked.
    Errors from the Vision API are fail-open: ``blocked=False`` is returned so
    a transient failure never prevents content from being stored.

    Args:
        image_url: Publicly reachable URL of the image to screen.
    """
    start = _now_ms()
    content_hash = hash_content(image_url)
    layer_latencies: dict[str, float] = {}

    layer_start = _now_ms()
    vision_verdict = await check_image_with_vision(image_url)
    layer_latencies["vision"] = _now_ms() - layer_start

    if vision_verdict.blocked:
        return ModerationResult(
            blocked=True,
            layer="vision",
            category=vision_verdict.category,
            reason=f"vision safeSearch: {vision_verdict.category}",
            latency_ms=_now_ms() - start,
            layer_latencies=layer_latencies,
            content_hash=content_hash,
        )

    return ModerationResult(
        blocked=False,
        latency_ms=_now_ms() - start,
        layer_latencies=layer_latencies,
        content_hash=content_hash,
    )
