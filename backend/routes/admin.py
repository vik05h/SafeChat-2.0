# backend/routes/admin.py
"""Admin-only routes."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Any

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from middleware.auth import require_admin
from moderation.engine import moderate_text
from services.moderation_log import log_moderation_decision

router = APIRouter(prefix="/admin", tags=["admin"])

_MAX_TEST_LENGTH = 10_000


def _meta() -> dict[str, str]:
    return {
        "request_id": str(uuid.uuid4()),
        "timestamp": datetime.now(timezone.utc).isoformat(),
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
