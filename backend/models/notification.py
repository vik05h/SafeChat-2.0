# backend/models/notification.py
"""Notification-related Pydantic models."""

from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

NotificationType = Literal[
    "like",
    "comment",
    "follow",
    "mention",
    "message",
    "moderation_alert",
    "report_update",
    "appeal_update",
    "safety_score_update",
    "trust_level_update",
]


class NotificationResponse(BaseModel):
    """Output for a single notification."""

    id: str
    type: NotificationType
    title: str
    body: str
    is_read: bool = False
    reference_id: str | None = None
    target_route: str | None = None
    created_at: datetime
