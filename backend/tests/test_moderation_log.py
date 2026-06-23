# backend/tests/test_moderation_log.py
"""Tests for services.moderation_log."""

from __future__ import annotations

from typing import Any
from unittest.mock import MagicMock

import pytest

from models.moderation import ModerationResult
from services import moderation_log
from services.moderation_log import log_moderation_decision


@pytest.fixture
def captured_add(monkeypatch: pytest.MonkeyPatch) -> MagicMock:
    """Replace `db.collection(...).add(...)` with a capturing mock."""
    mock_add = MagicMock()
    mock_collection = MagicMock()
    mock_collection.add = mock_add

    mock_db = MagicMock()
    mock_db.collection.return_value = mock_collection

    monkeypatch.setattr(moderation_log, "db", mock_db)
    return mock_add


@pytest.mark.asyncio
async def test_writes_approved_log(captured_add: MagicMock) -> None:
    result = ModerationResult(
        blocked=False,
        latency_ms=15.0,
        layer_latencies={"keyword": 0.5, "openai": 14.0},
        content_hash="abc",
    )

    await log_moderation_decision(
        result=result,
        content_type="message",
        content_id="msg-123",
        author_uid="user-456",
    )

    assert captured_add.call_count == 1
    payload: dict[str, Any] = captured_add.call_args.args[0]
    assert payload["verdict"] == "approved"
    assert payload["content_hash"] == "abc"
    assert payload["content_type"] == "message"
    assert payload["content_id"] == "msg-123"
    assert payload["author_uid"] == "user-456"
    assert payload["layer_triggered"] is None
    assert payload["category"] is None
    assert payload["total_latency_ms"] == 15.0


@pytest.mark.asyncio
async def test_writes_blocked_log(captured_add: MagicMock) -> None:
    result = ModerationResult(
        blocked=True,
        layer="keyword",
        category="english_slurs",
        reason="keyword match: idiot",
        latency_ms=0.5,
        layer_latencies={"keyword": 0.5},
        content_hash="hash",
    )

    await log_moderation_decision(
        result=result,
        content_type="post",
        content_id="post-1",
        author_uid="user-1",
    )

    payload = captured_add.call_args.args[0]
    assert payload["verdict"] == "blocked"
    assert payload["layer_triggered"] == "keyword"
    assert payload["category"] == "english_slurs"


@pytest.mark.asyncio
async def test_api_latencies_suffixed_with_ms(captured_add: MagicMock) -> None:
    result = ModerationResult(
        blocked=False,
        latency_ms=15.0,
        layer_latencies={"keyword": 0.5, "openai": 14.0},
        content_hash="abc",
    )

    await log_moderation_decision(
        result=result,
        content_type="message",
        content_id=None,
        author_uid="u",
    )

    payload = captured_add.call_args.args[0]
    assert payload["api_latencies"]["keyword_ms"] == 0.5
    assert payload["api_latencies"]["openai_ms"] == 14.0
    assert payload["api_latencies"]["gemini_ms"] is None
    assert payload["api_latencies"]["vision_ms"] is None


@pytest.mark.asyncio
async def test_firestore_failure_does_not_raise(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    def boom(payload: dict[str, Any]) -> None:
        raise RuntimeError("firestore down")

    monkeypatch.setattr(moderation_log, "_write_log", boom)

    result = ModerationResult(blocked=False, content_hash="x")

    # Must not raise — fail-open.
    await log_moderation_decision(
        result=result,
        content_type="test",
        content_id=None,
        author_uid="u",
    )


@pytest.mark.asyncio
async def test_empty_layer_latencies_handled(captured_add: MagicMock) -> None:
    result = ModerationResult(
        blocked=False,
        latency_ms=0.0,
        layer_latencies={},
        content_hash="x",
    )

    await log_moderation_decision(
        result=result,
        content_type="test",
        content_id=None,
        author_uid="u",
    )

    payload = captured_add.call_args.args[0]
    assert payload["api_latencies"] == {
        "keyword_ms": None,
        "tfidf_ms": None,
        "openai_ms": None,
        "gemini_ms": None,
        "vision_ms": None,
    }


@pytest.mark.asyncio
async def test_none_layer_latencies_handled(captured_add: MagicMock) -> None:
    """layer_latencies=None (not just empty dict) should also be handled."""
    result = ModerationResult(blocked=False, content_hash="x", latency_ms=0.0)

    await log_moderation_decision(
        result=result,
        content_type="test",
        content_id=None,
        author_uid="u",
    )

    payload = captured_add.call_args.args[0]
    assert payload["api_latencies"]["keyword_ms"] is None
    assert payload["api_latencies"]["openai_ms"] is None
