# backend/tests/test_tfidf_model.py
"""Tests for moderation.tfidf_model — the trained Layer 2 classifier wrapper."""

from __future__ import annotations

from pathlib import Path

import pytest

from moderation import tfidf_model


@pytest.fixture(autouse=True)
def _reset_model_cache() -> None:
    tfidf_model.reset_for_tests()
    yield
    tfidf_model.reset_for_tests()


def test_blank_text_returns_none() -> None:
    assert tfidf_model.score("") is None
    assert tfidf_model.score("   ") is None


def test_missing_artifact_is_fail_open(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    monkeypatch.setattr(tfidf_model, "MODEL_PATH", tmp_path / "absent.pkl")
    tfidf_model.reset_for_tests()
    assert tfidf_model.score("you are worthless") is None


def test_scores_in_unit_range_when_model_present() -> None:
    if not tfidf_model.MODEL_PATH.is_file():
        pytest.skip("model.pkl not trained in this environment")
    pytest.importorskip("sklearn")

    result = tfidf_model.score("you are a worthless waste of space")
    assert result is not None
    assert 0.0 <= result <= 1.0


def test_toxic_scores_higher_than_clean() -> None:
    if not tfidf_model.MODEL_PATH.is_file():
        pytest.skip("model.pkl not trained in this environment")
    pytest.importorskip("sklearn")

    toxic = tfidf_model.score("you are a worthless waste of space nobody wants you here")
    clean = tfidf_model.score("thanks so much for helping me with the project today")
    assert toxic is not None
    assert clean is not None
    assert toxic > clean
