# backend/moderation/keyword_filter.py
"""Static keyword filter — the first layer of the moderation cascade.

Keywords are loaded from _KEYWORD_LIST at module import time into an
in-memory dict keyed by category. There is NO background polling, no
Firestore round-trip, and no I/O of any kind — `check()` is a pure
synchronous RAM lookup that costs ~0.1 ms.

To add new keywords: edit _KEYWORD_LIST below and redeploy the backend.

For content that trips the filter but isn't clearly cut-and-dry, the
post/message is saved with status="pending_review" and shown only to the
author until a human moderator approves or rejects it.
"""

from __future__ import annotations

import logging
from collections import defaultdict

from moderation.normalizer import contains_normalized_match
from models.moderation import KeywordVerdict

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Hardcoded keyword list. Add/remove entries here and redeploy.
# Categories: threats | english_slurs | hindi_slurs | hinglish_slurs | bypass_patterns
# ---------------------------------------------------------------------------
_KEYWORD_LIST: list[dict[str, str]] = [
    # Threats
    {"category": "threats", "value": "kill you"},
    {"category": "threats", "value": "hurt you"},
    {"category": "threats", "value": "beat you up"},
    {"category": "threats", "value": "gonna kill"},
    {"category": "threats", "value": "i will hurt"},

    # English slurs (placeholder — expand with real list)
    {"category": "english_slurs", "value": "idiot"},
    {"category": "english_slurs", "value": "moron"},
    {"category": "english_slurs", "value": "loser"},
    {"category": "english_slurs", "value": "retard"},

    # Hindi slurs (placeholder)
    {"category": "hindi_slurs", "value": "bewakoof"},
    {"category": "hindi_slurs", "value": "gadha"},
    {"category": "hindi_slurs", "value": "kamina"},
    {"category": "hindi_slurs", "value": "kutte"},

    # Hinglish slurs (placeholder)
    {"category": "hinglish_slurs", "value": "pagal"},
    {"category": "hinglish_slurs", "value": "chutiya"},

    # Bypass patterns (leet-speak equivalents — normalizer handles @ → a, $ → s)
    {"category": "bypass_patterns", "value": "b@dword"},
]

# Order matters: first match wins. Higher-severity categories first.
_CATEGORY_CHECK_ORDER: tuple[str, ...] = (
    "threats",
    "english_slurs",
    "hindi_slurs",
    "hinglish_slurs",
    "bypass_patterns",
)


def _build_cache() -> dict[str, list[str]]:
    cache: dict[str, list[str]] = defaultdict(list)
    for entry in _KEYWORD_LIST:
        category = entry.get("category", "").strip()
        value = entry.get("value", "").strip()
        if category and value:
            cache[category].append(value)
    loaded = dict(cache)
    total = sum(len(v) for v in loaded.values())
    logger.info(
        "Keyword filter loaded: %d entries across %d categories (in-process, no I/O)",
        total,
        len(loaded),
    )
    return loaded


# Load once at import time — pure RAM, ~0 ms.
_cache: dict[str, list[str]] = _build_cache()


def check(text: str) -> KeywordVerdict:
    """Check text against the in-memory keyword list. Pure sync, no I/O."""
    if not text or not _cache:
        return KeywordVerdict(blocked=False)

    # Ordered categories first (highest severity wins).
    for category in _CATEGORY_CHECK_ORDER:
        words = _cache.get(category)
        if not words:
            continue
        matched, word = contains_normalized_match(text, words)
        if matched:
            return KeywordVerdict(blocked=True, category=category, matched_word=word)

    # Any future category not in the ordered list.
    for category, words in _cache.items():
        if category in _CATEGORY_CHECK_ORDER or not words:
            continue
        matched, word = contains_normalized_match(text, words)
        if matched:
            return KeywordVerdict(blocked=True, category=category, matched_word=word)

    return KeywordVerdict(blocked=False)
