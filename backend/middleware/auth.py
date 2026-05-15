# backend/middleware/auth.py
"""Firebase Auth middleware.

Exposes `get_current_user_claims` — a FastAPI dependency that extracts a Bearer
token from the Authorization header, verifies it via the Firebase Admin SDK,
and returns the decoded claims dictionary. All auth failures raise
HTTPException(401) with a structured detail; main.py reshapes it into the
standard error envelope.
"""

from __future__ import annotations

import asyncio
from typing import Any

from fastapi import Depends, HTTPException, Security
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from core.firebase import auth

bearer_scheme = HTTPBearer(auto_error=False)


def _unauthenticated(message: str) -> HTTPException:
    return HTTPException(
        status_code=401,
        detail={"code": "UNAUTHENTICATED", "message": message},
    )


async def get_current_user_claims(
    credentials: HTTPAuthorizationCredentials | None = Security(bearer_scheme),
) -> dict[str, Any]:
    """Verify the Authorization Bearer token and return the decoded claims.

    Raises:
        HTTPException(401): if the header is missing/malformed or the token is
        invalid, expired, revoked, or belongs to a disabled user.
    """
    if credentials is None:
        raise _unauthenticated(
            "Missing or malformed Authorization header. Expected: Bearer <token>."
        )

    try:
        decoded: dict[str, Any] = await asyncio.to_thread(
            auth.verify_id_token, credentials.credentials, check_revoked=True
        )
    except auth.ExpiredIdTokenError as exc:
        raise _unauthenticated("ID token has expired.") from exc
    except auth.RevokedIdTokenError as exc:
        raise _unauthenticated("ID token has been revoked.") from exc
    except auth.UserDisabledError as exc:
        raise _unauthenticated("User account has been disabled.") from exc
    except (auth.InvalidIdTokenError, auth.CertificateFetchError, ValueError) as exc:
        raise _unauthenticated("Invalid ID token.") from exc

    return decoded


async def require_admin(
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> dict[str, Any]:
    """FastAPI dependency that requires the `admin` custom claim.

    Builds on top of `get_current_user_claims` so token verification happens
    exactly once per request. Raises 403 FORBIDDEN if the verified user is
    authenticated but not an admin.
    """
    if not claims.get("admin"):
        raise HTTPException(
            status_code=403,
            detail={"code": "FORBIDDEN", "message": "Admin access required."},
        )
    return claims
