# backend/core/config.py
"""Application configuration loaded from environment variables.

Settings are loaded once and cached via lru_cache so the entire app shares a
single Settings instance. Required values raise at startup if missing — fail
fast rather than discover a misconfiguration mid-request.
"""

from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

_BACKEND_DIR = Path(__file__).resolve().parent.parent
_REPO_ROOT = _BACKEND_DIR.parent
_ENV_FILE = _BACKEND_DIR / ".env"

Environment = Literal["development", "staging", "production"]

_DEFAULT_CORS_ORIGINS: list[str] = [
    "http://localhost:8081",
    "http://localhost:19006",
    "http://localhost:3000",
]


class Settings(BaseSettings):
    """Validated application settings sourced from environment / .env file."""

    model_config = SettingsConfigDict(
        env_file=_ENV_FILE,
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ---- Required ---------------------------------------------------------
    firebase_admin_key_path: Path = Field(
        ..., description="Filesystem path to the Firebase Admin SDK JSON key."
    )
    gcp_project_id: str = Field(
        ..., min_length=1, description="GCP / Firebase project ID."
    )

    # ---- Optional now, required in Phase 2 --------------------------------
    # OpenAI Moderation API key. Becomes required once the moderation cascade
    # is wired up in Phase 2.
    openai_api_key: str | None = Field(
        default=None, description="OpenAI Moderation API key (required in Phase 2)."
    )

    # ---- With defaults ----------------------------------------------------
    environment: Environment = Field(
        default="development", description="Runtime environment."
    )
    log_level: str = Field(default="INFO", description="Python logging level.")
    port: int = Field(default=8080, ge=1, le=65535)
    backend_cors_origins: list[str] = Field(
        default_factory=lambda: list(_DEFAULT_CORS_ORIGINS)
    )
    firebase_storage_bucket: str | None = Field(
        default=None,
        description="Storage bucket. Defaults to {gcp_project_id}.firebasestorage.app.",
    )

    @field_validator("firebase_admin_key_path")
    @classmethod
    def _resolve_and_check_key_path(cls, value: Path) -> Path:
        # Relative paths are resolved against the repo root, not CWD,
        # so the app behaves the same whether run from / or from /backend.
        resolved = value if value.is_absolute() else (_REPO_ROOT / value).resolve()
        if not resolved.is_file():
            raise ValueError(
                f"FIREBASE_ADMIN_KEY_PATH does not point to a file: {resolved}"
            )
        return resolved

    @field_validator("backend_cors_origins", mode="before")
    @classmethod
    def _split_cors(cls, value: str | list[str]) -> list[str]:
        if isinstance(value, str):
            return [o.strip() for o in value.split(",") if o.strip()]
        return value

    @property
    def storage_bucket_name(self) -> str:
        return self.firebase_storage_bucket or f"{self.gcp_project_id}.firebasestorage.app"

    @property
    def is_production(self) -> bool:
        return self.environment == "production"


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return the cached singleton Settings instance."""
    return Settings()  # type: ignore[call-arg]
