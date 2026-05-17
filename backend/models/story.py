# backend/models/story.py
"""Story data models."""

from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class Story(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: str
    author_uid: str
    image_url: str
    text: str | None = None
    status: Literal["approved", "rejected", "pending"] = "approved"
    view_count: int = 0
    created_at: datetime
    expires_at: datetime
    schema_version: int = 1


class CreateStoryRequest(BaseModel):
    image_url: str
    text: str | None = Field(None, max_length=200)
