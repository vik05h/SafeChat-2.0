# backend/tests/test_likes.py
"""Tests for like/unlike — service layer and API endpoints."""

from __future__ import annotations

from collections.abc import Iterator
from datetime import datetime, timezone
from typing import Any

import pytest
from fastapi.testclient import TestClient
from google.cloud.firestore import SERVER_TIMESTAMP as _SERVER_TIMESTAMP

from main import app
from middleware.auth import get_current_user_claims
from models.post import Post
from services import likes as likes_service
from services import posts as posts_service


# --------------------------------------------------------------------------
# In-memory Firestore fake with subcollection and batch support
# --------------------------------------------------------------------------

def _apply_transform(current: Any, value: Any) -> Any:
    """Resolve a Firestore SERVER_TIMESTAMP or Increment sentinel to a plain value."""
    if value is _SERVER_TIMESTAMP:
        return datetime.now(timezone.utc)
    if type(value).__name__ == "Increment" and hasattr(value, "value"):
        return max(0, int(current or 0) + int(value.value))
    return value


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
    def __init__(
        self,
        store: dict[str, Any],
        doc_id: str,
        path: str,
        db: _FakeDB,
    ) -> None:
        self._store = store
        self.id = doc_id
        self._path = path
        self._db = db

    def collection(self, name: str) -> _FakeCollection:
        """Return a subcollection rooted at this document."""
        subcoll_path = f"{self._path}/{self.id}/{name}"
        return self._db.collection(subcoll_path)

    def get(self) -> _FakeSnapshot:
        return _FakeSnapshot(self.id, self._store.get(self.id))

    def set(self, data: dict[str, Any]) -> None:
        self._store[self.id] = {
            k: _apply_transform(None, v) for k, v in data.items()
        }

    def update(self, data: dict[str, Any]) -> None:
        row = dict(self._store.get(self.id, {}))
        for k, v in data.items():
            row[k] = _apply_transform(row.get(k), v)
        self._store[self.id] = row

    def delete(self) -> None:
        self._store.pop(self.id, None)


class _FakeCollection:
    def __init__(
        self, store: dict[str, Any], path: str, db: _FakeDB
    ) -> None:
        self._store = store
        self._path = path
        self._db = db

    def document(self, doc_id: str) -> _FakeDocRef:
        return _FakeDocRef(self._store, doc_id, self._path, self._db)


class _FakeBatch:
    """Mirrors the WriteBatch interface used by db.batch()."""

    def __init__(self) -> None:
        self._pending: list[tuple[str, _FakeDocRef, dict[str, Any]]] = []

    def set(self, ref: _FakeDocRef, data: dict[str, Any]) -> None:
        self._pending.append(("set", ref, dict(data)))

    def update(self, ref: _FakeDocRef, data: dict[str, Any]) -> None:
        self._pending.append(("update", ref, dict(data)))

    def delete(self, ref: _FakeDocRef) -> None:
        self._pending.append(("delete", ref, {}))

    def commit(self) -> None:
        for op, ref, data in self._pending:
            if op == "set":
                ref._store[ref.id] = {
                    k: _apply_transform(None, v) for k, v in data.items()
                }
            elif op == "update":
                row = dict(ref._store.get(ref.id, {}))
                for k, v in data.items():
                    row[k] = _apply_transform(row.get(k), v)
                ref._store[ref.id] = row
            elif op == "delete":
                ref._store.pop(ref.id, None)
        self._pending.clear()


class _FakeDB:
    def __init__(self) -> None:
        self._stores: dict[str, dict[str, Any]] = {}

    def collection(self, path: str) -> _FakeCollection:
        if path not in self._stores:
            self._stores[path] = {}
        return _FakeCollection(self._stores[path], path, self)

    def batch(self) -> _FakeBatch:
        return _FakeBatch()

    @property
    def posts(self) -> dict[str, Any]:
        return self._stores.get("posts", {})

    def likes_for(self, post_id: str) -> dict[str, Any]:
        return self._stores.get(f"posts/{post_id}/likes", {})


@pytest.fixture
def fake_db(monkeypatch: pytest.MonkeyPatch) -> _FakeDB:
    db = _FakeDB()
    monkeypatch.setattr(likes_service, "db", db)
    return db


# --------------------------------------------------------------------------
# Service-layer tests
# --------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_like_post_creates_doc_and_increments(fake_db: _FakeDB) -> None:
    fake_db.collection("posts").document("post-1").set(
        {"id": "post-1", "like_count": 0}
    )

    await likes_service.like_post("user-1", "post-1")

    assert "user-1" in fake_db.likes_for("post-1")
    doc = fake_db.likes_for("post-1")["user-1"]
    assert doc["user_uid"] == "user-1"
    assert doc["post_id"] == "post-1"
    assert fake_db.posts["post-1"]["like_count"] == 1


@pytest.mark.asyncio
async def test_like_post_is_idempotent(fake_db: _FakeDB) -> None:
    fake_db.collection("posts").document("post-1").set(
        {"id": "post-1", "like_count": 0}
    )

    await likes_service.like_post("user-1", "post-1")
    await likes_service.like_post("user-1", "post-1")  # second like — no-op

    assert len(fake_db.likes_for("post-1")) == 1
    assert fake_db.posts["post-1"]["like_count"] == 1


@pytest.mark.asyncio
async def test_unlike_post_removes_doc_and_decrements(fake_db: _FakeDB) -> None:
    fake_db.collection("posts").document("post-1").set(
        {"id": "post-1", "like_count": 0}
    )
    await likes_service.like_post("user-1", "post-1")   # like_count → 1

    await likes_service.unlike_post("user-1", "post-1")  # like_count → 0

    assert fake_db.likes_for("post-1") == {}
    assert fake_db.posts["post-1"]["like_count"] == 0


@pytest.mark.asyncio
async def test_unlike_post_is_idempotent(fake_db: _FakeDB) -> None:
    # No prior like — must not raise.
    await likes_service.unlike_post("user-1", "post-1")
    assert fake_db.likes_for("post-1") == {}


@pytest.mark.asyncio
async def test_is_liked_returns_correct_bool(fake_db: _FakeDB) -> None:
    fake_db.collection("posts").document("post-1").set(
        {"id": "post-1", "like_count": 0}
    )

    assert await likes_service.is_liked("user-1", "post-1") is False
    await likes_service.like_post("user-1", "post-1")
    assert await likes_service.is_liked("user-1", "post-1") is True
    # Other user has not liked it.
    assert await likes_service.is_liked("user-2", "post-1") is False


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


def _sample_post(**overrides: Any) -> Post:
    now = datetime(2026, 5, 17, tzinfo=timezone.utc)
    base: dict[str, Any] = {
        "id": "post-abc",
        "author_uid": "uid-1",
        "text": "Hello world",
        "image_url": None,
        "status": "approved",
        "like_count": 0,
        "comment_count": 0,
        "created_at": now,
        "updated_at": now,
        "schema_version": 1,
    }
    base.update(overrides)
    return Post(**base)


def test_like_post_returns_204(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "uid-1", "admin": False})

    async def fake_get_post(post_id: str) -> Post:
        return _sample_post(id=post_id)

    monkeypatch.setattr(posts_service, "get_post", fake_get_post)

    calls: dict[str, int] = {"like": 0}

    async def fake_like(user_uid: str, post_id: str) -> None:
        calls["like"] += 1

    monkeypatch.setattr(likes_service, "like_post", fake_like)

    response = client.post("/api/v1/posts/post-abc/like")

    assert response.status_code == 204
    assert response.content == b""
    assert calls["like"] == 1


def test_unlike_post_returns_204(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "uid-1", "admin": False})

    async def fake_get_post(post_id: str) -> Post:
        return _sample_post(id=post_id)

    monkeypatch.setattr(posts_service, "get_post", fake_get_post)

    async def fake_unlike(user_uid: str, post_id: str) -> None:
        return None

    monkeypatch.setattr(likes_service, "unlike_post", fake_unlike)

    response = client.delete("/api/v1/posts/post-abc/like")

    assert response.status_code == 204
    assert response.content == b""


def test_get_post_includes_is_liked(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "uid-1", "admin": False})

    async def fake_get_post(post_id: str) -> Post:
        return _sample_post(id=post_id)

    monkeypatch.setattr(posts_service, "get_post", fake_get_post)

    async def fake_is_liked(user_uid: str, post_id: str) -> bool:
        return True

    monkeypatch.setattr(likes_service, "is_liked", fake_is_liked)

    response = client.get("/api/v1/posts/post-abc")

    assert response.status_code == 200
    assert response.json()["data"]["post"]["is_liked"] is True
