# backend/tests/test_engine.py
"""Tests for moderation.engine — the cascade orchestrator."""

from __future__ import annotations

import hashlib

import pytest

from models.moderation import KeywordVerdict, OpenAIVerdict
from moderation import engine
from moderation.engine import moderate_text


@pytest.fixture(autouse=True)
def _default_layers_clean(monkeypatch: pytest.MonkeyPatch) -> None:
    """Default both layers to clean; individual tests override as needed."""
    monkeypatch.setattr(
        engine.keyword_filter,
        "check",
        lambda text: KeywordVerdict(blocked=False),
    )

    async def fake_openai(text: str) -> OpenAIVerdict:
        return OpenAIVerdict(blocked=False)

    monkeypatch.setattr(engine, "check_with_openai", fake_openai)


@pytest.mark.asyncio
async def test_keyword_block_short_circuits_openai(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(
        engine.keyword_filter,
        "check",
        lambda text: KeywordVerdict(
            blocked=True, category="english_slurs", matched_word="idiot"
        ),
    )
    openai_calls = {"n": 0}

    async def fake_openai(text: str) -> OpenAIVerdict:
        openai_calls["n"] += 1
        return OpenAIVerdict(blocked=True, category="hate", score=0.9)

    monkeypatch.setattr(engine, "check_with_openai", fake_openai)

    result = await moderate_text("you idiot")

    assert result.blocked is True
    assert result.layer == "keyword"
    assert result.category == "english_slurs"
    assert "idiot" in (result.reason or "")
    assert openai_calls["n"] == 0


@pytest.mark.asyncio
async def test_openai_block_when_keyword_clean(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    async def fake_openai(text: str) -> OpenAIVerdict:
        return OpenAIVerdict(blocked=True, category="hate", score=0.92)

    monkeypatch.setattr(engine, "check_with_openai", fake_openai)

    result = await moderate_text("hateful but not in keywords")

    assert result.blocked is True
    assert result.layer == "openai"
    assert result.category == "hate"
    assert "0.92" in (result.reason or "")


@pytest.mark.asyncio
async def test_both_layers_clean() -> None:
    result = await moderate_text("hello world")

    assert result.blocked is False
    assert result.layer is None
    assert result.category is None
    assert result.reason is None


@pytest.mark.asyncio
async def test_empty_text_skips_all_layers(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    keyword_calls = {"n": 0}
    openai_calls = {"n": 0}

    def fake_keyword_check(text: str) -> KeywordVerdict:
        keyword_calls["n"] += 1
        return KeywordVerdict(blocked=False)

    monkeypatch.setattr(engine.keyword_filter, "check", fake_keyword_check)

    async def fake_openai(text: str) -> OpenAIVerdict:
        openai_calls["n"] += 1
        return OpenAIVerdict(blocked=False)

    monkeypatch.setattr(engine, "check_with_openai", fake_openai)

    for text in ["", "   ", "\n\t"]:
        result = await moderate_text(text)
        assert result.blocked is False

    assert keyword_calls["n"] == 0
    assert openai_calls["n"] == 0


@pytest.mark.asyncio
async def test_latency_ms_populated() -> None:
    result = await moderate_text("any text")
    assert result.latency_ms is not None
    assert result.latency_ms >= 0


@pytest.mark.asyncio
async def test_content_hash_matches_sha256() -> None:
    text = "hash me please"
    expected = hashlib.sha256(text.encode("utf-8")).hexdigest()

    result = await moderate_text(text)

    assert result.content_hash == expected


@pytest.mark.asyncio
async def test_content_hash_populated_for_empty_text() -> None:
    expected = hashlib.sha256(b"").hexdigest()
    result = await moderate_text("")
    assert result.content_hash == expected


@pytest.mark.asyncio
async def test_layer_latencies_recorded_when_both_run() -> None:
    result = await moderate_text("clean text")

    assert result.layer_latencies is not None
    assert "keyword" in result.layer_latencies
    assert "openai" in result.layer_latencies
    assert result.layer_latencies["keyword"] >= 0
    assert result.layer_latencies["openai"] >= 0


@pytest.mark.asyncio
async def test_layer_latencies_omit_skipped_openai(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """When keyword blocks, the openai layer shouldn't have a latency entry."""
    monkeypatch.setattr(
        engine.keyword_filter,
        "check",
        lambda text: KeywordVerdict(
            blocked=True, category="threats", matched_word="kill you"
        ),
    )

    result = await moderate_text("i will kill you")

    assert result.layer_latencies is not None
    assert "keyword" in result.layer_latencies
    assert "openai" not in result.layer_latencies
