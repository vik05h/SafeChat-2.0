# backend/tests/test_moderation_routes.py
"""Tests for routes/moderation.py — analyze + appeals (user queue) endpoints."""

from __future__ import annotations

from collections.abc import Iterator
from datetime import UTC, datetime
from typing import Any

import pytest
from fastapi.testclient import TestClient

from main import app
from middleware.auth import get_current_user_claims
from models.moderation import Match, ModerationQueueItem, ModerationResult
from routes import moderation as moderation_routes


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)


@pytest.fixture(autouse=True)
def _reset_overrides() -> Iterator[None]:
    yield
    app.dependency_overrides.clear()


def _override_claims(claims: dict[str, Any]) -> None:
    async def fake_claims() -> dict[str, Any]:
        return claims

    app.dependency_overrides[get_current_user_claims] = fake_claims


def test_analyze_returns_status_and_matches(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "u1"})

    async def fake_moderate(text: str) -> ModerationResult:
        return ModerationResult(
            blocked=True,
            layer="keyword",
            category="english_slurs",
            reason="keyword match: idiot",
            matches=[Match(term="idiot", category="english_slurs", weight=0.5, start=0, end=5)],
            content_hash="h",
        )

    async def fake_log(**kwargs: Any) -> None:
        return None

    monkeypatch.setattr(moderation_routes, "moderate_text", fake_moderate)
    monkeypatch.setattr(moderation_routes, "log_moderation_decision", fake_log)

    response = client.post("/api/v1/moderation/analyze", json={"text": "idiot"})

    assert response.status_code == 200
    data = response.json()["data"]
    assert data["status"] == "BLOCKED"
    assert data["matches"][0]["term"] == "idiot"
    assert data["matches"][0]["start"] == 0


def test_list_my_appeals_returns_user_queue(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "u1"})

    async def fake_list_for_user(uid: str, limit: int = 50) -> list[ModerationQueueItem]:
        return [
            ModerationQueueItem(
                id="q1",
                content_type="post",
                content_id="c1",
                author_uid=uid,
                text="bad words",
                status="rejected",
                reason="Contains a slur",
                created_at=datetime(2026, 6, 1, tzinfo=UTC),
            )
        ]

    monkeypatch.setattr(moderation_routes.moderation_queue, "list_for_user", fake_list_for_user)

    response = client.get("/api/v1/moderation/appeals")

    assert response.status_code == 200
    items = response.json()["data"]["items"]
    assert len(items) == 1
    assert items[0]["status"] == "rejected"
    assert items[0]["reason"] == "Contains a slur"
