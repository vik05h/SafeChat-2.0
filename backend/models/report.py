# backend/models/report.py
"""Report data models."""

from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class Report(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: str
    reporter_uid: str
    target_type: Literal["post", "comment", "user", "story"]
    target_id: str
    reason: str
    status: Literal["pending", "reviewed", "dismissed"] = "pending"
    created_at: datetime
    schema_version: int = 1


class CreateReportRequest(BaseModel):
    target_type: Literal["post", "comment", "user", "story"]
    target_id: str
    reason: str = Field(..., min_length=10, max_length=500)
