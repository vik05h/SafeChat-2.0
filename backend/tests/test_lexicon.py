# backend/tests/test_lexicon.py
"""Tests for moderation.lexicon — the weighted keyword scorer (Layer 1)."""

from __future__ import annotations

from moderation import lexicon


class TestEvaluate:
    def test_blocks_when_term_present_with_exact_span(self) -> None:
        text = "you are an idiot"
        verdict = lexicon.evaluate(text)

        assert verdict.blocked is True
        assert verdict.category == "english_slurs"
        assert verdict.matched_word == "idiot"
        assert len(verdict.matches) == 1
        match = verdict.matches[0]
        assert text[match.start : match.end] == "idiot"

    def test_allows_clean_text(self) -> None:
        verdict = lexicon.evaluate("have a great day")
        assert verdict.blocked is False
        assert verdict.matches == []
        assert verdict.category is None
        assert verdict.matched_word is None

    def test_empty_text_allowed(self) -> None:
        assert lexicon.evaluate("").blocked is False

    def test_highest_weight_term_wins_summary(self) -> None:
        # A threat (weight 1.0) outranks a slur (0.5) in the summary fields,
        # but both are captured in matches/categories.
        verdict = lexicon.evaluate("i will kill you idiot")

        assert verdict.blocked is True
        assert verdict.category == "threats"
        assert verdict.matched_word in {"kill you", "i will kill"}
        cats = {m.category for m in verdict.matches}
        assert "threats" in cats
        assert "english_slurs" in cats

    def test_leet_bypass_caught_with_original_span(self) -> None:
        text = "you m@darchod"
        verdict = lexicon.evaluate(text)

        assert verdict.blocked is True
        match = next(m for m in verdict.matches if m.term == "madarchod")
        assert text[match.start : match.end] == "m@darchod"

    def test_separator_bypass(self) -> None:
        verdict = lexicon.evaluate("such an i.d.i.o.t")
        assert verdict.blocked is True
        assert any(m.term == "idiot" for m in verdict.matches)

    def test_repeated_chars_span_covers_full_run(self) -> None:
        text = "what a loooser"
        verdict = lexicon.evaluate(text)
        assert verdict.blocked is True
        match = verdict.matches[0]
        assert text[match.start : match.end] == "loooser"

    def test_case_insensitive_and_plural(self) -> None:
        verdict = lexicon.evaluate("you are IDIOTS")
        assert verdict.blocked is True
        assert verdict.matches[0].term == "idiot"

    def test_doubled_letter_multiword_term(self) -> None:
        # Regression: possessive quantifiers used to starve on the "ll" in
        # "kill", silently dropping the whole "kill you" match.
        verdict = lexicon.evaluate("i will kill you")
        assert verdict.blocked is True
        assert verdict.category == "threats"

    def test_no_inword_false_positive(self) -> None:
        # Leading word-guard: "loser" must not fire inside "closer", and the
        # multi-word "kill you" must not fire inside "killing time".
        assert lexicon.evaluate("closer to home").blocked is False
        assert lexicon.evaluate("killing time at the mall").blocked is False

    def test_score_aggregates_term_frequency(self) -> None:
        verdict = lexicon.evaluate("idiot idiot")
        assert verdict.blocked is True
        assert len(verdict.matches) == 2
        assert verdict.score > 0
