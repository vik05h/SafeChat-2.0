# backend/moderation/lexicon.py
"""Layer 1 of the moderation cascade — the weighted keyword lexicon.

This is the deterministic, dependency-free first line of defence. It implements
TF-IDF *weighting* over a curated lexicon: every term carries a severity weight
(its "inverse-document-frequency"-style rarity/harm score), and the verdict
score is the sum over matched terms of ``term_frequency x weight``.

Crucially, matching runs against the **original** text with an
obfuscation-tolerant regex per term, so we recover the exact character span of
each hit. Those spans are handed to the client to highlight the offending words
in the compose box / flagged-content popup.

The matcher tolerates the common bypass tricks:
  * case            ("IDIOT")            via re.IGNORECASE
  * leet-speak      ("1d10t", "b@d")     via per-letter character classes
  * repeated chars  ("idioooot")         via possessive ``++`` quantifiers
  * separators      ("i.d.i.o.t")        via optional separators between letters
  * spacing         ("kill   you")       via mandatory separators between words

Possessive quantifiers (Python 3.11+) keep the regex linear — no ReDoS.

To add or retune a term: edit ``_LEXICON`` below and redeploy. No I/O, no
Firestore round-trip; the patterns compile once at import (~0 ms per check).
"""

from __future__ import annotations

import logging
import re

from models.moderation import LexiconVerdict, Match

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Lexicon: (category, term, weight). Weight ~ severity (0..1). Every listed
# term is itself abusive, so ANY match flags the content for human
# verification — the weight only drives severity ranking + the Layer-2 blend.
# Categories: threats | english_slurs | hindi_slurs | hinglish_slurs
# ---------------------------------------------------------------------------
_LEXICON: list[tuple[str, str, float]] = [
    # Threats — always high severity.
    ("threats", "kill you", 1.0),
    ("threats", "i will kill", 1.0),
    ("threats", "gonna kill", 1.0),
    ("threats", "kill yourself", 1.0),
    ("threats", "kys", 1.0),
    ("threats", "end your life", 1.0),
    ("threats", "hurt you", 0.9),
    ("threats", "i will hurt", 0.9),
    ("threats", "beat you up", 0.9),
    # English slurs / insults.
    ("english_slurs", "retard", 0.9),
    ("english_slurs", "worthless", 0.7),
    ("english_slurs", "nobody likes you", 0.8),
    ("english_slurs", "freak", 0.5),
    ("english_slurs", "loser", 0.5),
    ("english_slurs", "idiot", 0.5),
    ("english_slurs", "moron", 0.5),
    ("english_slurs", "stupid", 0.4),
    ("english_slurs", "dumb", 0.4),
    ("english_slurs", "ugly", 0.4),
    # Hindi slurs.
    ("hindi_slurs", "harami", 0.7),
    ("hindi_slurs", "kamina", 0.6),
    ("hindi_slurs", "kutta", 0.5),
    ("hindi_slurs", "kutte", 0.5),
    ("hindi_slurs", "gadha", 0.4),
    ("hindi_slurs", "bewakoof", 0.4),
    # Hinglish slurs (strong profanity).
    ("hinglish_slurs", "madarchod", 1.0),
    ("hinglish_slurs", "behenchod", 1.0),
    ("hinglish_slurs", "bhosdike", 1.0),
    ("hinglish_slurs", "chutiya", 0.9),
    ("hinglish_slurs", "chutiye", 0.9),
    ("hinglish_slurs", "gandu", 0.9),
    ("hinglish_slurs", "pagal", 0.4),
]

# Per-letter character classes capturing common leet substitutions. Inside a
# [...] class every char below is literal, so no escaping is required.
_LEET: dict[str, str] = {
    "a": "a@4",
    "b": "b8",
    "e": "e3",
    "g": "g9",
    "i": "i1!|",
    "l": "l1|",
    "o": "o0",
    "s": "s$5",
    "t": "t7",
}

# Separator set used both between letters (optional) and between words
# (mandatory). Disjoint from every letter class, so possessive quantifiers
# below never need to backtrack.
_SEP_CHARS = r"\s._*\-"
_SEP_OPT = rf"[{_SEP_CHARS}]*+"  # between letters within a word (possessive)
_SEP_REQ = rf"[{_SEP_CHARS}]++"  # between words (>= 1, possessive)


def _char_atom(char: str) -> str:
    """Regex atom for one term letter: tolerant of leet + repeated chars."""
    cls = _LEET.get(char)
    if cls is not None:
        return f"[{cls}]++"
    return re.escape(char) + "++"


def _dedupe(word: str) -> str:
    """Collapse runs of the same char: "kill" -> "kil".

    The per-letter atoms are ``+`` quantified, so a single ``l`` atom already
    matches "ll"/"llll" in the input. Collapsing first means adjacent identical
    atoms can never starve each other under possessive quantifiers (which is
    what silently dropped "kill you").
    """
    out: list[str] = []
    for char in word:
        if not out or out[-1] != char:
            out.append(char)
    return "".join(out)


def _compile(term: str) -> re.Pattern[str]:
    """Compile an obfuscation-tolerant, span-capturing pattern for ``term``."""
    words = [_dedupe(word) for word in term.lower().split()]
    word_patterns = [_SEP_OPT.join(_char_atom(c) for c in word) for word in words]
    body = _SEP_REQ.join(word_patterns)
    # Leading guard only: reject matches that start mid-word (so "loser" does
    # not fire inside "closer"), but allow trailing letters so plurals/suffixes
    # ("idiots", "losers") still match.
    return re.compile(rf"(?<![A-Za-z0-9]){body}", re.IGNORECASE)


# (category, term, weight, compiled_pattern) — compiled once at import.
_COMPILED: list[tuple[str, str, float, re.Pattern[str]]] = [
    (category, term, weight, _compile(term)) for category, term, weight in _LEXICON
]
logger.info("Lexicon loaded: %d terms (in-process, no I/O)", len(_COMPILED))


def evaluate(text: str) -> LexiconVerdict:
    """Score ``text`` against the lexicon. Pure, synchronous, no I/O.

    Returns a :class:`LexiconVerdict` whose ``matches`` carry exact character
    spans into the *original* ``text`` for client-side highlighting. ``blocked``
    is True whenever any lexicon term is present.
    """
    if not text:
        return LexiconVerdict(blocked=False)

    matches: list[Match] = []
    for category, term, weight, pattern in _COMPILED:
        for hit in pattern.finditer(text):
            matches.append(
                Match(
                    term=term,
                    category=category,
                    weight=weight,
                    start=hit.start(),
                    end=hit.end(),
                )
            )

    if not matches:
        return LexiconVerdict(blocked=False)

    # TF-IDF-style aggregate: each occurrence contributes its severity weight.
    score = round(sum(m.weight for m in matches), 3)
    ordered = sorted(matches, key=lambda m: m.weight, reverse=True)
    categories: list[str] = []
    for m in ordered:
        if m.category not in categories:
            categories.append(m.category)

    top = ordered[0]
    return LexiconVerdict(
        blocked=True,
        score=score,
        matches=matches,
        categories=categories,
        category=top.category,
        matched_word=top.term,
    )
