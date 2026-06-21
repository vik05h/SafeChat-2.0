# SafeChat Moderation Engine

The moderation engine is SafeChat's core differentiator. This document specifies its design, behavior, and operational rules.

---

## 1. Design Principles

1. **Block before exposure.** Toxic content must never reach the recipient. All moderation happens at the API layer before persistence.

2. **Cascade, don't single-shot.** No single moderation system is reliable enough. Layers compound accuracy and resilience.

3. **Fail closed for safety, fail open for availability.** If a critical moderation API is down, fall back to less precise layers but never let content through unchecked.

4. **Multilingual by default.** Hindi, Hinglish, and English at launch. Architecture supports expansion.

5. **Updatable without redeployment.** Moderators must be able to react to new slang and abuse patterns in minutes, not deploy cycles.

6. **Transparent to users.** When content is blocked, users understand why (without revealing specific keyword matches that enable bypass).

---

## 2. Moderation Cascade Architecture

### Text Content Cascade

```
┌──────────────────────────────────────────────────────────┐
│  INCOMING TEXT                                           │
│  (message, comment, post caption, story caption, bio)    │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │  LAYER 1                   │
        │  Text Normalization        │
        │  ─────────────────────     │
        │  Lowercase                 │
        │  Strip diacritics          │
        │  Remove special chars      │
        │  Collapse repeated chars   │
        │  Demojize (🔫 → :gun:)    │
        └────────────┬───────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │  LAYER 2                   │
        │  Dynamic Keyword Filter    │
        │  ─────────────────────     │
        │  Firestore: /moderation/   │
        │  In-memory cache, 5min TTL │
        │  Multilingual word lists   │
        │  + bypass patterns         │
        └────────────┬───────────────┘
                     │
              ┌──────┴──────┐
              │             │
        HIT ──┘             └── MISS
              │             │
              ▼             ▼
          [BLOCKED]    ┌────────────────────────────┐
                       │  LAYER 3                   │
                       │  OpenAI Moderation API     │
                       │  ─────────────────────     │
                       │  Returns flagged: bool +   │
                       │  category scores           │
                       │  Categories: hate,         │
                       │  harassment, violence,     │
                       │  sexual, self-harm         │
                       └────────────┬───────────────┘
                                    │
                          ┌─────────┼─────────┐
                          │         │         │
                       FLAGGED  BORDERLINE   CLEAN
                          │         │         │
                          ▼         ▼         ▼
                      [BLOCKED]  Layer 4   [APPROVED]
                                    │
                                    ▼
                       ┌────────────────────────────┐
                       │  LAYER 4                   │
                       │  Google Gemini API         │
                       │  ─────────────────────     │
                       │  Context-aware             │
                       │  Multilingual              │
                       │  Returns toxic: bool +     │
                       │  reasoning                 │
                       └────────────┬───────────────┘
                                    │
                            ┌───────┴───────┐
                            │               │
                         TOXIC           CLEAN
                            │               │
                            ▼               ▼
                        [BLOCKED]      [APPROVED]
```

### Image Content Cascade

```
┌──────────────────────────────────────────────────────────┐
│  INCOMING IMAGE                                          │
│  (profile pic, post, story, message attachment)          │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │  LAYER 1                   │
        │  Google Cloud Vision       │
        │  Safe Search               │
        │  ─────────────────────     │
        │  Adult: VERY_UNLIKELY      │
        │  Violence: VERY_UNLIKELY   │
        │  Racy: VERY_UNLIKELY       │
        │  Medical: VERY_UNLIKELY    │
        │  Spoof: VERY_UNLIKELY      │
        └────────────┬───────────────┘
                     │
              ┌──────┴──────┐
              │             │
        FLAGGED ──┘         └── CLEAN
              │             │
              ▼             ▼
          [BLOCKED]    ┌────────────────────────────┐
                       │  LAYER 2                   │
                       │  Google Cloud Vision OCR   │
                       │  ─────────────────────     │
                       │  Extract any text from     │
                       │  image (memes, screenshots)│
                       └────────────┬───────────────┘
                                    │
                       ┌────────────┴────────────┐
                       │                         │
                  TEXT FOUND               NO TEXT
                       │                         │
                       ▼                         ▼
              [Run through text         ┌────────────────────────┐
               cascade above]           │  LAYER 3 (Optional)    │
                                        │  Gemini Vision         │
                                        │  ─────────────────────  │
                                        │  Context analysis:     │
                                        │  Is this image used    │
                                        │  for bullying?         │
                                        └────────────┬───────────┘
                                                     │
                                              ┌──────┴──────┐
                                              │             │
                                          TOXIC           CLEAN
                                              │             │
                                              ▼             ▼
                                          [BLOCKED]    [APPROVED]
```

---

## 3. Layer Specifications

### Layer 1: Text Normalization

**Purpose:** Defeat common bypass attempts before they reach pattern matching.

**Operations applied in order:**

```python
def normalize(text: str) -> str:
    text = text.lower()
    text = unicodedata.normalize('NFKD', text)        # strip diacritics
    text = emoji.demojize(text)                       # 🔫 → :gun:
    text = re.sub(r'[^\w\s:]', '', text)              # remove punctuation
    text = re.sub(r'(.)\1{2,}', r'\1\1', text)        # 'fuuuuuck' → 'fuuck'
    text = re.sub(r'\s+', ' ', text).strip()          # collapse whitespace
    return text
```

**Examples:**

| Input | Normalized |
|---|---|
| `m@darchod` | `mdarchod` (then keyword catches via Levenshtein) |
| `f.u.c.k` | `fck` (then keyword + fuzzy match) |
| `MADARCHOOOOD` | `madarchood` (then keyword match) |
| `kill ur self 🔫` | `kill ur self :gun:` |

### Layer 2: Dynamic Keyword Filter

**Storage:** Firestore at `/moderation/keywords` (see DATABASE_SCHEMA.md)

**Categories:**
- `english_slurs` — high-confidence English slurs
- `hindi_slurs` — Devanagari script slurs
- `hinglish_slurs` — romanized Hindi slurs
- `threats` — direct threat phrases
- `bypass_patterns` — known evasion patterns (regex)

**Matching strategy:**
1. Exact match against normalized text
2. Fuzzy match (Levenshtein distance ≤ 2) for words ≥ 5 chars
3. Regex match for bypass patterns

**Caching:** Backend caches keyword list in memory, refreshes every 5 minutes via background task. No DB query per moderation call.

**Update flow:**
1. Admin updates keyword list via admin panel
2. Write goes to Firestore
3. Backend cache refreshes on next interval (or via webhook for instant)
4. No redeployment required

### Layer 3: OpenAI Moderation API

**Endpoint:** `https://api.openai.com/v1/moderations`

**Model:** `omni-moderation-latest` (supports text + images)

**Request:**
```json
{
  "model": "omni-moderation-latest",
  "input": "<normalized text>"
}
```

**Response handling:**

```python
THRESHOLDS = {
    "hate": 0.7,
    "hate/threatening": 0.5,        # lower threshold for threats
    "harassment": 0.6,
    "harassment/threatening": 0.5,
    "self-harm": 0.5,
    "self-harm/intent": 0.4,        # highest sensitivity
    "sexual": 0.7,
    "sexual/minors": 0.3,           # near-zero tolerance
    "violence": 0.7,
    "violence/graphic": 0.6,
}

def classify_openai(text: str) -> Verdict:
    result = openai.moderations.create(input=text)
    scores = result.results[0].category_scores
    
    for category, threshold in THRESHOLDS.items():
        if scores[category] >= threshold:
            return Verdict(blocked=True, reason=category, score=scores[category])
    
    # Borderline: any score 0.3-0.5 → escalate to Gemini
    max_score = max(scores.values())
    if max_score >= 0.3:
        return Verdict(borderline=True, max_score=max_score)
    
    return Verdict(approved=True)
```

**Failure mode:** If API returns error or times out (>3s), log warning and proceed to Layer 4 (Gemini). If both fail, default to BLOCK (fail closed for safety).

### Layer 4: Google Gemini API

**Purpose:** Context-aware classification for borderline cases. Excels at:
- Sarcasm detection
- Hindi/Hinglish nuance
- Reclaimed slurs vs slurs used as attacks
- Coded language and dog whistles

**Model:** `gemini-2.0-flash` (low latency, good for moderation)

**Prompt template:**

```
You are a content moderator for a social platform. Determine if the 
following message is bullying, harassment, hate speech, or otherwise 
intended to harm another person.

Consider:
- Hindi, Hinglish, and English are common
- Slurs reclaimed in-group are not bullying
- Sarcasm and jokes between friends are acceptable
- Direct threats, slurs targeting someone, or doxxing are NOT acceptable

Respond ONLY in this exact JSON format:
{
  "toxic": true | false,
  "category": "hate" | "harassment" | "threat" | "sexual" | "self-harm" | "clean",
  "confidence": 0.0 to 1.0,
  "reason": "<brief explanation in English>"
}

Message: """<text>"""
```

**Decision:** `toxic == true AND confidence >= 0.6` → BLOCK

**Cost:** Free under GenAI App Builder credit at current volumes.

### Layer 5 (Image): Cloud Vision Safe Search

**Endpoint:** Cloud Vision API `images:annotate`

**Features requested:** `SAFE_SEARCH_DETECTION`

**Response categories:** `adult`, `violence`, `racy`, `medical`, `spoof`

**Likelihood values:** `VERY_UNLIKELY`, `UNLIKELY`, `POSSIBLE`, `LIKELY`, `VERY_LIKELY`

**Blocking thresholds:**

| Category | Block at |
|---|---|
| adult | LIKELY or higher |
| violence | LIKELY or higher |
| racy | VERY_LIKELY only (allow swimwear, bodies in context) |
| spoof | Not blocked (informational only) |
| medical | Not blocked (informational only) |

### Layer 6 (Image): Cloud Vision OCR

**Purpose:** Extract text from memes, screenshots, edited images. This is what catches "Hinglish slur written over Mickey Mouse" — the visual moderation alone misses this.

**Features requested:** `TEXT_DETECTION`

**Behavior:**
- Extract all detected text from image
- Run extracted text through Text Cascade (Layers 1-4)
- If text is toxic → block image (regardless of visual safety)

---

## 4. Per-Surface Behavior

Different content surfaces have different consequences when toxic content is detected.

| Surface | Toxic content action | User feedback |
|---|---|---|
| Direct message | Silently blocked, not stored | Sender sees "Your message was blocked" |
| Comment | Blocked from posting | Sender sees toast: "Comment doesn't meet community guidelines" |
| Post caption | Post status = `pending_review` | Sender sees: "Your post is under review" |
| Post image | Post status = `pending_review` | Same as above |
| Story | Story status = `pending_review`, not displayed | Sender sees same |
| Profile bio | Update rejected | Field highlighted: "This bio can't be saved" |
| Profile picture | Upload rejected | Image deleted from storage, error shown |
| Username | Reserved/blocked at signup | "This username isn't available" |

**Rationale for differences:**
- DMs are private — blocking outright is safer than human review
- Posts/stories may have legitimate gray-zone content — human moderator review preserves user trust
- Profile fields are public-facing identity — strict rejection prevents abuse

---

## 5. User Reporting Flow

Even with strong proactive moderation, user reports catch what the system misses.

```
1. User taps "Report" on a message, post, comment, or profile
2. Selects reason: harassment, spam, hate, threat, impersonation, other
3. Report written to /reports/{reportId}
4. If 3+ unique reporters on same content within 1 hour → auto-hide pending review
5. Admin panel surfaces all open reports
6. Admin actions: dismiss, block content, warn user, suspend user
7. Reporter sees status update when resolved
```

---

## 6. Rate Limits and Abuse Prevention

| Action | Rate limit | Enforcement |
|---|---|---|
| Send message | 30/min per user | Cloud Run middleware |
| Create post | 10/hour per user | Backend |
| Create comment | 30/hour per user | Backend |
| Submit report | 20/day per user | Backend |
| Failed signup attempts | 5/hour per IP | Cloud Armor |
| Failed login attempts | 5/15min per email | Firebase Auth built-in |

Users exceeding rate limits receive HTTP 429 with retry-after header.

---

## 7. Failure Modes and Fallbacks

| Scenario | Behavior |
|---|---|
| OpenAI API down | Skip to Gemini, log error |
| Gemini API down | Skip to Layer 2 only, log critical |
| Both APIs down | Block all writes with "Moderation unavailable" |
| Cloud Vision down | Block image uploads with retry message |
| Firestore down | Show maintenance page (rare, multi-region |
| Keyword cache stale | Use stale cache up to 1 hour, then refresh from Firestore |

The system prefers **false positives over false negatives** — better to wrongly block a clean message than to let a bullying message through.

---

## 8. Logging and Auditing

Every moderation decision is logged for analysis and audit:

```
Moderation Log Entry:
├── timestamp
├── content_id (message_id, post_id, etc)
├── content_type (message, comment, post, story)
├── author_uid
├── content_hash (for privacy — not raw content)
├── verdict (approved | blocked)
├── layer_triggered (keyword, openai, gemini, vision)
├── category (hate, harassment, etc)
├── confidence_score
├── api_latency_ms (per layer)
└── total_latency_ms
```

Logs stored in Cloud Logging. Aggregate metrics dashboard in Cloud Monitoring.

---

## 9. Continuous Improvement

The moderation engine improves through:

1. **Weekly review of false positives** — clean content wrongly blocked
2. **Weekly review of user-reported bypasses** — content that should have been blocked
3. **Keyword list updates** based on emerging slang
4. **Threshold tuning** for each category based on precision/recall analysis
5. **Quarterly review** of new moderation tools and APIs

---

## 10. Limitations and Honest Acknowledgements

This system is not perfect. Known limitations:

- **Subtle harassment patterns** — coordinated mocking via emoji combos, in-jokes targeting individuals
- **Image-based memes** — context-dependent humor vs targeted mockery is genuinely hard for AI
- **Reclaimed language** — slurs used affectionately within communities may be over-blocked
- **Novel attack vectors** — bypasses we haven't seen yet will succeed until caught
- **Languages beyond launch set** — global launch is English/Hindi/Hinglish only
- **Tone and intent** — "I'll kill you" between friends vs as threat — context window limits

User reporting + admin review is the safety net for these gaps.

---

## 11. Privacy Considerations

- **Content is not stored at moderation APIs.** OpenAI and Gemini do not train on API data per their terms.
- **Hashes, not content, in logs.** Moderation logs use SHA-256 hashes of content for tracking, not raw text.
- **User-specific patterns not built.** We do not profile users for moderation purposes.
- **GDPR/DPDP compliance.** Users can request deletion of all their content and associated moderation records.

See [`docs/legal/PRIVACY_POLICY.md`](legal/PRIVACY_POLICY.md) for full privacy commitments.

---

*Last updated: November 2026*
