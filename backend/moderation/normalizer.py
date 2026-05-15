# backend/moderation/normalizer.py
"""Text normalisation — the first layer of the moderation cascade.

`normalize_text` reduces input to a canonical lowercase form that survives
common bypass tricks: diacritics, leet-speak (@ → a), special-char insertions
("f.u.c.k"), repeated characters ("fuuuuck"), and emojis (converted to
`:name:` tokens so downstream layers can still see them as text).

`contains_normalized_match` does substring matching with an additional
single-letter collapse so "madarchoooood" still matches "madarchod".
"""

from __future__ import annotations

import re
import unicodedata

import emoji

# Conservative leet substitutions. Only characters that are clearly
# letter-replacements (not separators, not legitimate digits).
_LEET_MAP: dict[str, str] = {
    "@": "a",
    "$": "s",
}
_LEET_RE = re.compile("|".join(re.escape(k) for k in _LEET_MAP))

# Keep letters, digits, whitespace, colons (for :emoji_name:), and
# underscores (which appear inside emoji names like :thumbs_up:).
_KEEP_RE = re.compile(r"[^a-z0-9\s:_]")

# Three-or-more identical chars collapsed to two: "fuuuuuck" -> "fuuck".
_TRIPLE_REPEAT_RE = re.compile(r"(.)\1{2,}")

# Two-or-more identical chars collapsed to one — used only for matching
# tolerance, not by normalize_text itself.
_DOUBLE_REPEAT_RE = re.compile(r"(.)\1+")

_WHITESPACE_RE = re.compile(r"\s+")


def _strip_diacritics(text: str) -> str:
    """NFKD-decompose then drop combining marks. café -> cafe."""
    decomposed = unicodedata.normalize("NFKD", text)
    return "".join(c for c in decomposed if unicodedata.category(c) != "Mn")


def _apply_leet(text: str) -> str:
    return _LEET_RE.sub(lambda m: _LEET_MAP[m.group(0)], text)


def normalize_text(text: str) -> str:
    """Return the canonical normalised form of `text`.

    Pipeline:
      1. Lowercase
      2. NFKD + strip combining marks (diacritics)
      3. Demojize (🔫 -> :gun:)
      4. Leet substitution (@ -> a, $ -> s)
      5. Remove characters outside [a-z 0-9 \\s : _]
      6. Collapse 3+ identical chars to 2
      7. Collapse whitespace, strip ends
    """
    if not text:
        return ""

    text = text.lower()
    text = _strip_diacritics(text)
    text = emoji.demojize(text)
    text = _apply_leet(text)
    text = _KEEP_RE.sub("", text)
    text = _TRIPLE_REPEAT_RE.sub(r"\1\1", text)
    text = _WHITESPACE_RE.sub(" ", text).strip()
    return text


def _collapse_repeats_for_match(text: str) -> str:
    """Collapse any run of repeated chars down to one. Used only inside
    contains_normalized_match to tolerate "madarchoooood" vs "madarchod"."""
    return _DOUBLE_REPEAT_RE.sub(r"\1", text)


def contains_normalized_match(
    text: str, words: list[str]
) -> tuple[bool, str | None]:
    """Return (True, original_word) if any word matches inside `text`.

    Both text and words are normalised via `normalize_text` plus an additional
    single-letter collapse so repeated-character bypasses still match. The
    returned word is the original (pre-normalisation) form from `words`, so
    callers can log which keyword triggered the hit.
    """
    haystack = _collapse_repeats_for_match(normalize_text(text))
    if not haystack:
        return False, None

    for original in words:
        needle = _collapse_repeats_for_match(normalize_text(original))
        if needle and needle in haystack:
            return True, original
    return False, None
