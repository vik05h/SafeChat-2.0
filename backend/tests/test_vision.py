# backend/tests/test_vision.py
"""Tests for Google Cloud Vision SafeSearch moderation."""

from __future__ import annotations

from types import SimpleNamespace
from typing import Any

import pytest

import moderation.vision as vision_module
from moderation import engine as engine_module
from moderation.vision import check_image_with_vision
from google.cloud.vision import Likelihood


# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

def _make_response(
    adult: Likelihood = Likelihood.VERY_UNLIKELY,
    violence: Likelihood = Likelihood.VERY_UNLIKELY,
    racy: Likelihood = Likelihood.VERY_UNLIKELY,
) -> Any:
    """Build a minimal fake Vision API response."""
    return SimpleNamespace(
        safe_search_annotation=SimpleNamespace(
            adult=adult,
            violence=violence,
            racy=racy,
        )
    )


# --------------------------------------------------------------------------
# Vision module tests
# --------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_vision_blocks_adult_likelihood(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(
        vision_module, "_annotate", lambda url: _make_response(adult=Likelihood.LIKELY)
    )
    monkeypatch.setattr(vision_module, "_VISION_ENABLED", True)

    verdict = await check_image_with_vision("https://example.com/img.jpg")

    assert verdict.blocked is True
    assert verdict.category == "adult"


@pytest.mark.asyncio
async def test_vision_blocks_violence_likelihood(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(
        vision_module,
        "_annotate",
        lambda url: _make_response(violence=Likelihood.LIKELY),
    )
    monkeypatch.setattr(vision_module, "_VISION_ENABLED", True)

    verdict = await check_image_with_vision("https://example.com/img.jpg")

    assert verdict.blocked is True
    assert verdict.category == "violence"


@pytest.mark.asyncio
async def test_vision_blocks_racy_very_likely_only(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """VERY_LIKELY blocks; LIKELY alone must NOT block for the racy category."""
    monkeypatch.setattr(vision_module, "_VISION_ENABLED", True)

    # VERY_LIKELY should block
    monkeypatch.setattr(
        vision_module,
        "_annotate",
        lambda url: _make_response(racy=Likelihood.VERY_LIKELY),
    )
    verdict_vl = await check_image_with_vision("https://example.com/img.jpg")
    assert verdict_vl.blocked is True
    assert verdict_vl.category == "racy"

    # LIKELY alone should NOT block
    monkeypatch.setattr(
        vision_module,
        "_annotate",
        lambda url: _make_response(racy=Likelihood.LIKELY),
    )
    verdict_l = await check_image_with_vision("https://example.com/img.jpg")
    assert verdict_l.blocked is False


@pytest.mark.asyncio
async def test_vision_passes_below_thresholds(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(
        vision_module,
        "_annotate",
        lambda url: _make_response(
            adult=Likelihood.POSSIBLE,
            violence=Likelihood.POSSIBLE,
            racy=Likelihood.LIKELY,
        ),
    )
    monkeypatch.setattr(vision_module, "_VISION_ENABLED", True)

    verdict = await check_image_with_vision("https://example.com/img.jpg")

    assert verdict.blocked is False
    assert verdict.skipped is False
    assert verdict.error is False


@pytest.mark.asyncio
async def test_vision_skipped_when_not_configured(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(vision_module, "_VISION_ENABLED", False)

    verdict = await check_image_with_vision("https://example.com/img.jpg")

    assert verdict.blocked is False
    assert verdict.skipped is True


@pytest.mark.asyncio
async def test_vision_error_on_api_exception(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    def _raise(url: str) -> None:
        raise RuntimeError("quota exceeded")

    monkeypatch.setattr(vision_module, "_annotate", _raise)
    monkeypatch.setattr(vision_module, "_VISION_ENABLED", True)

    verdict = await check_image_with_vision("https://example.com/img.jpg")

    assert verdict.blocked is False
    assert verdict.error is True


# --------------------------------------------------------------------------
# Engine-layer test
# --------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_moderate_image_returns_result_with_vision_layer(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    from models.moderation import VisionVerdict

    async def fake_check(image_url: str) -> VisionVerdict:
        return VisionVerdict(blocked=True, category="adult")

    monkeypatch.setattr(engine_module, "check_image_with_vision", fake_check)

    result = await engine_module.moderate_image("https://example.com/img.jpg")

    assert result.blocked is True
    assert result.layer == "vision"
    assert result.category == "adult"
    assert result.reason == "vision safeSearch: adult"
    assert result.latency_ms is not None
    assert "vision" in (result.layer_latencies or {})
