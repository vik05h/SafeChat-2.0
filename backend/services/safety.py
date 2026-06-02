# backend/services/safety.py
"""Safety and Moderation analytics service layer."""

from __future__ import annotations

import asyncio
from datetime import datetime, timezone
import uuid
from typing import Any

from google.cloud import firestore
from google.cloud.firestore import FieldFilter

from core.firebase import db
from models.safety import AppealResponse, SafetyStatsResponse, SafetyTrendPoint


def _user_appeals_ref(uid: str) -> firestore.CollectionReference:
    return db.collection("users").document(uid).collection("appeals")


async def get_safety_stats(uid: str) -> SafetyStatsResponse:
    """Calculate and return safety stats for the user.
    
    In a fully productionized system, these scores would be pre-calculated
    via background jobs. Here we compute them dynamically or return stubs
    matching the frontend's expectations for Beta validation.
    """
    def _fetch() -> SafetyStatsResponse:
        # In a real system, we'd query moderation_logs, reports, appeals.
        # For the Beta Sprint, we will return a mock baseline that acts as
        # if the user has a clean history, simulating the exact logic requested.
        
        # Base calculations (mocked for now, can be populated if collections exist)
        safety_score = 100
        reputation_score = 85
        trust_level = "Trusted" # 80-100 Trusted
        
        # Return the baseline score with a mock trend
        now = datetime.now(timezone.utc)
        trend = [
            SafetyTrendPoint(date=now.isoformat(), score=safety_score)
        ]
        
        return SafetyStatsResponse(
            safety_score=safety_score,
            reputation_score=reputation_score,
            trust_level=trust_level,
            reports_submitted=0,
            reports_resolved=0,
            warnings_received=0,
            appeals_won=0,
            appeals_lost=0,
            safety_trend=trend,
        )

    return await asyncio.to_thread(_fetch)


async def get_appeals(uid: str) -> list[AppealResponse]:
    """Fetch user's appeals."""
    def _query() -> list[AppealResponse]:
        q = (
            _user_appeals_ref(uid)
            .order_by("created_at", direction=firestore.Query.DESCENDING)
        )
        results: list[AppealResponse] = []
        for snap in q.stream():
            d = snap.to_dict() or {}
            d["id"] = snap.id
            results.append(AppealResponse.model_validate(d))
        return results
        
    return await asyncio.to_thread(_query)


async def create_appeal(uid: str, content_id: str, reason: str) -> None:
    """Create a new appeal."""
    def _write() -> None:
        doc_id = str(uuid.uuid4())
        _user_appeals_ref(uid).document(doc_id).set({
            "content_id": content_id,
            "content_preview": "Appealed content...", # normally fetch post/message text
            "reason_provided": reason,
            "appeal_status": "submitted",
            "created_at": firestore.SERVER_TIMESTAMP,
        })
        
    await asyncio.to_thread(_write)
