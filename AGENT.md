# SafeChat V1 AI Agent Instructions

This file serves as the Single Source of Truth for all AI agents (Claude, Gemini, etc.) working on the SafeChat repository. 

## Context
SafeChat is a social platform with AI-powered real-time content moderation, specifically focused on schools and teens to prevent cyberbullying. Bullying and toxic content are blocked **before** reaching the recipient. 

**Target Platforms:** Android (Play Store) and Web.

## Design System
SafeChat implements a multi-theme design system supporting exactly two distinct switchable designs:
1. **Material 3 (Standard):** Clean, standard Material 3 components following conventional guidelines.
2. **Softer Neobrutalism (Custom):** A distinctive neo-brutalist style featuring muted/pastel colors, prominent dark grey borders, and sharp offset shadows.
*(See `docs/UI_DESIGN_SYSTEM.md` for full details).*

## 🧠 How to Use This File

Before generating ANY code, the agent MUST:
1. Read this `AGENT.md` file.
2. Read `README.md` for architecture and API specs.
3. Read `docs/ARCHITECTURE.md` for locked decisions.
4. Activate relevant skills from `.agents/skills/` based on the task.
5. Ask clarifying questions if requirements are ambiguous.
6. Refer to the `docs/` folder for more specific information.
7. For animation (especially web/cross-platform), use GSAP from `.agents/skills/`.

## Tech Stack (V1)
```
Frontend:    Flutter 3.x (Android + Web from single codebase)
State:       Riverpod (Strict Riverpod for state management)
Routing:     GoRouter (declarative, deep-link ready)
HTTP:        Dio + retrofit (type-safe API client)

Backend:     FastAPI on Cloud Run (Python 3.11+)
Database:    Cloud Firestore (real-time listeners for chat/notifications)
Auth:        Firebase Auth (Google + Email/Password)
Storage:     Firebase Storage (direct uploads via signed URLs)
Push:        Firebase Cloud Messaging

Moderation:  Keyword detection (TF-IDF based). OpenAI, Gemini, and Vision are upcoming features for later phases.
```

## Critical Rules
1. **All writes go through backend.** Never write posts/messages/comments directly to Firestore from the client. Call FastAPI endpoints so moderation runs.
2. **Direct Firestore reads are fine** for real-time chat, notifications, and feed updates.
3. **Never bypass moderation.** Every user-generated content surface must hit the API first.
4. **Never commit credentials.** Firebase config, API keys, `.env` stay local only.
5. **Match existing patterns** in the same folder before inventing new ones.

## Code Conventions

### Dart / Flutter
- **Formatting:** `dart format` line length 100, `flutter_lints` strict.
- **Naming:** `snake_case` files, `PascalCase` widgets/classes, `camelCase` variables/functions, `lowerCamelCase` providers.
- **State:** `AsyncValue` for Riverpod.
- **Error handling:** Centralized error mapper → user-friendly messages.

### Python / FastAPI
- **Formatting:** Black (line length 100).
- **Linting:** Ruff.
- **Type checking:** mypy strict mode. All functions require type hints.
- **Naming:** `snake_case` functions/variables, `PascalCase` classes, `UPPER_SNAKE_CASE` constants.
- **Models:** Pydantic models for all request/response shapes.

## Key Patterns
- **Auth flow:** Sign in → Check Firestore `/users/{uid}` directly for profile (Zero-latency boot). If missing, call `POST /auth/onboard` to create profile through backend. Store Firebase token in secure storage → attach to all backend requests via Dio interceptor.
- **Real-time chat:** Firestore listener on `/chats/{chatId}/messages` ordered by `created_at`.
- **Feed:** Firestore query `/posts` with `author_uid in [followedUsers]` + `status == approved`. Pagination with cursors.
- **Image upload:** `POST /uploads/sign` → get signed URL → upload directly to Firebase Storage → pass `file_url` to post/story creation.

## Testing
- **Backend:** pytest, mock external APIs, use Firestore emulator for integration tests.
- **Frontend Unit:** Use cases, repositories (mock Dio/Firebase).
- **Frontend Widget:** Golden tests for critical screens, checking both themes.
- **Integration:** Auth flow, post creation, DM send.

## Phase Awareness
Current: **Phase 0/1 — Foundation.** 
Don't build Phase 6+ UI before scaffolding is solid.
Wait to implement advanced AI moderation (OpenAI/Gemini/Vision) until the foundation of Keyword Detection is perfectly integrated.
