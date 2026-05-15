# backend/tests/test_keyword_filter.py
"""Tests for moderation.keyword_filter."""

from __future__ import annotations

from typing import Any

import pytest

from moderation.keyword_filter import KeywordFilter


def _seed_cache(kf: KeywordFilter, cache: dict[str, list[str]]) -> None:
    """Directly populate the in-memory cache for tests (no Firestore round-trip)."""
    kf._cache = cache  # noqa: SLF001 — test-only access to private state


class TestCheck:
    def test_blocks_when_keyword_present(self) -> None:
        kf = KeywordFilter()
        _seed_cache(kf, {"english_slurs": ["idiot"]})

        verdict = kf.check("you are an idiot")

        assert verdict.blocked is True
        assert verdict.category == "english_slurs"
        assert verdict.matched_word == "idiot"

    def test_allows_clean_text(self) -> None:
        kf = KeywordFilter()
        _seed_cache(kf, {"english_slurs": ["idiot"]})

        verdict = kf.check("have a great day")

        assert verdict.blocked is False
        assert verdict.category is None
        assert verdict.matched_word is None

    def test_empty_cache_allows_everything(self) -> None:
        kf = KeywordFilter()
        verdict = kf.check("anything goes here even idiot")
        assert verdict.blocked is False

    def test_empty_text_is_allowed(self) -> None:
        kf = KeywordFilter()
        _seed_cache(kf, {"english_slurs": ["idiot"]})
        assert kf.check("").blocked is False

    def test_higher_severity_category_wins(self) -> None:
        # "threats" is checked before "english_slurs"; a text matching both
        # should report the threat category.
        kf = KeywordFilter()
        _seed_cache(
            kf,
            {
                "english_slurs": ["idiot"],
                "threats": ["kill you"],
            },
        )

        verdict = kf.check("i will kill you, idiot")

        assert verdict.blocked is True
        assert verdict.category == "threats"
        assert verdict.matched_word == "kill you"

    def test_bypass_attempt_caught_via_normalizer(self) -> None:
        kf = KeywordFilter()
        _seed_cache(kf, {"hindi_slurs": ["madarchod"]})

        # @ -> a via normalizer; repeated chars collapsed for matching.
        verdict_at = kf.check("you m@darchod")
        verdict_repeats = kf.check("MADARCHOOOOD")

        assert verdict_at.blocked is True
        assert verdict_at.matched_word == "madarchod"
        assert verdict_repeats.blocked is True
        assert verdict_repeats.matched_word == "madarchod"

    def test_unknown_category_still_checked(self) -> None:
        # A category not in the ordered list should still be matched (forward compat).
        kf = KeywordFilter()
        _seed_cache(kf, {"future_category": ["forbidden"]})

        verdict = kf.check("this is forbidden")

        assert verdict.blocked is True
        assert verdict.category == "future_category"


class TestRefresh:
    @pytest.mark.asyncio
    async def test_refresh_populates_cache(self, monkeypatch: pytest.MonkeyPatch) -> None:
        kf = KeywordFilter()
        fake_docs: list[dict[str, Any]] = [
            {"category": "english_slurs", "value": "idiot", "is_regex": False},
            {"category": "english_slurs", "value": "moron", "is_regex": False},
            {"category": "threats", "value": "kill you", "is_regex": False},
        ]
        monkeypatch.setattr(kf, "_fetch_all", lambda: fake_docs)

        await kf.refresh()

        assert sorted(kf.cache["english_slurs"]) == ["idiot", "moron"]
        assert kf.cache["threats"] == ["kill you"]

    @pytest.mark.asyncio
    async def test_refresh_skips_docs_missing_required_fields(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        kf = KeywordFilter()
        fake_docs: list[dict[str, Any]] = [
            {"category": "english_slurs", "value": "idiot"},
            {"category": "english_slurs"},          # missing value
            {"value": "orphan"},                    # missing category
            {},
        ]
        monkeypatch.setattr(kf, "_fetch_all", lambda: fake_docs)

        await kf.refresh()

        assert kf.cache == {"english_slurs": ["idiot"]}

    @pytest.mark.asyncio
    async def test_refresh_swallows_firestore_failure(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        kf = KeywordFilter()

        def boom() -> Any:
            raise RuntimeError("firestore down")

        monkeypatch.setattr(kf, "_fetch_all", boom)

        # Should not raise; cache should remain whatever it was.
        await kf.refresh()
        assert kf.cache == {}
