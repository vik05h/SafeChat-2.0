# SafeChat Architecture

This document describes the system architecture, hosting decisions, and scaling considerations for SafeChat.

---

## 1. System Overview

SafeChat is built as a three-tier system:

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  CLIENT LAYER (Expo - React Native + Web)                   │
│  ├─ Android app (Play Store)                                │
│  ├─ Web app (browser)                                       │
│  └─ Direct Firebase SDK access for realtime features        │
│                                                             │
└──────────────────┬──────────────────────┬───────────────────┘
                   │                      │
                   │ REST API             │ Firestore Listeners
                   │ (HTTPS)              │ (WebSocket)
                   │                      │
┌──────────────────▼──────────┐  ┌────────▼─────────────────┐
│                             │  │                          │
│  APPLICATION LAYER          │  │  DATA + AUTH LAYER       │
│  (FastAPI on Cloud Run)     │  │  (Firebase / GCP)        │
│                             │  │                          │
│  ├─ Auth verification       │  │  ├─ Firebase Auth        │
│  ├─ Moderation engine       │  │  ├─ Cloud Firestore      │
│  ├─ Business logic          │  │  ├─ Firebase Storage     │
│  ├─ Push notification       │  │  ├─ Firebase Hosting     │
│  │   dispatch               │  │  └─ Cloud Messaging      │
│  └─ External API calls      │  │                          │
│                             │  └──────────────────────────┘
└─────────────┬───────────────┘
              │
              │ HTTPS
              │
┌─────────────▼─────────────────────────────────────────────┐
│                                                           │
│  EXTERNAL SERVICES                                        │
│  ├─ OpenAI Moderation API (text classification)           │
│  ├─ Google Gemini API (nuanced moderation, Hindi/lang)    │
│  ├─ Google Cloud Vision (image safety + OCR)              │
│  └─ Agora SDK (voice/video calls — Phase 3)               │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

---

## 2. Component Responsibilities

### Client Layer (Expo App)

**Responsibilities:**
- User interface for both Android and Web from a single codebase
- Direct read access to Firestore via Firebase SDK (real-time listeners for chat, feed, notifications)
- All write operations routed through backend API for moderation
- Firebase Auth token management
- Local state management
- Push notification reception (FCM)

**Why direct Firestore reads:**
Real-time chat performance requires WebSocket-based listeners. Routing reads through the backend would add latency and require maintaining our own WebSocket infrastructure. Firestore's security rules enforce that users can only read what they're authorized to see.

**Why writes go through backend:**
Every write (message, post, comment, story, profile update) must pass through the moderation cascade. Allowing direct Firestore writes would bypass moderation.

### Application Layer (FastAPI on Cloud Run)

**Responsibilities:**
- Verify Firebase Auth tokens on every request
- Run all content through the moderation engine before persisting
- Coordinate calls to external moderation APIs
- Write moderated content to Firestore
- Dispatch push notifications via FCM
- Handle media upload pipeline (signed URLs to Firebase Storage)
- Admin operations (post approval, report resolution, keyword management)

**Why Cloud Run:**
- Autoscales from zero to thousands of containers
- Pay-per-request (covered by GCP credits)
- Native HTTPS, integrates with Firebase Auth tokens
- Container-based — same Docker setup that works locally

### Data + Auth Layer (Firebase / GCP)

**Cloud Firestore (database):**
- Document-based, real-time, globally distributed
- Multi-region replication for global low latency
- Security rules enforce row-level access control

**Firebase Auth:**
- Handles password hashing, OAuth flows, session management, MFA
- Email/Password + Google Sign-In at launch; Phone Auth later
- ID tokens verified by backend on every request

**Firebase Storage:**
- Stores all user media (profile pictures, posts, stories, video attachments)
- Backed by Google Cloud Storage with global CDN
- Access controlled via signed URLs from backend

**Firebase Cloud Messaging (FCM):**
- Push notifications to Android and web
- Server-initiated from FastAPI backend

### External Services

**OpenAI Moderation API:**
- Text moderation across categories: hate, harassment, violence, self-harm, sexual content
- Free with API key
- First-line API check after keyword filter

**Google Gemini API:**
- Nuanced moderation for borderline cases
- Better Hindi/Hinglish support than alternatives
- Context-aware (understands sarcasm, intent better than pattern matching)
- Image understanding for complex visual moderation
- Covered by GenAI App Builder credit

**Google Cloud Vision:**
- Safe Search for adult/violence/racy content in images
- OCR to extract text from memes (then runs through text moderation)
- Object and label detection for context

---

## 3. Hosting & Infrastructure

### Cloud Run (Backend Hosting)

```yaml
Service:           FastAPI backend
Region:            Same as Firestore (us-central1 or nam5-compatible)
Min instances:     0 (scales to zero when idle)
Max instances:     100 (initial cap, raise as needed)
CPU:               1 vCPU
Memory:            512 MB
Concurrency:       80 requests per container
Timeout:           60 seconds
```

### Firestore (Database)

```yaml
Location:          nam5 (multi-region US)
Mode:              Native mode
Backup:            Daily automated, 7-day retention
Security:          Security Rules enforced (see DATABASE_SCHEMA.md)
```

### Firebase Storage

```yaml
Bucket:            safechat-prod.firebasestorage.app
Location:          US-EAST1 (compatible with nam5 Firestore)
Storage class:     Standard
Access:            Authenticated only, via Storage Rules
```

### Firebase Hosting (Web Frontend)

```yaml
Domain:            safechat-prod.web.app (auto-provisioned)
Custom domain:     safechat.app (when acquired)
SSL:               Auto-provisioned via Firebase
CDN:               Google Global CDN included
```

---

## 4. Data Flow Examples

### Sending a Direct Message

```
1. User types message in Expo app
2. App calls POST /api/v1/messages
   - Includes Firebase Auth ID token
3. Backend verifies token via Firebase Admin SDK
4. Backend runs message through moderation cascade:
   a. Normalize text (handle bypass attempts)
   b. Check dynamic keyword list (Firestore-cached)
   c. If clean: OpenAI Moderation API
   d. If borderline: Gemini API
   e. If toxic at any layer → respond 200 with blocked status
5. If clean: write to /chats/{chatId}/messages/{messageId} in Firestore
6. Recipient's Firestore listener triggers — message appears instantly
7. Backend dispatches FCM push notification to recipient
```

### Uploading a Post with Image

```
1. User selects image in app
2. App requests signed upload URL: POST /api/v1/uploads/sign
3. Backend returns signed Firebase Storage URL
4. App uploads image directly to Firebase Storage (bypasses backend)
5. App calls POST /api/v1/posts with caption + image path
6. Backend runs moderation:
   a. Caption → text moderation cascade
   b. Image → Cloud Vision Safe Search
   c. Image → Cloud Vision OCR → extracted text → text moderation
   d. (Optional) Image → Gemini Vision for context check
7. If clean: write post to /posts/{postId} (status: approved)
8. If toxic: write post with status: blocked (kept for admin review only)
9. App displays appropriate UI to user
```

### Reading the Feed

```
1. User opens app
2. App subscribes to Firestore query:
   /posts where author in [followedUsers] orderBy createdAt desc limit 20
3. Security Rules verify user can read these posts
4. Firestore streams matching documents directly to client
5. New posts appear in real-time via listener
6. No backend involvement — pure Firestore real-time
```

---

## 5. Authentication Flow

```
1. User opens app, taps "Sign in with Google"
2. Firebase Auth SDK opens Google OAuth flow
3. User completes Google sign-in
4. Firebase Auth returns ID token (JWT) to app
5. App stores token, attaches to every API request as Bearer token
6. Backend verifies token on each request via Firebase Admin SDK
7. Token contains user UID — used to authorize Firestore operations
```

**Token lifetime:** 1 hour, auto-refreshed by Firebase SDK.

---

## 6. Security Architecture

### Defense in depth

1. **Firebase Auth** — handles credential security
2. **Firestore Security Rules** — row-level access control
3. **Storage Security Rules** — file-level access control
4. **Backend token verification** — every API request authenticated
5. **Moderation cascade** — content security (anti-bullying)
6. **Rate limiting** — anti-abuse (Cloud Run + custom middleware)
7. **HTTPS only** — TLS for all communications

### Secrets management

- All API keys stored in Cloud Run environment variables (encrypted at rest)
- Firebase Admin SDK key never committed to git
- Local development uses `.env` files (gitignored)
- Production secrets managed via Google Secret Manager

---

## 7. Scaling Considerations

### Current capacity (v1 architecture)

| Metric | Estimated capacity |
|---|---|
| Concurrent users | ~10,000 |
| Messages/second | ~1,000 |
| Posts/day | ~100,000 |
| Image uploads/day | ~50,000 |
| API requests/month | ~10 million |

### Scaling triggers and responses

| Issue | When | Response |
|---|---|---|
| Cloud Run cold starts | Always | Set min instances to 1 (small cost) |
| Firestore read costs | >50k reads/day | Add aggressive caching, denormalize |
| Moderation API latency | >2s p95 | Add Redis cache for repeat content |
| Image upload bandwidth | >100GB/month | Migrate hot media to Cloud CDN |
| Vision API costs | >₹5k/month | Add image hash dedup, ML pre-filter |

### Scaling beyond v1

When approaching 100k+ daily active users:
- Move moderation engine to dedicated service (separate Cloud Run service)
- Introduce read replicas / caching layer (Redis on Memorystore)
- Move heavy media to dedicated CDN (Cloudflare in front of Cloud Storage)
- Region-specific Firestore for sub-100ms global latency

---

## 8. Observability

| Layer | Tooling |
|---|---|
| Application logs | Cloud Logging (auto from Cloud Run) |
| Error tracking | Sentry |
| Performance metrics | Cloud Monitoring + Firebase Performance |
| Uptime monitoring | Cloud Monitoring uptime checks |
| Cost monitoring | GCP Billing alerts at ₹500, ₹1k, ₹5k thresholds |

---

## 9. Deployment Strategy

### Environments

```
Local        → Developer machine, local Firestore emulator optional
Staging      → Separate Firebase project (safechat-staging)
Production   → safechat-prod
```

### CI/CD Pipeline

```
Push to main         → Build → Test → Deploy to staging
Manual promotion     → Deploy to production
                       (after smoke tests pass)
```

Pipeline defined in `.github/workflows/`.

### Database migrations

Firestore is schemaless, but we maintain consistency via:
- Backend-only writes (no direct client writes for structured data)
- Migration scripts in `backend/scripts/migrations/`
- Version field on documents for future schema changes

---

## 10. Architecture Decisions Record

Key decisions and their rationales:

| Decision | Alternative considered | Reason chosen |
|---|---|---|
| Firestore over Postgres | Cloud SQL Postgres | Real-time listeners, simpler scaling, integrated auth |
| Expo over native | Pure React Native | Single codebase for Android + Web |
| OpenAI + Gemini cascade | Single API, custom model | Best accuracy/cost balance, multilingual |
| Cloud Run over GKE | Kubernetes Engine | Lower operational overhead, pay-per-request |
| Firebase Auth over custom | Self-built bcrypt | Security, OAuth providers, mature SDK |
| Agora over custom WebRTC | Build from scratch | Time to market, reliability, scale-ready |

---

## 11. Cost Model

See [`docs/ROADMAP.md`](ROADMAP.md) for cost projections at different user scales.

Major cost drivers ranked:
1. Firestore reads (mitigated by caching strategy)
2. Cloud Vision API (mitigated by image hash deduplication)
3. Cloud Storage egress (mitigated by CDN caching)
4. Cloud Run compute (covered by free tier for low traffic)
5. FCM, Auth, Hosting — effectively free at our scale

---

*Last updated: November 2026*
