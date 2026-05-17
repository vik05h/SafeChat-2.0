# backend/models/post.py
"""Post data models."""

from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class Post(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: str
    author_uid: str
    text: str
    image_url: str | None = None
    status: Literal["approved", "rejected", "pending"] = "approved"
    like_count: int = 0
    comment_count: int = 0
    created_at: datetime
    updated_at: datetime
    schema_version: int = 1


class CreatePostRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=500)
    image_url: str | None = None
