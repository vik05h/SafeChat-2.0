# backend/tests/test_comments.py
"""Tests for comments — service layer and API endpoints."""

from __future__ import annotations

from collections.abc import Iterator
from datetime import datetime, timezone
from typing import Any

import pytest
from fastapi.testclient import TestClient
from google.cloud.firestore import SERVER_TIMESTAMP as _SERVER_TIMESTAMP

from main import app
from middleware.auth import get_current_user_claims
from models.comment import Comment
from models.moderation import ModerationResult
from services import comments as comments_service
from services import likes as likes_service


# --------------------------------------------------------------------------
# In-memory Firestore fake with subcollection, query, and batch support
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


class _FakeQuery:
    """Chainable query object — applies sort/limit at stream() time."""

    def __init__(self, store: dict[str, Any]) -> None:
        self._store = store
        self._order_field: str | None = None
        self._order_desc: bool = False
        self._limit_n: int | None = None

    def order_by(self, field: str, direction: Any = None) -> "_FakeQuery":
        self._order_field = field
        if direction is not None:
            self._order_desc = str(direction) == "DESCENDING"
        return self

    def where(self, filter: Any = None, **kwargs: Any) -> "_FakeQuery":  # noqa: A002
        # Filtering not needed for these tests — all seeded data is in range.
        return self

    def limit(self, n: int) -> "_FakeQuery":
        self._limit_n = n
        return self

    def stream(self) -> list[_FakeSnapshot]:
        items = list(self._store.items())
        if self._order_field:
            items.sort(
                key=lambda kv: kv[1].get(self._order_field) or "",
                reverse=self._order_desc,
            )
        snaps = [_FakeSnapshot(k, v) for k, v in items]
        if self._limit_n is not None:
            snaps = snaps[: self._limit_n]
        return snaps


class _FakeDocRef:
    def __init__(
        self,
        store: dict[str, Any],
        doc_id: str,
        path: str,
        db: "_FakeDB",
    ) -> None:
        self._store = store
        self.id = doc_id
        self._path = path
        self._db = db

    def collection(self, name: str) -> "_FakeCollection":
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
        self, store: dict[str, Any], path: str, db: "_FakeDB"
    ) -> None:
        self._store = store
        self._path = path
        self._db = db

    def document(self, doc_id: str) -> _FakeDocRef:
        return _FakeDocRef(self._store, doc_id, self._path, self._db)

    def order_by(self, field: str, direction: Any = None) -> _FakeQuery:
        return _FakeQuery(self._store).order_by(field, direction)

    def where(self, filter: Any = None, **kwargs: Any) -> _FakeQuery:  # noqa: A002
        return _FakeQuery(self._store).where(filter, **kwargs)

    def limit(self, n: int) -> _FakeQuery:
        return _FakeQuery(self._store).limit(n)

    def stream(self) -> list[_FakeSnapshot]:
        return [_FakeSnapshot(k, v) for k, v in self._store.items()]


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

    def comments_for(self, post_id: str) -> dict[str, Any]:
        return self._stores.get(f"posts/{post_id}/comments", {})


@pytest.fixture
def fake_db(monkeypatch: pytest.MonkeyPatch) -> _FakeDB:
    db = _FakeDB()
    monkeypatch.setattr(comments_service, "db", db)
    return db


# --------------------------------------------------------------------------
# Service-layer tests
# --------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_create_comment_returns_comment(
    fake_db: _FakeDB, monkeypatch: pytest.MonkeyPatch
) -> None:
    fake_db.collection("posts").document("post-1").set(
        {"id": "post-1", "comment_count": 0}
    )

    async def fake_moderate(text: str) -> ModerationResult:
        return ModerationResult(blocked=False, content_hash="h")

    monkeypatch.setattr(comments_service, "moderate_text", fake_moderate)

    comment = await comments_service.create_comment("post-1", "uid-1", "Hello!")

    assert isinstance(comment, Comment)
    assert comment.post_id == "post-1"
    assert comment.author_uid == "uid-1"
    assert comment.text == "Hello!"
    assert comment.schema_version == 1


@pytest.mark.asyncio
async def test_create_comment_increments_post_comment_count(
    fake_db: _FakeDB, monkeypatch: pytest.MonkeyPatch
) -> None:
    fake_db.collection("posts").document("post-1").set(
        {"id": "post-1", "comment_count": 0}
    )

    async def fake_moderate(text: str) -> ModerationResult:
        return ModerationResult(blocked=False, content_hash="h")

    monkeypatch.setattr(comments_service, "moderate_text", fake_moderate)

    await comments_service.create_comment("post-1", "uid-1", "Hello!")

    assert fake_db.posts["post-1"]["comment_count"] == 1
    assert len(fake_db.comments_for("post-1")) == 1


@pytest.mark.asyncio
async def test_create_comment_blocked_raises(
    fake_db: _FakeDB, monkeypatch: pytest.MonkeyPatch
) -> None:
    fake_db.collection("posts").document("post-1").set(
        {"id": "post-1", "comment_count": 0}
    )

    async def fake_moderate(text: str) -> ModerationResult:
        return ModerationResult(
            blocked=True,
            layer="keyword",
            category="slurs",
            reason="keyword match",
            content_hash="h",
        )

    monkeypatch.setattr(comments_service, "moderate_text", fake_moderate)

    with pytest.raises(comments_service.CommentBlocked) as exc_info:
        await comments_service.create_comment("post-1", "uid-1", "toxic text")

    assert exc_info.value.layer == "keyword"
    # Nothing written — count must be unchanged.
    assert fake_db.posts["post-1"]["comment_count"] == 0


@pytest.mark.asyncio
async def test_create_comment_on_missing_post_raises(
    fake_db: _FakeDB,
) -> None:
    # No post seeded — PostNotFound is raised before moderation runs.
    with pytest.raises(comments_service.PostNotFound):
        await comments_service.create_comment("nonexistent-post", "uid-1", "Hello!")


@pytest.mark.asyncio
async def test_get_comments_returns_list_ordered_by_created_at(
    fake_db: _FakeDB,
) -> None:
    t1 = datetime(2026, 1, 1, 10, 0, tzinfo=timezone.utc)
    t2 = datetime(2026, 1, 1, 11, 0, tzinfo=timezone.utc)
    t3 = datetime(2026, 1, 1, 12, 0, tzinfo=timezone.utc)

    # Seed in intentionally scrambled order to confirm sort is applied.
    for cid, t in [("c3", t3), ("c1", t1), ("c2", t2)]:
        fake_db.collection("posts/post-1/comments").document(cid).set(
            {
                "id": cid,
                "post_id": "post-1",
                "author_uid": "uid-1",
                "text": f"comment {cid}",
                "created_at": t,
                "updated_at": t,
                "schema_version": 1,
            }
        )

    comments = await comments_service.get_comments("post-1")

    assert len(comments) == 3
    assert comments[0].id == "c1"
    assert comments[1].id == "c2"
    assert comments[2].id == "c3"


@pytest.mark.asyncio
async def test_delete_comment_raises_not_authorized(fake_db: _FakeDB) -> None:
    fake_db.collection("posts").document("post-1").set(
        {"id": "post-1", "comment_count": 1}
    )
    fake_db.collection("posts/post-1/comments").document("c-1").set(
        {
            "id": "c-1",
            "post_id": "post-1",
            "author_uid": "alice",
            "text": "Hello",
            "created_at": datetime(2026, 1, 1, tzinfo=timezone.utc),
            "updated_at": datetime(2026, 1, 1, tzinfo=timezone.utc),
            "schema_version": 1,
        }
    )

    with pytest.raises(comments_service.NotAuthorized):
        await comments_service.delete_comment("post-1", "c-1", requesting_uid="bob")

    # Comment and count must be unchanged.
    assert "c-1" in fake_db.comments_for("post-1")
    assert fake_db.posts["post-1"]["comment_count"] == 1


@pytest.mark.asyncio
async def test_delete_comment_decrements_post_comment_count(
    fake_db: _FakeDB,
) -> None:
    fake_db.collection("posts").document("post-1").set(
        {"id": "post-1", "comment_count": 1}
    )
    fake_db.collection("posts/post-1/comments").document("c-1").set(
        {
            "id": "c-1",
            "post_id": "post-1",
            "author_uid": "alice",
            "text": "Hello",
            "created_at": datetime(2026, 1, 1, tzinfo=timezone.utc),
            "updated_at": datetime(2026, 1, 1, tzinfo=timezone.utc),
            "schema_version": 1,
        }
    )

    await comments_service.delete_comment("post-1", "c-1", requesting_uid="alice")

    assert "c-1" not in fake_db.comments_for("post-1")
    assert fake_db.posts["post-1"]["comment_count"] == 0


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


@pytest.fixture(autouse=True)
def _default_is_liked_false(monkeypatch: pytest.MonkeyPatch) -> None:
    """Default: viewer has not liked any post."""

    async def fake_is_liked(user_uid: str, post_id: str) -> bool:
        return False

    monkeypatch.setattr(likes_service, "is_liked", fake_is_liked)


def _override_claims(claims: dict[str, Any]) -> None:
    async def fake_claims() -> dict[str, Any]:
        return claims

    app.dependency_overrides[get_current_user_claims] = fake_claims


def _sample_comment(**overrides: Any) -> Comment:
    now = datetime(2026, 5, 17, tzinfo=timezone.utc)
    base: dict[str, Any] = {
        "id": "comment-abc",
        "post_id": "post-abc",
        "author_uid": "uid-1",
        "text": "Nice post!",
        "created_at": now,
        "updated_at": now,
        "schema_version": 1,
    }
    base.update(overrides)
    return Comment(**base)


def test_post_comment_returns_201(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "uid-1", "admin": False})

    async def fake_create(post_id: str, author_uid: str, text: str) -> Comment:
        return _sample_comment(post_id=post_id, author_uid=author_uid, text=text)

    monkeypatch.setattr(comments_service, "create_comment", fake_create)

    response = client.post(
        "/api/v1/posts/post-abc/comments", json={"text": "Nice post!"}
    )

    assert response.status_code == 201
    data = response.json()["data"]["comment"]
    assert data["post_id"] == "post-abc"
    assert data["author_uid"] == "uid-1"
    assert data["text"] == "Nice post!"


def test_post_comment_toxic_text_returns_422(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "uid-1", "admin": False})

    async def fake_create(post_id: str, author_uid: str, text: str) -> Comment:
        raise comments_service.CommentBlocked(layer="keyword", reason="blocked")

    monkeypatch.setattr(comments_service, "create_comment", fake_create)

    response = client.post(
        "/api/v1/posts/post-abc/comments", json={"text": "toxic content"}
    )

    assert response.status_code == 422
    body = response.json()
    assert body["error"]["code"] == "MODERATION_BLOCKED"
    assert body["error"]["field"] == "text"


def test_get_comments_returns_200_with_list(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "uid-1", "admin": False})

    async def fake_get_comments(
        post_id: str,
        limit: int = 20,
        before_created_at: str | None = None,
    ) -> list[Comment]:
        return [
            _sample_comment(id="c1", text="first"),
            _sample_comment(id="c2", text="second"),
        ]

    monkeypatch.setattr(comments_service, "get_comments", fake_get_comments)

    response = client.get("/api/v1/posts/post-abc/comments")

    assert response.status_code == 200
    comments = response.json()["data"]["comments"]
    assert len(comments) == 2
    assert comments[0]["id"] == "c1"


def test_delete_comment_returns_204(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "uid-1", "admin": False})

    async def fake_delete(
        post_id: str,
        comment_id: str,
        requesting_uid: str,
        is_admin: bool = False,
    ) -> None:
        return None

    monkeypatch.setattr(comments_service, "delete_comment", fake_delete)

    response = client.delete("/api/v1/posts/post-abc/comments/comment-abc")

    assert response.status_code == 204
    assert response.content == b""


def test_delete_comment_returns_403_for_non_author(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    _override_claims({"uid": "uid-other", "admin": False})

    async def fake_delete(
        post_id: str,
        comment_id: str,
        requesting_uid: str,
        is_admin: bool = False,
    ) -> None:
        raise comments_service.NotAuthorized(requesting_uid)

    monkeypatch.setattr(comments_service, "delete_comment", fake_delete)

    response = client.delete("/api/v1/posts/post-abc/comments/comment-abc")

    assert response.status_code == 403
    assert response.json()["error"]["code"] == "FORBIDDEN"
