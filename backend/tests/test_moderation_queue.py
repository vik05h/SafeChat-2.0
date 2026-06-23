# backend/tests/test_moderation_queue.py
"""Tests for services.moderation_queue.build_item (pure payload builder)."""

from __future__ import annotations

from google.cloud.firestore import SERVER_TIMESTAMP

from models.moderation import Match, ModerationResult
from services import moderation_queue


def _result() -> ModerationResult:
    return ModerationResult(
        blocked=True,
        layer="keyword",
        category="english_slurs",
        reason="keyword match: idiot",
        matches=[
            Match(term="idiot", category="english_slurs", weight=0.5, start=8, end=13),
            Match(term="loser", category="english_slurs", weight=0.5, start=20, end=25),
            Match(term="idiot", category="english_slurs", weight=0.5, start=30, end=35),
        ],
        lexicon_score=1.5,
    )


def test_build_item_for_post() -> None:
    queue_id, payload = moderation_queue.build_item(
        content_type="post",
        content_id="post-1",
        author_uid="uid-1",
        author_username="alice",
        text="you are idiot and loser idiot",
        result=_result(),
    )

    assert payload["id"] == queue_id
    assert payload["content_type"] == "post"
    assert payload["content_id"] == "post-1"
    assert payload["author_uid"] == "uid-1"
    assert payload["author_username"] == "alice"
    assert payload["status"] == "pending_review"
    assert payload["post_id"] is None
    assert payload["chat_id"] is None
    # flagged_terms de-duplicated, first-seen order preserved
    assert payload["flagged_terms"] == ["idiot", "loser"]
    assert payload["categories"] == ["english_slurs"]
    assert payload["lexicon_score"] == 1.5
    assert len(payload["matches"]) == 3
    assert payload["matches"][0]["term"] == "idiot"
    assert payload["created_at"] is SERVER_TIMESTAMP
    assert payload["resolved_at"] is None
    assert payload["resolved_by"] is None


def test_build_item_for_comment_sets_post_id() -> None:
    _, payload = moderation_queue.build_item(
        content_type="comment",
        content_id="c-1",
        author_uid="uid-1",
        author_username="alice",
        text="idiot",
        result=_result(),
        post_id="post-9",
    )
    assert payload["content_type"] == "comment"
    assert payload["post_id"] == "post-9"
    assert payload["chat_id"] is None


def test_build_item_for_message_sets_chat_id() -> None:
    _, payload = moderation_queue.build_item(
        content_type="message",
        content_id="m-1",
        author_uid="uid-1",
        author_username="alice",
        text="idiot",
        result=_result(),
        chat_id="uid-1_uid-2",
    )
    assert payload["content_type"] == "message"
    assert payload["chat_id"] == "uid-1_uid-2"
    assert payload["post_id"] is None
