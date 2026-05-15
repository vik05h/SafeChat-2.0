# backend/main.py
"""FastAPI application entry point for SafeChat backend."""

from __future__ import annotations

import logging
import uuid
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from typing import Any

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from core import API_VERSION, firebase  # noqa: F401  — firebase import triggers Admin SDK init
from core.config import get_settings
from moderation.keyword_filter import keyword_filter
from routes import auth as auth_routes
from routes import health

logger = logging.getLogger(__name__)

API_V1_PREFIX = "/api/v1"

_DEFAULT_ERROR_CODES: dict[int, str] = {
    400: "INVALID_INPUT",
    401: "UNAUTHENTICATED",
    403: "FORBIDDEN",
    404: "NOT_FOUND",
    409: "CONFLICT",
    422: "MODERATION_BLOCKED",
    429: "RATE_LIMITED",
    500: "INTERNAL_ERROR",
    503: "SERVICE_UNAVAILABLE",
}

# Pydantic loc tuples are prefixed with the source (body / query / path / header / cookie).
# We strip the prefix so error.field is the actual user-facing field name.
_VALIDATION_LOC_PREFIXES = {"body", "query", "path", "header", "cookie"}


def _make_meta() -> dict[str, str]:
    return {
        "request_id": str(uuid.uuid4()),
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


def _envelope_error(
    *,
    status_code: int,
    code: str,
    message: str,
    field: str | None = None,
) -> JSONResponse:
    error: dict[str, Any] = {"code": code, "message": message}
    if field:
        error["field"] = field
    return JSONResponse(
        status_code=status_code,
        content={"error": error, "meta": _make_meta()},
    )


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Application startup and shutdown hooks."""
    settings = get_settings()
    logging.basicConfig(level=settings.log_level.upper())
    logger.info(
        "SafeChat API starting (environment=%s, project=%s)",
        settings.environment,
        settings.gcp_project_id,
    )

    # Prime the keyword cache before serving requests, then poll in the
    # background. Failures inside refresh() are logged, not raised — the
    # cascade has other layers, so we fail open on this one.
    await keyword_filter.refresh()
    await keyword_filter.start_background_refresh()

    try:
        yield
    finally:
        await keyword_filter.stop_background_refresh()
        logger.info("SafeChat API shutting down")


async def _http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """Reshape HTTPException into the standard error envelope.

    Handlers and dependencies may raise HTTPException with `detail` as either:
      - a dict like {"code": "...", "message": "...", "field": "..."}, or
      - a plain string (falls back to the default code for the status).
    """
    detail: Any = exc.detail
    if isinstance(detail, dict):
        code = detail.get("code") or _DEFAULT_ERROR_CODES.get(exc.status_code, "ERROR")
        message = detail.get("message", "")
        field = detail.get("field")
    else:
        code = _DEFAULT_ERROR_CODES.get(exc.status_code, "ERROR")
        message = str(detail) if detail is not None else ""
        field = None

    return _envelope_error(
        status_code=exc.status_code, code=code, message=message, field=field
    )


async def _validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    """Convert FastAPI's default 422 validation errors into 400 INVALID_INPUT.

    The contract reserves 422 for MODERATION_BLOCKED, so structural validation
    failures use 400 instead. The first error's field path is surfaced as
    `error.field` for client convenience.
    """
    errors = exc.errors()
    field: str | None = None
    message = "Request validation failed."

    if errors:
        first = errors[0]
        loc = first.get("loc", ())
        # Drop the source prefix ("body", "query", etc.) — clients only care
        # about the user-facing field path.
        loc_parts = [str(p) for p in loc if p not in _VALIDATION_LOC_PREFIXES]
        if loc_parts:
            field = ".".join(loc_parts)
        message = first.get("msg", message)

    return _envelope_error(
        status_code=400, code="INVALID_INPUT", message=message, field=field
    )


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI(
        title="SafeChat API",
        version=API_VERSION,
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.backend_cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.add_exception_handler(HTTPException, _http_exception_handler)
    app.add_exception_handler(RequestValidationError, _validation_exception_handler)

    app.include_router(health.router, prefix=API_V1_PREFIX)
    app.include_router(auth_routes.router, prefix=API_V1_PREFIX)

    return app


app = create_app()
