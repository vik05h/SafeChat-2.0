# backend/main.py
"""FastAPI application entry point for SafeChat backend."""

from __future__ import annotations

import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core import API_VERSION, firebase  # noqa: F401  — firebase import triggers Admin SDK init
from core.config import get_settings
from routes import health

logger = logging.getLogger(__name__)

API_V1_PREFIX = "/api/v1"


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
    yield
    logger.info("SafeChat API shutting down")


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

    app.include_router(health.router, prefix=API_V1_PREFIX)

    return app


app = create_app()
