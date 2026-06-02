# backend/models/comment.py
"""Comment data models."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class Comment(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: str
    post_id: str
    author_uid: str
    text: str
    created_at: datetime
    updated_at: datetime
    schema_version: int = 1


class CreateCommentRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=300)
