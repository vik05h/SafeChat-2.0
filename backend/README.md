# SafeChat Backend

FastAPI backend for SafeChat. Runs on Cloud Run, uses Firebase Admin SDK for auth and Firestore writes.

## Requirements

- Python 3.13
- A Firebase service account key at `backend/credentials/firebase-admin-key.json` (never commit this)

## Local setup

```powershell
# From the repo root
python -m venv backend/venv
backend\venv\Scripts\Activate.ps1
pip install -r backend/requirements.txt
```

Copy `.env.example` to `.env` and fill in your values:

```powershell
Copy-Item backend\.env.example backend\.env
```

## Running

```powershell
cd backend
uvicorn main:app --reload --port 8080
```

## Testing

```powershell
cd backend
pytest
```

## Project structure

```
backend/
├── main.py            FastAPI app entry point
├── core/
│   ├── config.py      Pydantic Settings (env vars)
│   └── firebase.py    Firebase Admin SDK initialisation
├── middleware/        Auth, rate limiting, logging
├── routes/            API endpoint handlers
├── models/            Pydantic request/response schemas
├── services/          Firebase Admin wrappers, external API clients
└── tests/             Pytest test suite
```

## Environment variables

See `.env.example` for the full list with descriptions.

## Phases

This backend is built in phases. See `docs/ROADMAP.md`.

- **Phase 1 (current):** Project structure, Firebase init, auth middleware, user/profile endpoints
- **Phase 2:** Moderation engine (text + image cascade)
- **Phase 3+:** Social features, DMs, stories, admin panel
