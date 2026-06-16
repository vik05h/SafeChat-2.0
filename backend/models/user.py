# backend/models/user.py
"""User-related Pydantic models."""

from __future__ import annotations

import re
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field, field_validator

USERNAME_PATTERN = re.compile(r"^[a-z0-9_]{3,30}$")


class OnboardRequest(BaseModel):
    """Input for POST /auth/onboard."""

    username: str = Field(description="Lowercase letters, digits, and underscores. 3-30 chars.")
    display_name: str = Field(min_length=1, max_length=50)
    phone_number: str = Field(description="E.164 formatted phone number", min_length=10, max_length=15)
    dob: str = Field(description="Date of birth in YYYY-MM-DD format")
    bio: str = Field(default="", max_length=200)

    @field_validator("username")
    @classmethod
    def _validate_username(cls, value: str) -> str:
        normalised = value.strip().lower()
        if not USERNAME_PATTERN.match(normalised):
            raise ValueError(
                "Username must be 3-30 characters: lowercase letters, "
                "digits, and underscores only."
            )
        return normalised


class UpdateProfileRequest(BaseModel):
    """Partial update for PATCH /users/me. All fields optional."""

    display_name: str | None = Field(default=None, min_length=1, max_length=50)
    bio: str | None = Field(default=None, max_length=200)
    photo_url: str | None = None
    private_account: bool | None = None
    allow_messages_from: Literal["everyone", "followers", "none"] | None = None


class UserProfile(BaseModel):
    """Full /users/{uid} document shape — matches docs/DATABASE_SCHEMA.md."""

    uid: str
    email: str
    phone_number: str
    username: str
    display_name: str
    dob: str
    bio: str
    photo_url: str | None = None

    follower_count: int
    following_count: int
    post_count: int

    is_verified: bool
    is_suspended: bool

    created_at: datetime
    updated_at: datetime
    last_active_at: datetime

    private_account: bool
    allow_messages_from: Literal["everyone", "followers", "none"]

    schema_version: int


class UserSearchResult(BaseModel):
    """Lightweight user record returned by GET /users/search."""

    uid: str
    username: str
    display_name: str
    photo_url: str | None = None


class DeviceTokenRequest(BaseModel):
    """Input for POST /users/device-token."""

    token: str = Field(min_length=1)
