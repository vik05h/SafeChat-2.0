# SafeChat Moderation Engine (V1)

This document outlines the moderation cascade used to filter content before it reaches end-users.

**Note:** In V1 (Phase 0/1), the moderation engine relies exclusively on a **TF-IDF Keyword Detection** filter. Advanced AI integrations (OpenAI, Gemini, Vision) are documented here as *upcoming features* and will be enabled in subsequent phases.

---

## The V1 Cascade

Every user-generated string (messages, posts, bio, comments) flows through this pipeline before being saved to the database:

### 1. Normalizer (Active)
Before checking against lists or models, text must be normalized to prevent bypass attempts (e.g., "b@d w0rd" -> "bad word").
- Strips special characters used as delimiters.
- Normalizes visually similar Unicode characters (homoglyphs).
- Consolidates repeated characters (e.g., "baaaad" -> "bad").

### 2. TF-IDF Keyword Filter (Active)
A lightweight, lightning-fast first line of defense.
- Scans normalized text against a curated dictionary of highly toxic words and slurs.
- Uses Term Frequency-Inverse Document Frequency (TF-IDF) concepts to weight terms appropriately and reduce false positives.
- If a hard-banned keyword is detected, the message is **blocked immediately**.
- Bypasses external APIs completely for obvious infractions, saving cost and latency.

---

## Upcoming Moderation Phases

Once the foundation is solid, the following layers will be integrated into the cascade:

### 3. OpenAI Moderation API (Upcoming)
If the keyword filter passes, the text will be sent to the OpenAI Moderation API to detect context-heavy toxicity (hate speech, self-harm, harassment) that keyword filters miss.

### 4. Google Gemini API (Upcoming)
For borderline cases flagged by OpenAI, or for heavily nuanced cultural context (like Hinglish or sarcasm), the Gemini API will be used as the final tie-breaker.

### 5. Cloud Vision OCR & Safe Search (Upcoming)
For images, Google Cloud Vision will be utilized to extract text (OCR) from memes and images, which is then fed into the text moderation cascade. Safe Search will detect visual toxicity (violence, adult content).

---

## Developer Guidelines

**Golden Rule: Never bypass moderation.**

When implementing a new feature in the backend (FastAPI) that accepts user text:
1. Ensure the text payload is routed to `engine.moderate_text(text)`.
2. Handle the `ModerationResult`. If `is_blocked == True`, return a `422 Unprocessable Entity` with a standardized moderation error code.
3. **Never** write user text to Firestore directly from the Flutter client.
