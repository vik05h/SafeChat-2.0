# SafeChat Flutter Agent Instructions

## Context
SafeChat is a social platform with AI-powered real-time content moderation, specifically focused on schools and teens to prevent cyberbullying. Bullying and toxic content are blocked **before** reaching the recipient. Target: Android (Play Store) and Web.

## Design System
SafeChat implements a multi-theme design system supporting exactly two distinct switchable designs:
1. **Material 3 (Standard):** Clean, standard Material 3 components following conventional guidelines.
2. **Softer Neobrutalism (Custom):** A distinctive neo-brutalist style featuring muted/pastel colors, prominent dark grey borders, and sharp offset shadows.
The UI components must adapt to both themes elegantly. Note: Claymorphism was considered but explicitly dropped.

## 🧠 How to Use This File

Before generating ANY code, the agent MUST:
1. Read this AGENT.md file
2. Read README.md for architecture and API specs
3. Read ARCHITECTURE.md for locked decisions
4. Activate relevant skills from `.agents/skills/` based on the task
5. Ask clarifying questions if requirements are ambiguous
6. refer docs folder for more information
7. for animation if possible use GSAP (Flutter has web support so use GSAP for animation) from `.agents/skills/`


## Available Skills
Use the .agents/skills/ directory for guided implementations:

    flutter-add-integration-test — Integration testing setup
    flutter-add-widget-test — Widget testing patterns
    flutter-add-widget-preview — Widget preview tooling
    flutter-apply-architecture-best-practices — Clean architecture scaffolding
    flutter-build-responsive-layout — Responsive design for mobile + web
    flutter-fix-layout-issues — Layout debugging
    flutter-implement-json-serialization — Freezed/JSON models
    flutter-setup-declarative-routing — GoRouter configuration
    flutter-setup-localization — i18n setup
    flutter-use-http-package — Dio/HTTP client patterns

Always check the relevant skill before implementing a new pattern.

## Tech Stack (Flutter)
```
Frontend:    Flutter 3.x (Android + Web from single codebase)
State:       Riverpod (Strict Riverpod for state management)
Routing:     GoRouter (declarative, deep-link ready)
HTTP:        Dio + retrofit (type-safe API client)
Auth:        Firebase Auth (Google + Email/Password)
Database:    Cloud Firestore (real-time listeners for chat/notifications)
Storage:     Firebase Storage (direct uploads via signed URLs)
Push:        Firebase Cloud Messaging
Images:      cached_network_image
Local:       Hive (for caching/complex objects) + flutter_secure_storage (for tokens)
```

## Critical Rules
1. **All writes go through backend.** Never write posts/messages/comments directly to Firestore. Call FastAPI endpoints so moderation runs.
2. **Direct Firestore reads are fine** for real-time chat, notifications, and feed updates.
3. **Never bypass moderation.** Every user-generated content surface must hit the API first.
4. **Never commit credentials.** Firebase config, API keys, `.env` stay local only.
5. **Match existing patterns** in the same folder before inventing new ones.

## API Integration
- Base URL: `API_BASE_URL` (from `.env` via `flutter_dotenv` or `--dart-define`)
- Auth header: `Bearer <firebase_id_token>` (auto-injected via Dio interceptor)
- All endpoints under `/api/v1/`
- Parse the standard response envelope: `{ data: ..., meta: ..., error: ... }`

## Key Patterns
- **Auth flow:** Sign in → get Firebase ID token → call `POST /auth/onboard` → store token in secure storage → attach to all requests.
- **Real-time chat:** Firestore listener on `/chats/{chatId}/messages` ordered by `created_at`. Security rules enforce participant access.
- **Feed:** Firestore query `/posts` with `author_uid in [followedUsers]` + `status == approved`. Pagination with cursors.
- **Image upload:** `POST /uploads/sign` → get signed URL → upload directly to Firebase Storage → pass `file_url` to post/story creation.
- **Moderation feedback:** When API returns `422 MODERATION_BLOCKED`, show contextual error (e.g., "Message blocked" for DMs, "Post under review" for posts).

## Code Conventions
- **Dart:** `dart format` line length 100, `flutter_lints` strict
- **Naming:** `snake_case` files, `PascalCase` widgets/classes, `camelCase` variables/functions, `lowerCamelCase` providers
- **Imports:** Dart → Flutter → third-party → local, separated by blank lines
- **State:** AsyncValue for Riverpod
- **Error handling:** Centralized error mapper → user-friendly messages

## Testing
- Unit: Use cases, repositories (mock Dio/Firebase)
- Widget: Golden tests for critical screens, checking both themes
- Integration: Auth flow, post creation, DM send (Firestore emulator optional)
- Never test third-party SDKs

## Phase Awareness
Current: **Phase 0 — Foundation.** Next: Phase 1 (Backend Foundation), then Phase 5 (Flutter Foundation).
Build in order. Don't build Phase 6+ UI before Phase 5 scaffolding is solid.

## What to Avoid
- Don't add new packages without checking if existing ones cover it
- Don't write business logic in widgets — keep it in usecases/providers
- Don't denormalize data unless documented in `DATABASE_SCHEMA.md`
- Don't create new Firestore collections without schema doc updates
- Don't store raw user content in logs
