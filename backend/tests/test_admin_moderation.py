# backend/tests/test_admin_moderation.py
"""Tests for the admin moderation-test endpoint."""

from __future__ import annotations

from collections.abc import Iterator
from typing import Any

import pytest
from fastapi.testclient import TestClient

from main import app
from middleware.auth import get_current_user_claims
from models.moderation import ModerationResult
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


def test_keyword_block_returned(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
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
