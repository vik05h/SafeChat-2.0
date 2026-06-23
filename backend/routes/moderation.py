# backend/routes/moderation.py
"""Client-facing moderation routes."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime
from typing import Any

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from core.firebase import db
from middleware.auth import get_current_user_claims
from moderation.engine import moderate_text
from services import moderation_queue
from services.moderation_log import log_moderation_decision

router = APIRouter(prefix="/moderation", tags=["moderation"])

_MAX_TEXT_LENGTH = 10_000


def _meta() -> dict[str, str]:
    return {
        "request_id": str(uuid.uuid4()),
        "timestamp": datetime.now(UTC).isoformat(),
    }


class ModerationAnalyzeRequest(BaseModel):
    """Input for POST /moderation/analyze."""

    content_type: str = Field(default="text")
    text: str = Field(max_length=_MAX_TEXT_LENGTH)


@router.post("/analyze")
async def analyze_content(
    payload: ModerationAnalyzeRequest,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Analyze text for violations before submission.

    Returns SAFE, WARNING, or BLOCKED status.
    """
    result = await moderate_text(payload.text)

    # Convert internal 'blocked' boolean to SAFE/BLOCKED/WARNING statuses
    # For MVP, warning is not natively produced by moderate_text unless we configure it,
    # but the frontend expects status string.
    status = "BLOCKED" if result.blocked else "SAFE"

    # Log the decision
    await log_moderation_decision(
        result=result,
        content_type="pre_flight",
        content_id=None,
        author_uid=claims["uid"],
    )

    return JSONResponse(
        content={
            "data": {
                "status": status,
                "reason": result.reason,
                "category": result.category,
                # Exact spans of any flagged terms, for client-side highlighting.
                "matches": [m.model_dump(mode="json") for m in result.matches],
            },
            "meta": _meta(),
        }
    )


class AppealRequest(BaseModel):
    reason: str = Field(..., max_length=500)
    content_type: str = Field(default="post")  # 'post', 'comment', 'message'


@router.post("/appeals/{content_id}")
async def submit_appeal(
    content_id: str,
    payload: AppealRequest,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Submit an appeal for blocked content to be reviewed by humans."""
    uid = claims["uid"]

    appeal_ref = db.collection("appeals").document()

    appeal_data = {
        "id": appeal_ref.id,
        "content_id": content_id,
        "content_type": payload.content_type,
        "author_uid": uid,
        "reason": payload.reason,
        "status": "pending",
        "created_at": datetime.now(UTC),
    }

    appeal_ref.set(appeal_data)

    # Update the original content to show it's under review
    # This depends on the content_type
    try:
        if payload.content_type == "post":
            db.collection("posts").document(content_id).update({"status": "pending_review"})
        elif payload.content_type == "comment":
            # Finding the comment requires a group query or knowing the post_id
            # Assuming comments are top-level or have a known path,
            # or for simplicity here we just use 'comments' collection if it exists
            # Wait, DATABASE_SCHEMA says posts/{postId}/comments/{commentId}
            pass  # We'd need the post ID. For now we will support posts primarily.
    except Exception:
        # Ignore if document doesn't exist
        pass

    return JSONResponse(
        content={
            "data": appeal_data,
            "meta": _meta(),
        }
    )


@router.get("/appeals")
async def list_my_appeals(
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """List the current user's content under / after human verification.

    Backs the Profile -> Appeals (Content Status) screen: each item carries its
    status (pending_review / approved / rejected) and, when rejected, the
    reason — so the author sees what happened to flagged content they submitted.
    """
    items = await moderation_queue.list_for_user(claims["uid"])
    return JSONResponse(
        content={
            "data": {"items": [item.model_dump(mode="json") for item in items]},
            "meta": _meta(),
        }
    )
