# backend/tests/test_normalizer.py
"""Tests for moderation.normalizer."""

from __future__ import annotations

import pytest

from moderation.normalizer import contains_normalized_match, normalize_text


class TestNormalizeText:
    def test_lowercase(self) -> None:
        assert normalize_text("HELLO") == "hello"

    def test_strips_diacritics(self) -> None:
        assert normalize_text("café") == "cafe"
        assert normalize_text("naïve résumé") == "naive resume"

    def test_demojizes_emoji(self) -> None:
        assert normalize_text("kill 🔫") == "kill :water_pistol:"

    def test_removes_special_chars_between_letters(self) -> None:
        assert normalize_text("f.u.c.k") == "fuck"
        assert normalize_text("h-e-l-l-o") == "hello"

    def test_collapses_repeated_chars_to_two(self) -> None:
        # 3+ identical chars collapse to 2, doubles preserved.
        assert normalize_text("fuuuuuck") == "fuuck"
        assert normalize_text("loooove") == "loove"
        assert normalize_text("ok") == "ok"
        assert normalize_text("book") == "book"  # legitimate double survives

    def test_leet_substitution(self) -> None:
        assert normalize_text("h@ck") == "hack"
        assert normalize_text("c$h") == "csh"

    def test_combined_bypass(self) -> None:
        # F@.@.@.UUUUCK 🔫 ->
        #   lowercase     -> f@.@.@.uuuuck 🔫
        #   demojize      -> f@.@.@.uuuuck :water_pistol:
        #   leet (@->a)   -> fa.a.a.uuuuck :water_pistol:
        #   strip special -> faaauuuuck :water_pistol:
        #   collapse 3+   -> faauuck :water_pistol:
        assert normalize_text("F@.@.@.UUUUCK 🔫") == "faauuck :water_pistol:"

    def test_empty_string(self) -> None:
        assert normalize_text("") == ""

    def test_whitespace_only(self) -> None:
        assert normalize_text("     ") == ""

    def test_collapses_internal_whitespace(self) -> None:
        assert normalize_text("hello   world") == "hello world"
        assert normalize_text("  hello   world  ") == "hello world"

    def test_emoji_with_text(self) -> None:
        assert normalize_text("happy 😀 day") == "happy :grinning_face: day"


class TestContainsNormalizedMatch:
    def test_leet_bypass_matches(self) -> None:
        matched, word = contains_normalized_match("m@darchod", ["madarchod"])
        assert matched is True
        assert word == "madarchod"

    def test_repeated_char_bypass_matches(self) -> None:
        matched, word = contains_normalized_match("MADARCHOOOOD", ["madarchod"])
        assert matched is True
        assert word == "madarchod"

    def test_clean_text_does_not_match(self) -> None:
        matched, word = contains_normalized_match("clean message", ["madarchod"])
        assert matched is False
        assert word is None

    def test_returns_first_matching_word(self) -> None:
        matched, word = contains_normalized_match(
            "you are an idiot", ["fool", "idiot", "moron"]
        )
        assert matched is True
        assert word == "idiot"

    def test_empty_text_no_match(self) -> None:
        matched, word = contains_normalized_match("", ["madarchod"])
        assert matched is False
        assert word is None

    def test_empty_word_list_no_match(self) -> None:
        matched, word = contains_normalized_match("anything goes here", [])
        assert matched is False
        assert word is None

    @pytest.mark.parametrize(
        "text",
        [
            "M.A.D.A.R.C.H.O.D",
            "Madarchod",
            "madarchoooood",
            "m@darch0d",  # 0 isn't substituted — should still fail to match
        ],
    )
    def test_various_bypass_attempts(self, text: str) -> None:
        matched, word = contains_normalized_match(text, ["madarchod"])
        # Note the 0->o NOT being substituted: m@darch0d should NOT match.
        # If you want digit substitution, expand _LEET_MAP.
        if "0" in text:
            assert matched is False
        else:
            assert matched is True
            assert word == "madarchod"
