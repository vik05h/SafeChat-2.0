# backend/models/storage.py
"""Storage-related Pydantic models."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel


class UploadUrlResponse(BaseModel):
    upload_url: str
    object_path: str
    expires_at: datetime
