# backend/services/moderation_seed.py
"""Seed the moderation_keywords collection with a small starter set.

Run manually from the backend directory:

    python -m services.moderation_seed

Idempotent: uses deterministic doc IDs so re-running updates existing entries
rather than duplicating them. Replace these placeholder entries with real
lists via the admin panel once Phase 7 lands.
"""

from __future__ import annotations

import logging
import re
from typing import TypedDict

from google.cloud import firestore

from core.firebase import db
from moderation.keyword_filter import KEYWORDS_COLLECTION

logger = logging.getLogger(__name__)

SEED_ADMIN_UID = "system"


class _Entry(TypedDict):
    category: str
    value: str
    is_regex: bool
    severity: str
    notes: str


# Intentionally mild / placeholder entries. The admin panel will manage the
# real lists; these exist only so the cascade has something to match against
# in local dev and tests.
_DEFAULT_ENTRIES: list[_Entry] = [
    {"category": "english_slurs", "value": "idiot", "is_regex": False,
     "severity": "low", "notes": "Placeholder."},
    {"category": "english_slurs", "value": "moron", "is_regex": False,
     "severity": "low", "notes": "Placeholder."},

    {"category": "hindi_slurs", "value": "bewakoof", "is_regex": False,
     "severity": "low", "notes": "Placeholder."},

    {"category": "hinglish_slurs", "value": "pagal", "is_regex": False,
     "severity": "low", "notes": "Placeholder."},

    {"category": "threats", "value": "kill you", "is_regex": False,
     "severity": "high", "notes": "Direct threat."},
    {"category": "threats", "value": "hurt you", "is_regex": False,
     "severity": "high", "notes": "Direct threat."},

    {"category": "bypass_patterns", "value": "b@dword", "is_regex": False,
     "severity": "low", "notes": "Example leet-bypass pattern."},
]


def _doc_id(entry: _Entry) -> str:
    """Deterministic doc ID from category + value, so reseeding is idempotent."""
    sanitised = re.sub(r"[^a-z0-9]+", "_", entry["value"].lower()).strip("_")
    return f"{entry['category']}__{sanitised}"


def seed_default_keywords() -> None:
    """Upsert all default keyword entries into moderation_keywords."""
    now = firestore.SERVER_TIMESTAMP
    collection = db.collection(KEYWORDS_COLLECTION)

    for entry in _DEFAULT_ENTRIES:
        doc_ref = collection.document(_doc_id(entry))
        snapshot = doc_ref.get()

        payload: dict[str, object] = {
            "category": entry["category"],
            "value": entry["value"],
            "is_regex": entry["is_regex"],
            "severity": entry["severity"],
            "notes": entry["notes"],
            "added_by": SEED_ADMIN_UID,
            "updated_at": now,
        }
        if not snapshot.exists:
            payload["created_at"] = now

        doc_ref.set(payload, merge=True)
        logger.info("Seeded %s", doc_ref.id)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    seed_default_keywords()
    print(f"Seeded {len(_DEFAULT_ENTRIES)} entries into {KEYWORDS_COLLECTION}.")
