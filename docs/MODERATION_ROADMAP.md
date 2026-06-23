# Moderation Improvement Roadmap

How to make SafeChat's moderation meaningfully better, in priority order. The
theme: **detection quality first** — the cheapest, highest-impact wins are in
data and feedback loops, not exotic models.

### Where we are today
- **Layer 1 — lexicon** (`moderation/lexicon.py`): curated slurs/threats with
  obfuscation-tolerant matching + exact highlight spans. Deterministic.
- **Layer 2 — TF-IDF model** (`moderation/tfidf_model.py`): `TfidfVectorizer →
  LogisticRegression` trained on `data/seed_corpus.csv` (**~130 rows**),
  flagging at probability ≥ **0.55**.
- **Layers 3–4 — OpenAI / Gemini / Vision**: scaffolded but **off** (OpenAI runs
  only with a key; it's currently rate-limited).

The model already *generalizes* (it flags unseen sentences built from learned
words), but a 130-row corpus is small — expect both misses and false positives.

---

## 1. Data — the biggest lever

**1a. Grow & balance the corpus.** Get `seed_corpus.csv` from ~130 to **1,000+**
balanced rows. Cover English, Hindi, and Hinglish; include subtle bullying
(exclusion, body-shaming, "jokes") *and* clean look-alikes (so "you're an
amazing friend" stops being a false positive).
- Bulk-import public datasets, reformatted to `text,label`:
  - **Jigsaw Toxic Comment** (English),
  - **HASOC / HOT** (Hindi-English code-mixed),
  - **OLID / HateXplain** (offensive language).
- Keep a **held-out eval set** (~15–20%) that is *never* trained on.

**1b. Feedback loop — turn moderation into free labels.** Every admin
Approve/Reject already lives in `moderation_queue` with the original `text` and
outcome. That's labeled data for free:
- `approved` → label `0`, `rejected` → label `1`.
- Build an **export script** (`scripts/export_training_data.py`) that appends
  resolved queue items to a `corpus/feedback.csv`, de-duplicated.
- Retrain on `seed_corpus.csv` + `feedback.csv`. The model improves from real
  usage — exactly the cases your users actually hit. *(This is the single
  highest-leverage item; ask and I'll build it.)*

---

## 2. Model — measure, then tune

**2a. Add metrics to training.** Have `train_model.py` report
**precision / recall / F1** on the eval set, and a confusion matrix. Track
**false-positive rate** (user friction) separately from **false-negative rate**
(missed bullying) — they have very different costs here.

**2b. Tune the threshold from data, not by hand.** Replace the hand-picked 0.55
with a value chosen off the **precision–recall curve** for a target
(e.g. "recall ≥ 0.9 on the eval set"). Consider **per-category** thresholds
later (threats stricter than mild insults).

**2c. Cheap model upgrades** (in rough order):
- Add **character n-grams** (`analyzer="char_wb", ngram_range=(3,5)`) — catches
  misspellings/obfuscation and Hinglish spelling variants the word model misses.
- Keep `class_weight="balanced"`; calibrate probabilities if thresholds feel off.
- Only if data is plentiful: try a small transformer (e.g. distilled
  multilingual model) behind the same `tfidf_model.score()` interface — the
  engine doesn't care what's behind it.

**2d. Retrain cadence.** Retrain on a schedule (e.g. weekly) or a trigger
(every N new feedback labels). Commit the regenerated `model.pkl`, restart, and
compare eval metrics before/after to catch regressions.

---

## 3. Cascade layers — switch on what's already scaffolded

The engine is a first-block-wins cascade; these slot in with no rework:

1. **OpenAI Moderation** (`openai_moderation.py`, already wired): set a key with
   real quota. Covers nuanced hate / harassment / self-harm / sexual content the
   lexicon and a small model miss. *(Your current key is rate-limited — that's
   why "sex" isn't caught today.)*
2. **Gemini** as a tie-breaker for borderline / culturally nuanced cases
   (Hinglish sarcasm, reclaimed words).
3. **Vision SafeSearch + OCR** for images: the `moderate_image()` hook exists —
   extend it to OCR meme text and feed that back through the *text* cascade, so
   bullying-in-an-image is caught too.

Keep every layer **fail-open** (a provider outage must never block clean posts),
as the current code does.

---

## 4. Lighter notes — UX, admin tooling, scale

- **User UX:** soft inline warnings as they type (debounced `/moderation/analyze`
  is already built and returns highlight spans); educational copy on rejection;
  escalating handling for repeat offenders.
- **Admin tooling:** queue filters (by type/severity), bulk approve/reject, and
  an analytics view over `moderation_logs` (volume, false-positive rate, top
  categories, latency per layer — all already logged).
- **Scale & cost:** cache signed media URLs server-side; short-circuit cheap
  layers before paid APIs (already the design); per-user rate limits on the
  review queue to prevent spam.
- **Privacy:** `moderation_logs` already store only a content **hash**, not raw
  text; keep it that way, and document retention for queue items.

---

## Quick-wins checklist
- [ ] Grow `seed_corpus.csv` to 1,000+ balanced rows (+ public datasets)
- [ ] Build the admin-decision → training-data **feedback loop** export
- [ ] Add an eval set + precision/recall/F1 to `train_model.py`
- [ ] Pick the threshold from the PR curve (retire the hand-tuned 0.55)
- [ ] Add char n-grams to the vectorizer
- [ ] Restore the OpenAI layer (fix key quota)
- [ ] Plan Vision OCR for image moderation
