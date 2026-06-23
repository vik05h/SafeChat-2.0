# backend/moderation/tfidf_model.py
"""Layer 2 of the moderation cascade — the trained TF-IDF classifier.

A scikit-learn ``Pipeline(TfidfVectorizer -> LogisticRegression)`` trained by
``moderation/train_model.py`` on ``moderation/data/seed_corpus.csv`` and
serialised to ``moderation/data/model.pkl``.

Where it runs: **server-side only** (FastAPI / Cloud Run). The model is loaded
once, lazily, into process memory; inference is a few milliseconds. Nothing
ships to the client.

Fail-open by design: if the artifact is missing, or scikit-learn/joblib are not
installed, or scoring raises, :func:`score` returns ``None`` ("no opinion") and
the engine simply falls through to the next layer. This lets the rest of the
feature ship and run before/without the model being present.
"""

from __future__ import annotations

import logging
import threading
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)

MODEL_PATH = Path(__file__).resolve().parent / "data" / "model.pkl"

_model: Any | None = None
_loaded: bool = False
_lock = threading.Lock()


def _load() -> None:
    """Load the model artifact once. Thread-safe and fail-open."""
    global _model, _loaded
    if _loaded:
        return
    with _lock:
        if _loaded:
            return
        try:
            import joblib  # imported lazily so the module works without sklearn

            if MODEL_PATH.is_file():
                _model = joblib.load(MODEL_PATH)
                logger.info("TF-IDF model loaded from %s", MODEL_PATH)
            else:
                logger.warning(
                    "TF-IDF model artifact missing at %s — Layer 2 inert "
                    "(run `python -m moderation.train_model`).",
                    MODEL_PATH,
                )
        except Exception:  # pragma: no cover - defensive, fail-open
            logger.warning("Failed to load TF-IDF model — Layer 2 inert", exc_info=True)
            _model = None
        finally:
            _loaded = True


def score(text: str) -> float | None:
    """Return P(toxic) in ``[0, 1]`` for ``text``, or ``None`` if unavailable.

    ``None`` means the layer has no opinion (model absent / load or inference
    failure / blank input) and the caller should ignore Layer 2.
    """
    if not text or not text.strip():
        return None

    _load()
    if _model is None:
        return None

    try:
        proba = _model.predict_proba([text])[0]
        classes = list(getattr(_model, "classes_", []))
        # Probability of the positive (toxic == 1) class.
        idx = classes.index(1) if 1 in classes else len(proba) - 1
        return float(proba[idx])
    except Exception:  # pragma: no cover - defensive, fail-open
        logger.warning("TF-IDF scoring failed — treating as no-opinion", exc_info=True)
        return None


def reset_for_tests() -> None:
    """Clear the cached model so tests can re-exercise the lazy loader."""
    global _model, _loaded
    with _lock:
        _model = None
        _loaded = False
