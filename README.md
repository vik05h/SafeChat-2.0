# SafeChat

> A social platform where AI automatically blocks bullying, harassment, and toxic content in real time — across messages, posts, comments, and stories.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status: In Development](https://img.shields.io/badge/Status-In%20Development-orange.svg)]()
[![Platform: Web | Android](https://img.shields.io/badge/Platform-Web%20%7C%20Android-blue.svg)]()

---

## What is SafeChat

SafeChat is a global social media platform built on a fundamental premise: **bullying, harassment, and toxic content should never reach the victim in the first place.**

Where Instagram, Twitter, and similar platforms rely on user reports and post-hoc moderation, SafeChat moderates content **before it's stored** — using a backend AI cascade that filters toxic content in real time.

### The problem we solve

Existing platforms moderate reactively. A bully sends a message, the victim sees it, reports it, and *maybe* the platform acts hours or days later. The damage is already done.

SafeChat moderates proactively. Toxic content is blocked at the API layer before it reaches the recipient's screen. No exposure, no report queue, no waiting.

---

## Key Features

- **Real-time Moderation** across messages, posts, comments, stories, and profile content.
- **Cross-platform** — single Flutter codebase running on Android and web browsers.
- **Production-grade infrastructure** on Google Cloud Platform with global CDN.
- **Live keyword management** — moderators update rules without redeployment.
- *(Upcoming)* **Multi-layer AI cascade** combining OpenAI Moderation and Google Gemini for nuanced cases.
- *(Upcoming)* **Image-aware moderation** including OCR on memes to catch overlaid slurs.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile + Web Frontend | Flutter 3.x (Riverpod + GoRouter) |
| Backend API | FastAPI on Google Cloud Run |
| Database | Cloud Firestore (multi-region) |
| Authentication | Firebase Auth (Google + Email/Password) |
| Media Storage | Firebase Storage |
| Text Moderation | TF-IDF Keyword Detection |
| Push Notifications | Firebase Cloud Messaging |

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for system design details.

---

## Project Structure

```
SafeChat-2.0/
├── frontend/                 # Flutter app (Android + Web)
│   ├── lib/
│   │   ├── features/
│   │   ├── core/
│   │   ├── router/
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── ...
│
├── backend/                  # FastAPI server
│   ├── moderation/           # Moderation cascade
│   ├── routes/               # API endpoints
│   ├── models/               # Pydantic schemas
│   ├── services/             # Firebase Admin SDK
│   ├── main.py
│   └── requirements.txt
│
├── docs/                     # All project documentation
│   ├── v0/                   # Legacy documentation (React Native / Expo)
│   ├── ARCHITECTURE.md
│   ├── MODERATION.md
│   ├── API_CONTRACTS.md
│   ├── DATABASE_SCHEMA.md
│   ├── ROADMAP.md
│   ├── UI_DESIGN_SYSTEM.md
│   └── CONTRIBUTING.md
│
├── AGENT.md                  # Unified AI agent instructions
└── README.md
```

---

## Quick Start

### Prerequisites

- Flutter SDK (3.x)
- Python 3.11+
- Firebase project with Auth, Firestore, Storage enabled
- Google Cloud project

### Backend Setup

```bash
cd backend
python -m venv venv
# macOS/Linux: source venv/bin/activate
# Windows: venv\Scripts\activate
pip install -r requirements.txt

# Copy and edit .env with your credentials
cp .env.example .env

uvicorn main:app --reload --port 8000
```

API runs at `http://127.0.0.1:8000`. Interactive docs at `/docs`.

### Frontend Setup

```bash
cd frontend
flutter pub get

# Setup .env file
cp .env.example .env

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android
```

---

## Documentation

| Document | Purpose |
|---|---|
| [Architecture](docs/ARCHITECTURE.md) | System design, hosting, scaling decisions |
| [Moderation Engine](docs/MODERATION.md) | Full AI moderation cascade specification |
| [Design System](docs/UI_DESIGN_SYSTEM.md) | Material 3 & Softer Neobrutalism dual-theme guide |
| [API Contracts](docs/API_CONTRACTS.md) | REST endpoint specifications |
| [Database Schema](docs/DATABASE_SCHEMA.md) | Firestore collections, indexes, security rules |
| [Roadmap](docs/ROADMAP.md) | Phased build plan and feature timeline |
| [Contributing](docs/CONTRIBUTING.md) | Code style, branch strategy, PR process |

---

## Development Status

SafeChat is currently in active development. See [Roadmap](docs/ROADMAP.md) for the phased build plan.

**Current phase:** Phase 0/1 — Project foundation and infrastructure setup.

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) before opening a pull request.

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
