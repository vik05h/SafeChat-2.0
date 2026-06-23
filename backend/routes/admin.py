# backend/routes/admin.py
"""Admin-only routes."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime
from typing import Any

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from middleware.auth import require_admin
from moderation.engine import moderate_text
from services import moderation_queue, moderation_review
from services.moderation_log import log_moderation_decision

router = APIRouter(prefix="/admin", tags=["admin"])

_MAX_TEST_LENGTH = 10_000


def _meta() -> dict[str, str]:
    return {
        "request_id": str(uuid.uuid4()),
        "timestamp": datetime.now(UTC).isoformat(),
    }


class ModerationTestRequest(BaseModel):
    """Input for POST /admin/moderation/test."""

    text: str = Field(max_length=_MAX_TEST_LENGTH)


@router.post("/moderation/test")
async def test_moderation(
    payload: ModerationTestRequest,
    admin_claims: dict[str, Any] = Depends(require_admin),
) -> JSONResponse:
    """Run text through the full moderation cascade and return the result.

    Decisions are logged to `moderation_logs` with content_type="test" so
    admin testing activity is auditable.
    """
    result = await moderate_text(payload.text)

    await log_moderation_decision(
        result=result,
        content_type="test",
        content_id=None,
        author_uid=admin_claims["uid"],
    )

    return JSONResponse(
        content={
            "data": {"result": result.model_dump(mode="json")},
            "meta": _meta(),
        }
    )


class RejectRequest(BaseModel):
    """Input for POST /admin/moderation/queue/{id}/reject."""

    reason: str = Field(default="", max_length=500)


@router.get("/moderation/queue")
async def get_moderation_queue(
    limit: int = 50,
    admin_claims: dict[str, Any] = Depends(require_admin),
) -> JSONResponse:
    """List content awaiting human verification, oldest first."""
    items = await moderation_queue.list_pending(limit=limit)
    return JSONResponse(
        content={
            "data": {"items": [item.model_dump(mode="json") for item in items]},
            "meta": _meta(),
        }
    )


@router.post("/moderation/queue/{queue_id}/approve")
async def approve_queue_item(
    queue_id: str,
    admin_claims: dict[str, Any] = Depends(require_admin),
) -> JSONResponse:
    """Approve pending content — it becomes visible to its audience."""
    try:
        item = await moderation_review.approve(queue_id, admin_claims["uid"])
    except moderation_review.QueueItemNotFound as exc:
        raise HTTPException(
            status_code=404,
            detail={"code": "NOT_FOUND", "message": f"Queue item '{queue_id}' not found."},
        ) from exc
    except moderation_review.AlreadyResolved as exc:
        raise HTTPException(
            status_code=409,
            detail={"code": "CONFLICT", "message": "This item has already been reviewed."},
        ) from exc

    return JSONResponse(content={"data": {"item": item.model_dump(mode="json")}, "meta": _meta()})


@router.post("/moderation/queue/{queue_id}/reject")
async def reject_queue_item(
    queue_id: str,
    payload: RejectRequest,
    admin_claims: dict[str, Any] = Depends(require_admin),
) -> JSONResponse:
    """Reject pending content — it stays hidden; the author sees the reason."""
    try:
        item = await moderation_review.reject(queue_id, admin_claims["uid"], payload.reason or None)
    except moderation_review.QueueItemNotFound as exc:
        raise HTTPException(
            status_code=404,
            detail={"code": "NOT_FOUND", "message": f"Queue item '{queue_id}' not found."},
        ) from exc
    except moderation_review.AlreadyResolved as exc:
        raise HTTPException(
            status_code=409,
            detail={"code": "CONFLICT", "message": "This item has already been reviewed."},
        ) from exc

    return JSONResponse(content={"data": {"item": item.model_dump(mode="json")}, "meta": _meta()})
