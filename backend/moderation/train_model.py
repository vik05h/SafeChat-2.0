# backend/moderation/train_model.py
"""Train the Layer 2 TF-IDF toxicity classifier.

Reads ``moderation/data/seed_corpus.csv`` (columns: ``text,label`` where
``label`` is 1=toxic/bullying, 0=clean) and fits a
``TfidfVectorizer -> LogisticRegression`` pipeline, then serialises it to
``moderation/data/model.pkl`` with joblib.

Run from the backend directory:

    python -m moderation.train_model

Re-run after editing the corpus and commit the regenerated ``model.pkl``.
The model is loaded at runtime by ``moderation/tfidf_model.py`` (server-side).
"""

from __future__ import annotations

import csv
import logging
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)

_DATA_DIR = Path(__file__).resolve().parent / "data"
CORPUS_PATH = _DATA_DIR / "seed_corpus.csv"
MODEL_PATH = _DATA_DIR / "model.pkl"


def load_corpus(path: Path = CORPUS_PATH) -> tuple[list[str], list[int]]:
    """Load (texts, labels) from the seed corpus CSV, skipping malformed rows."""
    texts: list[str] = []
    labels: list[int] = []
    with path.open(newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            text = (row.get("text") or "").strip()
            label_raw = (row.get("label") or "").strip()
            if not text or label_raw not in ("0", "1"):
                continue
            texts.append(text)
            labels.append(int(label_raw))
    return texts, labels


def build_pipeline() -> Any:
    """Build the TF-IDF + LogisticRegression pipeline (unigrams + bigrams)."""
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.linear_model import LogisticRegression
    from sklearn.pipeline import Pipeline

    return Pipeline(
        [
            (
                "tfidf",
                TfidfVectorizer(
                    ngram_range=(1, 2),
                    min_df=1,
                    sublinear_tf=True,
                    lowercase=True,
                ),
            ),
            (
                "clf",
                LogisticRegression(max_iter=1000, class_weight="balanced"),
            ),
        ]
    )


def train(corpus_path: Path = CORPUS_PATH, model_path: Path = MODEL_PATH) -> int:
    """Fit the pipeline on the corpus and persist it. Returns the row count."""
    import joblib

    texts, labels = load_corpus(corpus_path)
    if len(set(labels)) < 2:
        raise SystemExit("Corpus must contain both classes (0 and 1).")

    pipeline = build_pipeline()
    pipeline.fit(texts, labels)
    model_path.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(pipeline, model_path)
    logger.info("Trained TF-IDF model on %d examples -> %s", len(texts), model_path)
    return len(texts)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    count = train()
    print(f"Trained TF-IDF model on {count} examples -> {MODEL_PATH}")
