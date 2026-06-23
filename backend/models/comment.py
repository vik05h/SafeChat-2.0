# backend/models/comment.py
"""Comment data models."""

from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class Comment(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: str
    post_id: str
    author_uid: str
    author_display_name: str = "Anonymous"
    author_photo_url: str = ""
    author_username: str = "unknown"
    text: str
    parent_comment_id: str | None = None
    status: Literal["approved", "pending_review", "rejected"] = "approved"
    moderation_layer: str | None = None
    moderation_reason: str | None = None
    rejection_reason: str | None = None
    flagged_terms: list[str] = Field(default_factory=list)
    like_count: int = 0
    created_at: datetime
    updated_at: datetime
    schema_version: int = 1


class CreateCommentRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=300)
    parent_comment_id: str | None = Field(
        default=None, description="Optional ID of the parent comment if this is a reply"
    )
    # When True, submit flagged content for human verification (pending_review).
    submit_for_review: bool = False
