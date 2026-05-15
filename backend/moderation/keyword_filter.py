# backend/moderation/keyword_filter.py
"""Dynamic keyword filter — the second layer of the moderation cascade.

Loads keyword entries from Firestore (collection `moderation_keywords`) into
an in-memory cache, refreshed periodically in the background. `check(text)`
returns a verdict using the normalizer's fuzzy substring match.

If Firestore is unreachable at startup, the cache stays empty and `check()`
will report blocked=False — moderation cascades to subsequent layers
(OpenAI / Gemini / Vision) which provide defense in depth.
"""

from __future__ import annotations

import asyncio
import logging
from collections import defaultdict
from collections.abc import Iterable
from typing import Any

from core.firebase import db
from models.moderation import KeywordVerdict
from moderation.normalizer import contains_normalized_match

logger = logging.getLogger(__name__)

KEYWORDS_COLLECTION = "moderation_keywords"
DEFAULT_REFRESH_INTERVAL_SECONDS = 5 * 60

# Order matters: first match wins, so put highest-severity categories first.
_CATEGORY_CHECK_ORDER: tuple[str, ...] = (
    "threats",
    "english_slurs",
    "hindi_slurs",
    "hinglish_slurs",
    "bypass_patterns",
)


class KeywordFilter:
    """In-memory dynamic keyword filter, periodically refreshed from Firestore."""

    def __init__(
        self,
        refresh_interval_seconds: int = DEFAULT_REFRESH_INTERVAL_SECONDS,
    ) -> None:
        self._cache: dict[str, list[str]] = {}
        self._lock = asyncio.Lock()
        self._refresh_interval = refresh_interval_seconds
        self._refresh_task: asyncio.Task[None] | None = None

    @property
    def cache(self) -> dict[str, list[str]]:
        """Snapshot of the current cache. Useful for tests/diagnostics."""
        return self._cache

    async def refresh(self) -> None:
        """Reload the keyword cache from Firestore.

        Failures are logged at CRITICAL but don't raise — keep serving with
        whatever cache we already have (or empty cache on first failure).
        """
        try:
            docs = await asyncio.to_thread(self._fetch_all)
        except Exception:
            logger.critical(
                "Failed to refresh keyword filter from Firestore; "
                "keyword layer is degraded.",
                exc_info=True,
            )
            return

        new_cache: dict[str, list[str]] = defaultdict(list)
        for doc in docs:
            category = doc.get("category")
            value = doc.get("value")
            if not category or not value:
                continue
            # TODO(phase 2.x): handle is_regex=true entries via a regex layer.
            new_cache[str(category)].append(str(value))

        async with self._lock:
            self._cache = dict(new_cache)

        total = sum(len(v) for v in self._cache.values())
        logger.info(
            "Keyword filter refreshed: %d entries across %d categories",
            total,
            len(self._cache),
        )

    def _fetch_all(self) -> Iterable[dict[str, Any]]:
        stream = db.collection(KEYWORDS_COLLECTION).stream()
        return [snap.to_dict() or {} for snap in stream]

    def check(self, text: str) -> KeywordVerdict:
        """Check text against the cached keyword list. Sync; no I/O."""
        if not text or not self._cache:
            return KeywordVerdict(blocked=False)

        # Ordered categories first (highest severity wins).
        for category in _CATEGORY_CHECK_ORDER:
            words = self._cache.get(category)
            if not words:
                continue
            matched, word = contains_normalized_match(text, words)
            if matched:
                return KeywordVerdict(
                    blocked=True, category=category, matched_word=word
                )

        # Any future category that isn't in the ordered list yet.
        for category, words in self._cache.items():
            if category in _CATEGORY_CHECK_ORDER or not words:
                continue
            matched, word = contains_normalized_match(text, words)
            if matched:
                return KeywordVerdict(
                    blocked=True, category=category, matched_word=word
                )

        return KeywordVerdict(blocked=False)

    async def start_background_refresh(self) -> None:
        """Schedule periodic refresh. No-op if already running."""
        if self._refresh_task and not self._refresh_task.done():
            return
        self._refresh_task = asyncio.create_task(self._refresh_loop())

    async def stop_background_refresh(self) -> None:
        if self._refresh_task and not self._refresh_task.done():
            self._refresh_task.cancel()
            try:
                await self._refresh_task
            except asyncio.CancelledError:
                pass
        self._refresh_task = None

    async def _refresh_loop(self) -> None:
        while True:
            try:
                await asyncio.sleep(self._refresh_interval)
                await self.refresh()
            except asyncio.CancelledError:
                raise
            except Exception:
                logger.exception("Unexpected error in keyword refresh loop")


# Module-level singleton.
keyword_filter = KeywordFilter()
