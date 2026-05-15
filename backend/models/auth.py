# backend/models/auth.py
"""Auth-related Pydantic models."""

from __future__ import annotations

from typing import Any

from pydantic import BaseModel


class CurrentUser(BaseModel):
    """The authenticated caller, derived from verified Firebase ID token claims."""

    uid: str
    email: str | None = None
    email_verified: bool = False
    is_admin: bool = False

    @classmethod
    def from_decoded_token(cls, claims: dict[str, Any]) -> "CurrentUser":
        """Build a CurrentUser from the dict returned by verify_id_token.

        The `admin` custom claim is the convention used by SafeChat for
        flagging admin users (set via Firebase Admin SDK from the admin panel).
        """
        return cls(
            uid=claims["uid"],
            email=claims.get("email"),
            email_verified=bool(claims.get("email_verified", False)),
            is_admin=bool(claims.get("admin", False)),
        )
