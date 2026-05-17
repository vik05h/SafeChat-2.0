# backend/tests/test_blocks.py
"""Tests for block/unblock — service layer and API endpoints."""

from __future__ import annotations

from collections.abc import Iterator
from datetime import datetime, timezone
from typing import Any

import pytest
from fastapi.testclient import TestClient

from main import app
from middleware.auth import get_current_user_claims
from models.user import UserProfile
from services import blocks as blocks_service
from services import users as users_service


# --------------------------------------------------------------------------
# Minimal in-memory Firestore fake (doc-level get/set/delete only)
# --------------------------------------------------------------------------

class _FakeSnapshot:
    def __init__(self, doc_id: str, data: dict[str, Any] | None) -> None:
        self.id = doc_id
        self._data = data

    @property
    def exists(self) -> bool:
        return self._data is not None

    def to_dict(self) -> dict[str, Any] | None:
        return dict(self._data) if self._data is not None else None


class _FakeDocRef:
    def __init__(self, store: dict[str, dict[str, Any]], doc_id: str) -> None:
        self._store = store
        self.id = doc_id

    def get(self) -> _FakeSnapshot:
        return _FakeSnapshot(self.id, self._store.get(self.id))

    def set(self, data: dict[str, Any]) -> None:
        self._store[self.id] = dict(data)

    def delete(self) -> None:
        self._store.pop(self.id, None)


class _FakeCollection:
    def __init__(self, store: dict[str, dict[str, Any]]) -> None:
        self._store = store

    def document(self, doc_id: str) -> _FakeDocRef:
        return _FakeDocRef(self._store, doc_id)


class _FakeDB:
    def __init__(self) -> None:
        self.store: dict[str, dict[str, Any]] = {}

    def collection(self, name: str) -> _FakeCollection:
        return _FakeCollection(self.store)


@pytest.fixture
def fake_db(monkeypatch: pytest.MonkeyPatch) -> _FakeDB:
    db = _FakeDB()
    monkeypatch.setattr(blocks_service, "db", db)
    return db


# --------------------------------------------------------------------------
# Service-layer tests
# --------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_block_user_creates_doc(fake_db: _FakeDB) -> None:
    await blocks_service.block_user("alice", "bob")

    assert "alice_bob" in fake_db.store
    doc = fake_db.store["alice_bob"]
    assert doc["blocker_uid"] == "alice"
    assert doc["blocked_uid"] == "bob"


@pytest.mark.asyncio
async def test_block_user_is_idempotent(fake_db: _FakeDB) -> None:
    await blocks_service.block_user("alice", "bob")
    await blocks_service.block_user("alice", "bob")
    assert len(fake_db.store) == 1


@pytest.mark.asyncio
async def test_unblock_user_removes_doc(fake_db: _FakeDB) -> None:
    await blocks_service.block_user("alice", "bob")
    await blocks_service.unblock_user("alice", "bob")
    assert fake_db.store == {}


@pytest.mark.asyncio
async def test_unblock_user_is_idempotent(fake_db: _FakeDB) -> None:
    # No prior block — must not raise.
    await blocks_service.unblock_user("alice", "bob")
    assert fake_db.store == {}


@pytest.mark.asyncio
async def test_is_blocked_true_and_false(fake_db: _FakeDB) -> None:
    await blocks_service.block_user("alice", "bob")

    assert await blocks_service.is_blocked("alice", "bob") is True
    # Unidirectional: bob has not blocked alice.
    assert await blocks_service.is_blocked("bob", "alice") is False
    assert await blocks_service.is_blocked("alice", "carol") is False


@pytest.mark.asyncio
async def test_block_self_raises(fake_db: _FakeDB) -> None:
    with pytest.raises(blocks_service.CannotBlockSelf):
        await blocks_service.block_user("alice", "alice")


# --------------------------------------------------------------------------
# API tests
# --------------------------------------------------------------------------

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


def _sample_profile(**overrides: Any) -> UserProfile:
    now = datetime(2026, 5, 17, tzinfo=timezone.utc)
    base: dict[str, Any] = {
        "uid": "target-uid",
        "email": "t@example.com",
        "username": "target",
        "display_name": "Target",
        "bio": "",
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


def test_cannot_block_self_via_api(client: TestClient) -> None:
    _override_claims({"uid": "me", "admin": False})

    response = client.post("/api/v1/users/me/block")

    assert response.status_code == 400
    assert response.json()["error"]["code"] == "INVALID_INPUT"


def test_block_returns_204(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "blocker", "admin": False})

    async def fake_get_profile(uid: str) -> UserProfile:
        return _sample_profile(uid=uid)

    monkeypatch.setattr(users_service, "get_user_profile", fake_get_profile)

    calls = {"block": 0}

    async def fake_block(blocker_uid: str, blocked_uid: str) -> None:
        calls["block"] += 1

    monkeypatch.setattr(blocks_service, "block_user", fake_block)

    response = client.post("/api/v1/users/target-uid/block")

    assert response.status_code == 204
    assert response.content == b""
    assert calls["block"] == 1


def test_block_target_not_found_returns_404(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "blocker", "admin": False})

    async def fake_get_profile(uid: str) -> None:
        return None

    monkeypatch.setattr(users_service, "get_user_profile", fake_get_profile)

    response = client.post("/api/v1/users/ghost/block")

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "NOT_FOUND"


def test_unblock_returns_204(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "blocker", "admin": False})

    async def fake_get_profile(uid: str) -> UserProfile:
        return _sample_profile(uid=uid)

    monkeypatch.setattr(users_service, "get_user_profile", fake_get_profile)

    async def fake_unblock(blocker_uid: str, blocked_uid: str) -> None:
        return None

    monkeypatch.setattr(blocks_service, "unblock_user", fake_unblock)

    response = client.delete("/api/v1/users/target-uid/block")

    assert response.status_code == 204


def test_get_user_shows_is_blocked_true(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "viewer", "admin": False})

    async def fake_get_by_username(username: str) -> UserProfile:
        return _sample_profile(uid="target-uid", username=username)

    monkeypatch.setattr(
        users_service, "get_profile_by_username", fake_get_by_username
    )

    async def fake_is_blocked(blocker_uid: str, blocked_uid: str) -> bool:
        return True

    monkeypatch.setattr(blocks_service, "is_blocked", fake_is_blocked)

    response = client.get("/api/v1/users/target")

    assert response.status_code == 200
    assert response.json()["data"]["is_blocked"] is True
