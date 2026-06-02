# backend/models/safety.py
"""Safety-related Pydantic models."""

from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

AppealStatus = Literal["submitted", "under_review", "approved", "rejected"]


class SafetyTrendPoint(BaseModel):
    date: str
    score: int


class SafetyStatsResponse(BaseModel):
    """Output for GET /safety/stats."""
    safety_score: int
    reputation_score: int
    trust_level: str
    reports_submitted: int
    reports_resolved: int
    warnings_received: int
    appeals_won: int
    appeals_lost: int
    safety_trend: list[SafetyTrendPoint]


class AppealCreateRequest(BaseModel):
    """Input for POST /safety/appeals."""
    content_id: str = Field(min_length=1)
    reason: str = Field(min_length=1)


class AppealResponse(BaseModel):
    """Output for GET /safety/appeals."""
    id: str
    content_id: str
    content_preview: str
    reason_provided: str
    admin_notes: str | None = None
    appeal_status: AppealStatus
    created_at: datetime
