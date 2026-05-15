# backend/models/moderation.py
"""Moderation-related Pydantic models."""

from __future__ import annotations

from pydantic import BaseModel


class KeywordVerdict(BaseModel):
    """Result of running text through the keyword filter."""

    blocked: bool
    category: str | None = None
    matched_word: str | None = None


class OpenAIVerdict(BaseModel):
    """Result of running text through the OpenAI Moderation API."""

    blocked: bool
    category: str | None = None
    score: float | None = None
    skipped: bool = False              # API key not configured
    error: bool = False                # HTTP/timeout/parse failure
    all_scores: dict[str, float] | None = None


class ModerationResult(BaseModel):
    """Unified moderation result across all cascade layers."""

    blocked: bool
    layer: str | None = None      # "keyword" | "openai" | "gemini" | "vision"
    category: str | None = None   # e.g. "english_slurs", "harassment"
    reason: str | None = None     # human-readable description for logs
