# backend/tests/test_users_routes.py
"""Tests for the user profile routes."""

from __future__ import annotations

from collections.abc import Iterator
from datetime import datetime, timezone
from typing import Any

import pytest
from fastapi.testclient import TestClient

from main import app
from middleware.auth import get_current_user_claims
from models.moderation import ModerationResult
from models.user import UserProfile
from routes import users as users_routes
from services import users as users_service


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)


@pytest.fixture(autouse=True)
def _reset_overrides() -> Iterator[None]:
    yield
    app.dependency_overrides.clear()


@pytest.fixture(autouse=True)
def _default_moderation_clean(monkeypatch: pytest.MonkeyPatch) -> None:
    """Default: moderation passes everything. Tests override to block."""

    async def fake_moderate(text: str) -> ModerationResult:
        return ModerationResult(blocked=False, content_hash="h")

    monkeypatch.setattr(users_routes, "moderate_text", fake_moderate)


def _override_claims(claims: dict[str, Any]) -> None:
    async def fake_claims() -> dict[str, Any]:
        return claims

    app.dependency_overrides[get_current_user_claims] = fake_claims


def _sample_profile(**overrides: Any) -> UserProfile:
    now = datetime(2026, 5, 17, tzinfo=timezone.utc)
    base: dict[str, Any] = {
        "uid": "uid-1",
        "email": "alice@example.com",
        "username": "alice",
        "display_name": "Alice",
        "bio": "hello",
        "photo_url": None,
        "follower_count": 0,
        "following_count": 0,
        "post_count": 0,
        "is_verified": False,
        "is_suspended": False,
        "created_at": now,
        "updated_at": now,
        "last_active_at": now,
        "private_account": False,
        "allow_messages_from": "everyone",
        "schema_version": 1,
    }
    base.update(overrides)
    return UserProfile(**base)


# ---- GET /users/{username} ------------------------------------------------

def test_get_user_returns_profile(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "viewer", "admin": False})

    async def fake_get(username: str) -> UserProfile:
        return _sample_profile(username=username)

    monkeypatch.setattr(users_service, "get_profile_by_username", fake_get)

    response = client.get("/api/v1/users/alice")

    assert response.status_code == 200
    data = response.json()["data"]
    assert data["username"] == "alice"
    assert data["is_following"] is False
    assert data["is_followed_by"] is False
    assert data["is_blocked"] is False


def test_get_user_not_found(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "viewer", "admin": False})

    async def fake_get(username: str) -> None:
        return None

    monkeypatch.setattr(users_service, "get_profile_by_username", fake_get)

    response = client.get("/api/v1/users/ghost")

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "NOT_FOUND"


def test_get_user_requires_auth(client: TestClient) -> None:
    response = client.get("/api/v1/users/alice")
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "UNAUTHENTICATED"


# ---- PATCH /users/me ------------------------------------------------------

def test_patch_me_updates_display_name(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "uid-1", "admin": False})

    async def fake_update(uid: str, fields: dict[str, Any]) -> UserProfile:
        return _sample_profile(display_name=fields["display_name"])

    monkeypatch.setattr(users_service, "update_profile", fake_update)

    response = client.patch(
        "/api/v1/users/me",
        json={"display_name": "Alice Updated"},
    )

    assert response.status_code == 200
    assert response.json()["data"]["profile"]["display_name"] == "Alice Updated"


def test_patch_me_blocks_toxic_bio(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "uid-1", "admin": False})

    async def fake_moderate(text: str) -> ModerationResult:
        return ModerationResult(
            blocked=True,
            layer="keyword",
            category="english_slurs",
            reason="keyword match",
            content_hash="h",
        )

    monkeypatch.setattr(users_routes, "moderate_text", fake_moderate)

    called = {"update": 0}

    async def fake_update(uid: str, fields: dict[str, Any]) -> UserProfile:
        called["update"] += 1
        return _sample_profile()

    monkeypatch.setattr(users_service, "update_profile", fake_update)

    response = client.patch(
        "/api/v1/users/me",
        json={"bio": "something toxic"},
    )

    assert response.status_code == 422
    body = response.json()
    assert body["error"]["code"] == "MODERATION_BLOCKED"
    assert body["error"]["field"] == "bio"
    assert called["update"] == 0  # blocked before any write


def test_patch_me_rejects_long_display_name(client: TestClient) -> None:
    _override_claims({"uid": "uid-1", "admin": False})

    response = client.patch(
        "/api/v1/users/me",
        json={"display_name": "x" * 51},
    )

    assert response.status_code == 400
    assert response.json()["error"]["code"] == "INVALID_INPUT"


# ---- GET /users/search ----------------------------------------------------

def test_search_returns_matches(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "viewer", "admin": False})

    async def fake_search(query: str, limit: int) -> list[dict[str, Any]]:
        return [
            {"uid": "u1", "username": "alice", "display_name": "Alice",
             "photo_url": None},
            {"uid": "u2", "username": "alicia", "display_name": "Alicia",
             "photo_url": None},
        ]

    monkeypatch.setattr(users_service, "search_users", fake_search)

    response = client.get("/api/v1/users/search?q=ali")

    assert response.status_code == 200
    results = response.json()["data"]["results"]
    assert len(results) == 2
    assert results[0]["username"] == "alice"


def test_search_empty_query_returns_empty(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "viewer", "admin": False})

    async def fake_search(query: str, limit: int) -> list[dict[str, Any]]:
        # Mirror the real service: empty query yields no results.
        return [] if not query.strip() else [{"uid": "u1"}]

    monkeypatch.setattr(users_service, "search_users", fake_search)

    response = client.get("/api/v1/users/search?q=")

    assert response.status_code == 200
    assert response.json()["data"]["results"] == []


def test_search_respects_limit(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "viewer", "admin": False})
    captured: dict[str, int] = {}

    async def fake_search(query: str, limit: int) -> list[dict[str, Any]]:
        captured["limit"] = limit
        return [
            {"uid": f"u{i}", "username": f"user{i}",
             "display_name": f"User {i}", "photo_url": None}
            for i in range(limit)
        ]

    monkeypatch.setattr(users_service, "search_users", fake_search)

    # Explicit limit honored.
    response = client.get("/api/v1/users/search?q=user&limit=3")
    assert response.status_code == 200
    assert captured["limit"] == 3
    assert len(response.json()["data"]["results"]) == 3

    # Over-max limit capped to 20.
    response = client.get("/api/v1/users/search?q=user&limit=50")
    assert captured["limit"] == 20
    assert len(response.json()["data"]["results"]) == 20


@pytest.mark.asyncio
async def test_search_users_empty_query_short_circuits() -> None:
    assert await users_service.search_users("", 10) == []
    assert await users_service.search_users("   ", 10) == []
