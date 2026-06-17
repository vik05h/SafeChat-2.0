# SafeChat

> A social platform where AI automatically blocks bullying, harassment, and toxic content in real time — across messages, posts, comments, and stories.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status: In Development](https://img.shields.io/badge/Status-In%20Development-orange.svg)]()
[![Platform: Web | Android](https://img.shields.io/badge/Platform-Web%20%7C%20Android-blue.svg)]()

---

## What is SafeChat

SafeChat is a global social media platform built on a fundamental premise: **bullying, harassment, and toxic content should never reach the victim in the first place.**

Where Instagram, Twitter, and similar platforms rely on user reports and post-hoc moderation, SafeChat moderates content **before it's stored** — using a multi-tier AI cascade that filters text, emojis, images, and image-overlaid text in real time.

### The problem we solve

Existing platforms moderate reactively. A bully sends a message, the victim sees it, reports it, and *maybe* the platform acts hours or days later. The damage is already done.

SafeChat moderates proactively. Toxic content is blocked at the API layer before it reaches the recipient's screen. No exposure, no report queue, no waiting.

### Who it's for

Global audience. Multilingual moderation (English, Hindi, Hinglish at launch, expandable). Available on Android (Play Store) and Web (browser).

---

## Key Features

- **Real-time AI moderation** across messages, posts, comments, stories, and profile content
- **Multi-layer cascade** combining dynamic keyword filtering, OpenAI Moderation, and Google Gemini for nuanced cases
- **Image-aware moderation** including OCR on memes to catch overlaid slurs
- **Cross-platform** — single codebase running on Android and web browsers
- **Production-grade infrastructure** on Google Cloud Platform with global CDN
- **Live keyword management** — moderators update rules without redeployment

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile + Web Frontend | Expo (React Native + React Native Web) |
| Backend API | FastAPI on Google Cloud Run |
| Database | Cloud Firestore (multi-region) |
| Authentication | Firebase Auth (Google + Email/Password) |
| Media Storage | Firebase Storage |
| Web Hosting | Firebase Hosting |
| Text Moderation | OpenAI Moderation API + Google Gemini |
| Image Moderation | Google Cloud Vision (Safe Search + OCR) |
| Push Notifications | Firebase Cloud Messaging |
| Voice/Video Calls | Agora SDK |
| CI/CD | GitHub Actions |

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for system design details.

---

## Project Structure

```
SafeChat-2.0/
├── app/                      # Expo app (Android + Web)
│   ├── src/
│   │   ├── screens/
│   │   ├── components/
│   │   ├── services/         # Firebase, API client
│   │   └── utils/
│   ├── app.json
│   └── package.json
│
├── backend/                  # FastAPI server
│   ├── moderation/           # AI moderation cascade
│   │   ├── keyword_filter.py
│   │   ├── normalizer.py
│   │   ├── openai_moderation.py
│   │   ├── gemini_moderation.py
│   │   ├── vision_moderation.py
│   │   └── engine.py
│   ├── routes/               # API endpoints
│   ├── models/               # Pydantic schemas
│   ├── services/             # Firebase Admin SDK
│   ├── tests/
│   ├── credentials/          # .gitignored
│   ├── .env                  # .gitignored
│   ├── main.py
│   └── requirements.txt
│
├── admin/                    # Admin moderation panel
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
├── .github/
│   └── workflows/            # CI/CD pipelines
│
├── .gitignore
└── README.md
```

---

## Quick Start

### Prerequisites

- Node.js 20+
- Python 3.11+
- Firebase project with Auth, Firestore, Storage enabled
- OpenAI API key (Moderation API)
- Google Cloud project with Vision API + Gemini enabled
- Agora SDK account (for calls, optional in v1)

### Backend Setup

```bash
cd backend
python -m venv venv
source venv/bin/activate            # macOS/Linux
# venv\Scripts\activate              # Windows
pip install -r requirements.txt

cp .env.example .env
# Edit .env with your credentials

uvicorn main:app --reload --port 8000
```

API runs at `http://127.0.0.1:8000`. Interactive docs at `/docs`.

### Frontend Setup

```bash
cd app
npm install

cp .env.example .env
# Edit .env with Firebase web config

# Run on web
npx expo start --web

# Run on Android (requires Android Studio or physical device)
npx expo start --android
```

### Environment Variables

**`backend/.env`:**
```
FIREBASE_ADMIN_KEY_PATH=./credentials/firebase-admin-key.json
OPENAI_API_KEY=sk-...
GEMINI_API_KEY=...
GCP_PROJECT_ID=safechat-prod-66143
ENVIRONMENT=development
```

**`app/.env`:**
```
EXPO_PUBLIC_API_BASE_URL=http://127.0.0.1:8000
EXPO_PUBLIC_FIREBASE_API_KEY=...
EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN=safechat-prod-66143.firebaseapp.com
EXPO_PUBLIC_FIREBASE_PROJECT_ID=safechat-prod-66143
EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET=safechat-prod-66143.firebasestorage.app
EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=...
EXPO_PUBLIC_FIREBASE_APP_ID=...
```

---

## Documentation

| Document | Purpose |
|---|---|
| [Architecture](docs/ARCHITECTURE.md) | System design, hosting, scaling decisions |
| [Moderation Engine](docs/MODERATION.md) | Full AI moderation cascade specification |
| [API Contracts](docs/API_CONTRACTS.md) | REST endpoint specifications |
| [Database Schema](docs/DATABASE_SCHEMA.md) | Firestore collections, indexes, security rules |
| [Roadmap](docs/ROADMAP.md) | Phased build plan and feature timeline |
| [Contributing](docs/CONTRIBUTING.md) | Code style, branch strategy, PR process |
| [Privacy Policy](docs/legal/PRIVACY_POLICY.md) | User data handling |
| [Terms of Service](docs/legal/TERMS_OF_SERVICE.md) | Platform terms |
| [Community Guidelines](docs/legal/COMMUNITY_GUIDELINES.md) | User behavior standards |

---

## Development Status

SafeChat is currently in active development. See [Roadmap](docs/ROADMAP.md) for the phased build plan.

**Current phase:** Phase 0 — Project foundation and infrastructure setup.

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) before opening a pull request.

For significant changes, open an issue first to discuss the proposed direction.

---

## Maintainer

**Adnan Zeya**
B.Tech CSE, SRM Institute of Science and Technology
GitHub: [@ADNAN-ZEYA](https://github.com/ADNAN-ZEYA)

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Acknowledgements

- Predecessor project: [SafeChat v1](https://github.com/ADNAN-ZEYA/SafeChat) — Best Project Award, SRM DevOps Expo 2026
- Inspired by the absence of proactive moderation in mainstream social platforms
