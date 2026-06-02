# backend/routes/safety.py
"""Safety API routes."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Any

from fastapi import APIRouter, Depends, Response
from fastapi.responses import JSONResponse

from middleware.auth import get_current_user_claims
from models.safety import AppealCreateRequest
from services import safety as safety_service

router = APIRouter(prefix="/safety", tags=["safety"])


def _meta() -> dict[str, str]:
    return {
        "request_id": str(uuid.uuid4()),
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@router.get("/stats")
async def get_stats(
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Fetch safety and reputation stats."""
    stats = await safety_service.get_safety_stats(claims["uid"])
    return JSONResponse(content={"data": stats.model_dump(mode="json"), "meta": _meta()})


@router.get("/appeals")
async def list_appeals(
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Fetch user's appeals."""
    appeals = await safety_service.get_appeals(claims["uid"])
    data = [a.model_dump(mode="json") for a in appeals]
    return JSONResponse(content={"data": data, "meta": _meta()})


@router.post("/appeals", status_code=201)
async def create_appeal(
    payload: AppealCreateRequest,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> Response:
    """Submit a new appeal."""
    await safety_service.create_appeal(claims["uid"], payload.content_id, payload.reason)
    return Response(status_code=201)
