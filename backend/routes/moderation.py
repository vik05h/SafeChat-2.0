# backend/routes/moderation.py
"""Client-facing moderation routes."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Any

from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from middleware.auth import get_current_user_claims
from moderation.engine import moderate_text
from services.moderation_log import log_moderation_decision

router = APIRouter(prefix="/moderation", tags=["moderation"])

_MAX_TEXT_LENGTH = 10_000


def _meta() -> dict[str, str]:
    return {
        "request_id": str(uuid.uuid4()),
        "timestamp": datetime.now(timezone.utc).isoformat(),
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
            },
            "meta": _meta(),
        }
    )
