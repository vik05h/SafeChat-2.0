# backend/tests/test_moderation_review.py
"""Tests for services.moderation_review — approve/reject orchestration."""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Any

import pytest

from models.moderation import ModerationQueueItem
from services import moderation_review


def _item(
    content_type: str = "post", status: str = "pending_review", **kw: Any
) -> ModerationQueueItem:
    base: dict[str, Any] = {
        "id": "q1",
        "content_type": content_type,
        "content_id": "c1",
        "author_uid": "uid-1",
        "text": "bad words",
        "status": status,
        "created_at": datetime(2026, 6, 1, tzinfo=UTC),
    }
    base.update(kw)
    return ModerationQueueItem(**base)


@pytest.fixture
def captured(monkeypatch: pytest.MonkeyPatch) -> dict[str, list[Any]]:
    """Patch the content-service / queue / notification seams the orchestrator
    calls, and record the calls. ``get`` returns the (mutating) current item."""
    calls: dict[str, list[Any]] = {"apply": [], "resolved": [], "notify": []}
    state = {"item": _item()}

    async def fake_get(queue_id: str) -> ModerationQueueItem:
        return state["item"]

    async def fake_set_post(post_id: str, status: str, reason: str | None = None) -> None:
        calls["apply"].append(("post", post_id, status, reason))

    async def fake_mark_resolved(
        queue_id: str, status: str, resolver_uid: str, reason: str | None = None
    ) -> None:
        calls["resolved"].append((queue_id, status, resolver_uid, reason))
        state["item"] = _item(status=status, reason=reason)

    async def fake_notify(uid: str, **kwargs: Any) -> None:
        calls["notify"].append((uid, kwargs))

    monkeypatch.setattr(moderation_review.moderation_queue, "get", fake_get)
    monkeypatch.setattr(moderation_review.posts_service, "set_post_status", fake_set_post)
    monkeypatch.setattr(moderation_review.moderation_queue, "mark_resolved", fake_mark_resolved)
    monkeypatch.setattr(moderation_review.notifications_service, "create_notification", fake_notify)
    return calls


@pytest.mark.asyncio
async def test_approve_publishes_resolves_and_notifies(captured: dict[str, list[Any]]) -> None:
    result = await moderation_review.approve("q1", "admin-1")

    assert ("post", "c1", "approved", None) in captured["apply"]
    assert ("q1", "approved", "admin-1", None) in captured["resolved"]
    assert captured["notify"][0][0] == "uid-1"
    assert captured["notify"][0][1]["notification_type"] == "appeal_update"
    assert result.status == "approved"


@pytest.mark.asyncio
async def test_reject_hides_with_reason_and_notifies(captured: dict[str, list[Any]]) -> None:
    result = await moderation_review.reject("q1", "admin-1", "Contains a slur")

    assert ("post", "c1", "rejected", "Contains a slur") in captured["apply"]
    assert ("q1", "rejected", "admin-1", "Contains a slur") in captured["resolved"]
    assert result.status == "rejected"
    # the rejection reason is surfaced to the author in the notification body
    assert "Contains a slur" in captured["notify"][0][1]["body"]


@pytest.mark.asyncio
async def test_approve_missing_item_raises(monkeypatch: pytest.MonkeyPatch) -> None:
    async def fake_get(queue_id: str) -> None:
        return None

    monkeypatch.setattr(moderation_review.moderation_queue, "get", fake_get)
    with pytest.raises(moderation_review.QueueItemNotFound):
        await moderation_review.approve("missing", "admin-1")


@pytest.mark.asyncio
async def test_decide_on_already_resolved_raises(monkeypatch: pytest.MonkeyPatch) -> None:
    async def fake_get(queue_id: str) -> ModerationQueueItem:
        return _item(status="approved")

    monkeypatch.setattr(moderation_review.moderation_queue, "get", fake_get)
    with pytest.raises(moderation_review.AlreadyResolved):
        await moderation_review.reject("q1", "admin-1", "too late")
