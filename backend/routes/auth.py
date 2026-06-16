# backend/routes/auth.py
"""Authentication routes."""

from __future__ import annotations

import asyncio
import uuid
from datetime import datetime, timezone
from typing import Any

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse

from core.firebase import db
from middleware.auth import get_current_user_claims
from models.auth import CurrentUser
from models.user import OnboardRequest
from services import users as users_service

router = APIRouter(prefix="/auth", tags=["auth"])


def _meta() -> dict[str, str]:
    return {
        "request_id": str(uuid.uuid4()),
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


def _sanitize(obj: Any) -> Any:
    """Recursively convert datetime/Firestore timestamp objects to ISO strings.

    Firestore returns DatetimeWithNanoseconds (a datetime subclass) for
    timestamp fields. JSONResponse cannot serialize these, so we walk the
    structure and convert any datetime instance to an ISO 8601 string.
    """
    if isinstance(obj, datetime):
        return obj.isoformat()
    if isinstance(obj, dict):
        return {k: _sanitize(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [_sanitize(item) for item in obj]
    return obj


@router.get("/me")
async def get_me(
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Return the authenticated user, plus their Firestore profile if it exists.

    If no /users/{uid} document exists yet, `needs_onboarding` is true and the
    client should run the onboarding flow (username selection, profile setup).
    """
    user = CurrentUser.from_decoded_token(claims)

    snapshot = await asyncio.to_thread(
        lambda: db.collection("users").document(user.uid).get()
    )

    if snapshot.exists:
        data = {
            "user": user.model_dump(),
            "profile": _sanitize(snapshot.to_dict()),
            "needs_onboarding": False,
        }
    else:
        data = {
            "user": user.model_dump(),
            "profile": None,
            "needs_onboarding": True,
        }

    return JSONResponse(content={"data": data, "meta": _meta()})


@router.post("/onboard", status_code=201)
async def onboard(
    payload: OnboardRequest,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Create the authenticated user's profile and reserve their username.

    The username and user-profile docs are created in a single Firestore
    transaction. Validation here is structural only; content moderation of
    `username`, `display_name`, and `bio` is added in Phase 2.
    """
    uid = claims["uid"]
    email = claims.get("email")
    photo_url = claims.get("picture") # Extracted from Google Auth

    try:
        profile = await users_service.reserve_username(
            uid=uid,
            email=email,
            phone_number=payload.phone_number,
            username=payload.username,
            display_name=payload.display_name,
            dob=payload.dob,
            bio=payload.bio,
            photo_url=photo_url,
        )
    except users_service.UsernameTaken as exc:
        raise HTTPException(
            status_code=409,
            detail={
                "code": "USERNAME_TAKEN",
                "message": f"Username '{payload.username}' is already taken.",
                "field": "username",
            },
        ) from exc
    except users_service.PhoneNumberTaken as exc:
        raise HTTPException(
            status_code=409,
            detail={
                "code": "PHONE_TAKEN",
                "message": f"Phone number '{payload.phone_number}' is already registered.",
                "field": "phone_number",
            },
        ) from exc
    except users_service.AlreadyOnboarded as exc:
        raise HTTPException(
            status_code=409,
            detail={
                "code": "CONFLICT",
                "message": "User has already completed onboarding.",
            },
        ) from exc

    return JSONResponse(
        status_code=201,
        content={
            "data": {"profile": profile.model_dump(mode="json")},
            "meta": _meta(),
        },
    )
