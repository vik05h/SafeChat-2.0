# backend/models/message.py
"""Direct-message data models."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class Message(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: str
    chat_id: str
    sender_uid: str
    text: str
    image_url: str | None = None
    read_at: datetime | None = None
    created_at: datetime
    updated_at: datetime
    schema_version: int = 1


class Chat(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: str
    participants: list[str]
    last_message_text: str | None = None
    last_message_at: datetime | None = None
    created_at: datetime
    updated_at: datetime
    schema_version: int = 1


class SendMessageRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=1000)
    image_url: str | None = None
