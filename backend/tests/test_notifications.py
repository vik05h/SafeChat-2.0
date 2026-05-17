# backend/tests/test_notifications.py
"""Tests for the FCM push notification service."""

from __future__ import annotations

from typing import Any

import pytest

import services.notifications as notifications_module
from services.notifications import send_message_notification


# --------------------------------------------------------------------------
# Minimal Firestore fake — only needs collection/document/get
# --------------------------------------------------------------------------

class _FakeSnapshot:
    def __init__(self, data: dict[str, Any] | None) -> None:
        self._data = data

    @property
    def exists(self) -> bool:
        return self._data is not None

    def to_dict(self) -> dict[str, Any] | None:
        return dict(self._data) if self._data is not None else None


class _FakeDocRef:
    def __init__(self, data: dict[str, Any] | None) -> None:
        self._data = data

    def get(self) -> _FakeSnapshot:
        return _FakeSnapshot(self._data)


class _FakeCollection:
    def __init__(self, store: dict[str, Any]) -> None:
        self._store = store

    def document(self, doc_id: str) -> _FakeDocRef:
        return _FakeDocRef(self._store.get(doc_id))


class _FakeDB:
    def __init__(self, stores: dict[str, dict[str, Any]] | None = None) -> None:
        self._stores = stores or {}

    def collection(self, name: str) -> _FakeCollection:
        return _FakeCollection(self._stores.get(name, {}))


# --------------------------------------------------------------------------
# Tests
# --------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_sends_fcm_when_token_exists(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    fake_db = _FakeDB({"fcm_tokens": {"uid-2": {"token": "fcm-device-token"}}})
    monkeypatch.setattr(notifications_module, "db", fake_db)

    sent: list[Any] = []

    def fake_send_fcm(msg: Any) -> None:
        sent.append(msg)

    monkeypatch.setattr(notifications_module, "_send_fcm", fake_send_fcm)

    await send_message_notification("uid-2", "Alice", "Hello!", "uid-1_uid-2")

    assert len(sent) == 1
    assert sent[0].token == "fcm-device-token"
    assert sent[0].notification.title == "Alice"
    assert sent[0].notification.body == "Hello!"
    assert sent[0].data == {"chat_id": "uid-1_uid-2", "type": "new_message"}


@pytest.mark.asyncio
async def test_skips_when_no_token_found(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """When the fcm_tokens doc does not exist no FCM call should be made."""
    fake_db = _FakeDB({"fcm_tokens": {}})
    monkeypatch.setattr(notifications_module, "db", fake_db)

    sent: list[Any] = []

    def fake_send_fcm(msg: Any) -> None:
        sent.append(msg)

    monkeypatch.setattr(notifications_module, "_send_fcm", fake_send_fcm)

    await send_message_notification("uid-2", "Alice", "Hello!", "uid-1_uid-2")

    assert len(sent) == 0


@pytest.mark.asyncio
async def test_fails_open_on_fcm_error(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """An FCM send failure must be swallowed — no exception propagated."""
    fake_db = _FakeDB({"fcm_tokens": {"uid-2": {"token": "fcm-device-token"}}})
    monkeypatch.setattr(notifications_module, "db", fake_db)

    def fake_send_fcm(msg: Any) -> None:
        raise RuntimeError("FCM quota exceeded")

    monkeypatch.setattr(notifications_module, "_send_fcm", fake_send_fcm)

    # Must not raise.
    await send_message_notification("uid-2", "Alice", "Hello!", "uid-1_uid-2")


@pytest.mark.asyncio
async def test_message_text_truncated_to_100_chars(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Notification body must be capped at 100 characters regardless of input length."""
    long_text = "a" * 200
    fake_db = _FakeDB({"fcm_tokens": {"uid-2": {"token": "tok"}}})
    monkeypatch.setattr(notifications_module, "db", fake_db)

    sent: list[Any] = []

    def fake_send_fcm(msg: Any) -> None:
        sent.append(msg)

    monkeypatch.setattr(notifications_module, "_send_fcm", fake_send_fcm)

    await send_message_notification("uid-2", "Alice", long_text, "uid-1_uid-2")

    assert len(sent) == 1
    assert sent[0].notification.body == "a" * 100
    assert len(sent[0].notification.body) == 100
