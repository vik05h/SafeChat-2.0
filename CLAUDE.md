# Claude Code Instructions for SafeChat

This file is read by Claude Code at the start of every session in this repository. It defines project-specific rules and conventions.

---

## Project Context

SafeChat is a social media platform with AI-powered real-time content moderation. The differentiator is that bullying, harassment, and toxic content are blocked **before** they reach the recipient, across messages, posts, comments, stories, and images.

**Target platforms:** Android (via Play Store) and Web browsers.
**Audience:** Global. Multilingual moderation (English, Hindi, Hinglish at launch).

Before writing any code, read these documents in order:

1. `docs/ARCHITECTURE.md` — system design and component responsibilities
2. `docs/MODERATION.md` — moderation cascade specification (THE most important doc)
3. `docs/API_CONTRACTS.md` — REST endpoint specifications
4. `docs/DATABASE_SCHEMA.md` — Firestore collections and security rules
5. `docs/ROADMAP.md` — what we're building now vs later

---

## Critical Rules

### 1. Never bypass moderation

Every endpoint that accepts user-generated content (messages, posts, comments, stories, captions, bios, usernames, profile fields) MUST run that content through the moderation engine before persisting to Firestore. No exceptions, even for testing.

If you're creating a new endpoint, ask: does it accept user content? If yes, where does the moderation call go?

### 2. Never commit credentials

The following must NEVER appear in committed code:
- Firebase Admin SDK JSON keys
- API keys (OpenAI, Gemini, etc.)
- `.env` file contents
- Service account credentials

The `.gitignore` is configured to prevent this, but always verify before committing.

### 3. Backend writes only for structured data

Clients (the Expo app) write to Firestore in only one case: their own writable subcollections (likes, FCM tokens). All other writes — messages, posts, comments, profile updates — go through the FastAPI backend so moderation runs.

Direct Firestore reads from clients are fine (and encouraged) for real-time features like chat and notifications.

### 4. Document changes alongside code changes

If a code change affects:
- An API endpoint → update `docs/API_CONTRACTS.md` in the same PR
- The database shape → update `docs/DATABASE_SCHEMA.md`
- Moderation behavior → update `docs/MODERATION.md`
- System architecture → update `docs/ARCHITECTURE.md`
- User-facing functionality → update `README.md`

---

## Tech Stack

```
Backend         FastAPI on Cloud Run (Python 3.11)
Database        Cloud Firestore (Firebase)
Auth            Firebase Auth (Google + Email/Password)
Storage         Firebase Storage
Frontend        Expo (React Native + React Native Web)
Mobile target   Android (Play Store)
Web target      Browser via Expo web build
Push notifs     Firebase Cloud Messaging
Text moderation OpenAI Moderation API + Google Gemini
Image moderation Google Cloud Vision (Safe Search + OCR)
Voice/Video     Agora (added in Phase 10)
CI/CD           GitHub Actions
Monitoring      Cloud Logging + Cloud Monitoring + Sentry
```

---

## Code Conventions

### Python (Backend)

- Format: Black (line length 100)
- Lint: Ruff
- Type checking: mypy strict mode
- All functions: type hints required, docstrings on public functions
- Naming: `snake_case` functions/variables, `PascalCase` classes, `UPPER_SNAKE_CASE` constants
- Imports: stdlib → third-party → local, separated by blank lines
- Async by default for I/O operations
- Pydantic models for all request/response shapes
- File header comment: `# backend/path/to/file.py`

### TypeScript (Frontend)

- Format: Prettier (single quotes, no semicolons, line length 100)
- Lint: ESLint
- TypeScript required for new files
- Functional components only
- Naming: `camelCase` variables, `PascalCase` components and types
- File naming: `PascalCase.tsx` components, `camelCase.ts` utilities
- File header comment: `// app/path/to/file.tsx`

### Common

- Match patterns from existing code in the same folder before inventing new ones
- Small, focused commits with conventional commit messages
- Tests live alongside code: `module.py` → `tests/test_module.py`

---

## File Structure

```
SafeChat-2.0/
├── app/                      # Expo (React Native + Web)
│   ├── src/
│   │   ├── screens/          # Full screen components
│   │   ├── components/       # Reusable UI components
│   │   ├── hooks/            # Custom React hooks
│   │   ├── services/         # API client, Firebase SDK wrappers
│   │   ├── utils/            # Pure utility functions
│   │   ├── types/            # Shared TypeScript types
│   │   └── navigation/       # React Navigation setup
│   ├── app.json
│   └── package.json
│
├── backend/                  # FastAPI server
│   ├── moderation/           # Moderation cascade
│   │   ├── normalizer.py
│   │   ├── keyword_filter.py
│   │   ├── openai_moderation.py
│   │   ├── gemini_moderation.py
│   │   ├── vision_moderation.py
│   │   └── engine.py         # Main orchestrator
│   ├── routes/               # API endpoint handlers
│   │   ├── auth.py
│   │   ├── users.py
│   │   ├── posts.py
│   │   ├── messages.py
│   │   ├── chats.py
│   │   ├── stories.py
│   │   ├── uploads.py
│   │   ├── reports.py
│   │   ├── notifications.py
│   │   └── admin.py
│   ├── models/               # Pydantic schemas
│   ├── services/             # Firebase Admin, external APIs
│   ├── middleware/           # Auth, rate limiting, logging
│   ├── tests/                # Pytest tests
│   ├── main.py               # FastAPI app entry
│   └── requirements.txt
│
├── admin/                    # Separate admin panel (React web)
│   └── src/
│
├── docs/                     # All project documentation
│   ├── ARCHITECTURE.md
│   ├── MODERATION.md
│   ├── API_CONTRACTS.md
│   ├── DATABASE_SCHEMA.md
│   ├── ROADMAP.md
│   ├── CONTRIBUTING.md
│   └── legal/
│       ├── PRIVACY_POLICY.md
│       ├── TERMS_OF_SERVICE.md
│       └── COMMUNITY_GUIDELINES.md
│
└── .github/
    └── workflows/            # CI/CD
```

---

## Before You Generate Code

When asked to build a feature:

1. **Read the relevant docs first** — never invent behavior; the spec already exists
2. **Check existing patterns** in the same folder; match them
3. **Identify dependencies** — what already exists you can use vs. what you need to create
4. **Plan the data flow** — what hits the API, where does moderation happen, what writes to Firestore, what triggers notifications
5. **Then write code**

For non-trivial features (more than ~50 lines), draft an approach first and confirm before writing all of it.

---

## Phase-Aware Building

We build in phases (see `docs/ROADMAP.md`). Don't build out of sequence.

If a feature you want to implement belongs to a later phase, flag it but don't build it yet. Premature features:
- Bloat the codebase
- Block earlier critical work
- Don't match what's documented

Current phase: **Phase 0 — Foundation.** Next phase: **Phase 1 — Backend Foundation.**

---

## Testing Discipline

- Backend: pytest, mock external APIs (OpenAI, Gemini, Vision), use Firestore emulator for integration tests
- Frontend: Jest + React Testing Library
- Don't write tests for trivial code (simple getters, third-party libs)
- DO write tests for: moderation cascade (every layer, every category), auth flows, critical user paths, edge cases
- New code should not decrease test coverage on critical modules

When you write code that affects moderation, you must also write or update tests covering:
- Clean content (should not be blocked)
- Toxic content in English, Hindi, Hinglish (should be blocked)
- Bypass attempts (character substitutions, repeated letters)
- Edge cases (empty input, max length, special characters, emojis)

---

## What to Avoid

- Don't pick libraries or services that aren't in the tech stack without flagging it
- Don't add complexity for hypothetical future needs
- Don't write large speculative refactors mid-feature
- Don't store raw user content in moderation logs (use SHA-256 hashes)
- Don't bypass auth for any user-content endpoint
- Don't denormalize data unless documented in `DATABASE_SCHEMA.md`
- Don't add new Firestore collections without updating the schema doc
- Don't deploy or run terraform/gcloud commands without explicit user instruction

---

## Git Conventions

- Never add "Co-Authored-By: Claude" or any AI attribution in commit messages
- Never add "Generated with Claude Code" footers
- Commits should appear authored solely by the project maintainer

---

## Tone

Be direct, practical, and concise in responses. The maintainer (Adnan) prefers honest pushback over agreement when something is wrong. Skip preamble, get to the point.

When you don't know something, say so. When you're unsure if a feature belongs in this phase, ask.

---

*This file may be updated as the project evolves. Keep it in sync with reality.*
