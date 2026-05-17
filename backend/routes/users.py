# backend/routes/users.py
"""User profile routes."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, Response
from fastapi.responses import JSONResponse

from middleware.auth import get_current_user_claims
from models.user import UpdateProfileRequest
from moderation.engine import moderate_text
from services import blocks as blocks_service
from services import users as users_service

router = APIRouter(prefix="/users", tags=["users"])

_SEARCH_LIMIT_DEFAULT = 10
_SEARCH_LIMIT_MAX = 20


def _meta() -> dict[str, str]:
    return {
        "request_id": str(uuid.uuid4()),
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


def _user_not_found(identifier: str) -> HTTPException:
    return HTTPException(
        status_code=404,
        detail={"code": "NOT_FOUND", "message": f"User '{identifier}' not found."},
    )


def _self_block_error() -> HTTPException:
    return HTTPException(
        status_code=400,
        detail={"code": "INVALID_INPUT", "message": "You cannot block yourself."},
    )


# NOTE: /search is declared before /{username} so the literal path wins over
# the path parameter (both are GET).
@router.get("/search")
async def search_users(
    q: str = "",
    limit: int = _SEARCH_LIMIT_DEFAULT,
    _claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Prefix-search users by username. Empty query returns an empty list."""
    capped_limit = max(1, min(limit, _SEARCH_LIMIT_MAX))
    results = await users_service.search_users(q, capped_limit)
    return JSONResponse(content={"data": {"results": results}, "meta": _meta()})


@router.patch("/me")
async def update_me(
    payload: UpdateProfileRequest,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Update the authenticated user's own profile.

    `display_name` and `bio`, when present, are run through the moderation
    cascade before persisting. A blocked value yields 422 MODERATION_BLOCKED.
    """
    uid = claims["uid"]
    fields = payload.model_dump(exclude_unset=True)

    for field_name in ("display_name", "bio"):
        value = fields.get(field_name)
        if isinstance(value, str) and value.strip():
            result = await moderate_text(value)
            if result.blocked:
                raise HTTPException(
                    status_code=422,
                    detail={
                        "code": "MODERATION_BLOCKED",
                        "message": (
                            f"The submitted {field_name.replace('_', ' ')} "
                            "was blocked by content moderation."
                        ),
                        "field": field_name,
                    },
                )

    try:
        profile = await users_service.update_profile(uid, fields)
    except users_service.ProfileNotFound as exc:
        raise HTTPException(
            status_code=404,
            detail={
                "code": "NOT_FOUND",
                "message": "Profile not found. Complete onboarding first.",
            },
        ) from exc

    return JSONResponse(
        content={
            "data": {"profile": profile.model_dump(mode="json")},
            "meta": _meta(),
        }
    )


@router.post("/{uid}/block", status_code=204)
async def block_user(
    uid: str,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> Response:
    """Block another user. Idempotent."""
    blocker_uid = claims["uid"]
    # Self-check first — avoids a needless profile read for an invalid request.
    if blocker_uid == uid:
        raise _self_block_error()

    if await users_service.get_user_profile(uid) is None:
        raise _user_not_found(uid)

    await blocks_service.block_user(blocker_uid, uid)
    return Response(status_code=204)


@router.delete("/{uid}/block", status_code=204)
async def unblock_user(
    uid: str,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> Response:
    """Unblock a user. Idempotent."""
    blocker_uid = claims["uid"]
    if blocker_uid == uid:
        raise _self_block_error()

    if await users_service.get_user_profile(uid) is None:
        raise _user_not_found(uid)

    await blocks_service.unblock_user(blocker_uid, uid)
    return Response(status_code=204)


@router.get("/{username}")
async def get_user(
    username: str,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Fetch a public profile by username.

    `is_following` / `is_followed_by` are placeholders (false) until the follow
    system lands in Step 3. `is_blocked` reflects whether the viewer has blocked
    this user.
    """
    profile = await users_service.get_profile_by_username(username)
    if profile is None:
        raise _user_not_found(username)

    viewer_uid = claims["uid"]
    blocked = await blocks_service.is_blocked(viewer_uid, profile.uid)

    data = {
        **profile.model_dump(mode="json"),
        # Placeholders — wired up in Step 3.
        "is_following": False,
        "is_followed_by": False,
        "is_blocked": blocked,
    }
    return JSONResponse(content={"data": data, "meta": _meta()})
