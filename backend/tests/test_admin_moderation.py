# backend/tests/test_admin_moderation.py
"""Tests for the admin moderation-test endpoint."""

from __future__ import annotations

from collections.abc import Iterator
from datetime import UTC, datetime
from typing import Any

import pytest
from fastapi.testclient import TestClient

from main import app
from middleware.auth import get_current_user_claims
from models.moderation import ModerationQueueItem, ModerationResult
from routes import admin as admin_routes


@pytest.fixture
def client() -> TestClient:
    # TestClient without `with` -> lifespan doesn't run, so keyword_filter
    # never tries to refresh from Firestore during the test.
    return TestClient(app)


@pytest.fixture(autouse=True)
def _reset_dependency_overrides() -> Iterator[None]:
    yield
    app.dependency_overrides.clear()


@pytest.fixture(autouse=True)
def _noop_log(monkeypatch: pytest.MonkeyPatch) -> None:
    """Default to a no-op log call. Override in tests that verify logging."""

    async def fake_log(**kwargs: Any) -> None:
        return None

    monkeypatch.setattr(admin_routes, "log_moderation_decision", fake_log)


def _override_claims(claims: dict[str, Any]) -> None:
    async def fake_claims() -> dict[str, Any]:
        return claims

    app.dependency_overrides[get_current_user_claims] = fake_claims


def test_admin_user_can_test_moderation(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "admin-uid", "admin": True})

    async def fake_moderate(text: str) -> ModerationResult:
        return ModerationResult(
            blocked=False,
            latency_ms=12.3,
            layer_latencies={"keyword": 0.1, "openai": 12.0},
            content_hash="abc123",
        )

    monkeypatch.setattr(admin_routes, "moderate_text", fake_moderate)

    response = client.post(
        "/api/v1/admin/moderation/test",
        json={"text": "hello world"},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["data"]["result"]["blocked"] is False
    assert body["data"]["result"]["latency_ms"] == 12.3
    assert body["data"]["result"]["layer_latencies"] == {
        "keyword": 0.1,
        "openai": 12.0,
    }
    assert "request_id" in body["meta"]


def test_non_admin_user_gets_403(client: TestClient) -> None:
    _override_claims({"uid": "regular-uid", "admin": False})

    response = client.post(
        "/api/v1/admin/moderation/test",
        json={"text": "anything"},
    )

    assert response.status_code == 403
    body = response.json()
    assert body["error"]["code"] == "FORBIDDEN"
    assert "admin" in body["error"]["message"].lower()
    assert "request_id" in body["meta"]


def test_user_without_admin_claim_gets_403(client: TestClient) -> None:
    """Claims lacking the `admin` key entirely should also be forbidden."""
    _override_claims({"uid": "regular-uid"})

    response = client.post(
        "/api/v1/admin/moderation/test",
        json={"text": "anything"},
    )

    assert response.status_code == 403


def test_unauthenticated_request_gets_401(client: TestClient) -> None:
    """No Authorization header -> 401 from get_current_user_claims."""
    response = client.post(
        "/api/v1/admin/moderation/test",
        json={"text": "anything"},
    )

    assert response.status_code == 401
    body = response.json()
    assert body["error"]["code"] == "UNAUTHENTICATED"


def test_keyword_block_returned(client: TestClient, monkeypatch: pytest.MonkeyPatch) -> None:
    _override_claims({"uid": "admin-uid", "admin": True})

    async def fake_moderate(text: str) -> ModerationResult:
        return ModerationResult(
            blocked=True,
            layer="keyword",
            category="english_slurs",
            reason="keyword match: idiot",
            latency_ms=0.5,
            layer_latencies={"keyword": 0.5},
            content_hash="xyz",
        )

    monkeypatch.setattr(admin_routes, "moderate_text", fake_moderate)

    response = client.post(
        "/api/v1/admin/moderation/test",
        json={"text": "you idiot"},
    )

    assert response.status_code == 200
    result = response.json()["data"]["result"]
    assert result["blocked"] is True
    assert result["layer"] == "keyword"
    assert result["category"] == "english_slurs"
    assert "idiot" in result["reason"]


def test_clean_text_returns_blocked_false(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "admin-uid", "admin": True})

    async def fake_moderate(text: str) -> ModerationResult:
        return ModerationResult(
            blocked=False,
            latency_ms=1.0,
            layer_latencies={"keyword": 0.1, "openai": 0.9},
            content_hash="hash",
        )

    monkeypatch.setattr(admin_routes, "moderate_text", fake_moderate)

    response = client.post(
        "/api/v1/admin/moderation/test",
        json={"text": "hello world"},
    )

    assert response.status_code == 200
    assert response.json()["data"]["result"]["blocked"] is False


def test_logging_called_with_correct_args(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "admin-uid", "admin": True})

    captured: dict[str, Any] = {}

    async def fake_log(**kwargs: Any) -> None:
        captured.update(kwargs)

    monkeypatch.setattr(admin_routes, "log_moderation_decision", fake_log)

    async def fake_moderate(text: str) -> ModerationResult:
        return ModerationResult(
            blocked=False,
            latency_ms=1.0,
            layer_latencies={"keyword": 0.1, "openai": 0.9},
            content_hash="hash-xyz",
        )

    monkeypatch.setattr(admin_routes, "moderate_text", fake_moderate)

    response = client.post(
        "/api/v1/admin/moderation/test",
        json={"text": "hello"},
    )

    assert response.status_code == 200
    assert captured["content_type"] == "test"
    assert captured["content_id"] is None
    assert captured["author_uid"] == "admin-uid"
    assert captured["result"].content_hash == "hash-xyz"
    assert captured["result"].blocked is False


# ---------------------------------------------------------------------------
# Moderation review queue endpoints
# ---------------------------------------------------------------------------


def _queue_item(status: str = "pending_review", reason: str | None = None) -> ModerationQueueItem:
    return ModerationQueueItem(
        id="q1",
        content_type="post",
        content_id="c1",
        author_uid="u1",
        author_username="alice",
        text="bad words",
        status=status,
        reason=reason,
        created_at=datetime(2026, 6, 1, tzinfo=UTC),
    )


def test_admin_queue_lists_pending(client: TestClient, monkeypatch: pytest.MonkeyPatch) -> None:
    _override_claims({"uid": "admin-uid", "admin": True})

    async def fake_list(limit: int = 50) -> list[ModerationQueueItem]:
        return [_queue_item()]

    monkeypatch.setattr(admin_routes.moderation_queue, "list_pending", fake_list)

    response = client.get("/api/v1/admin/moderation/queue")

    assert response.status_code == 200
    items = response.json()["data"]["items"]
    assert len(items) == 1
    assert items[0]["id"] == "q1"
    assert items[0]["status"] == "pending_review"


def test_admin_queue_requires_admin(client: TestClient) -> None:
    _override_claims({"uid": "u1", "admin": False})
    response = client.get("/api/v1/admin/moderation/queue")
    assert response.status_code == 403


def test_admin_approve_returns_approved_item(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "admin-uid", "admin": True})

    async def fake_approve(queue_id: str, admin_uid: str) -> ModerationQueueItem:
        return _queue_item(status="approved")

    monkeypatch.setattr(admin_routes.moderation_review, "approve", fake_approve)

    response = client.post("/api/v1/admin/moderation/queue/q1/approve")

    assert response.status_code == 200
    assert response.json()["data"]["item"]["status"] == "approved"


def test_admin_reject_returns_rejected_item_with_reason(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "admin-uid", "admin": True})

    async def fake_reject(queue_id: str, admin_uid: str, reason: str | None) -> ModerationQueueItem:
        return _queue_item(status="rejected", reason=reason)

    monkeypatch.setattr(admin_routes.moderation_review, "reject", fake_reject)

    response = client.post(
        "/api/v1/admin/moderation/queue/q1/reject",
        json={"reason": "Contains a slur"},
    )

    assert response.status_code == 200
    item = response.json()["data"]["item"]
    assert item["status"] == "rejected"
    assert item["reason"] == "Contains a slur"


def test_admin_approve_missing_item_returns_404(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "admin-uid", "admin": True})

    async def fake_approve(queue_id: str, admin_uid: str) -> ModerationQueueItem:
        raise admin_routes.moderation_review.QueueItemNotFound(queue_id)

    monkeypatch.setattr(admin_routes.moderation_review, "approve", fake_approve)

    response = client.post("/api/v1/admin/moderation/queue/nope/approve")

    assert response.status_code == 404
