# backend/core/firebase.py
"""Firebase Admin SDK initialisation.

Importing this module initialises the default Firebase app exactly once.
Downstream code imports `db`, `auth`, and `bucket` directly.
"""

from __future__ import annotations

import logging

import firebase_admin
from firebase_admin import auth, credentials, firestore, storage
from google.cloud.firestore import Client as FirestoreClient
from google.cloud.storage import Bucket

from core.config import get_settings

logger = logging.getLogger(__name__)


def _initialise_app() -> firebase_admin.App:
    """Initialise the default Firebase Admin app, or return the existing one."""
    try:
        return firebase_admin.get_app()
    except ValueError:
        pass  # No app yet — fall through and create one.

    settings = get_settings()

    try:
        cred = credentials.Certificate(str(settings.firebase_admin_key_path))
    except FileNotFoundError as exc:
        raise RuntimeError(
            f"Firebase Admin key not found at {settings.firebase_admin_key_path}"
        ) from exc
    except ValueError as exc:
        raise RuntimeError(
            f"Firebase Admin key file is not valid JSON credentials: {exc}"
        ) from exc

    app = firebase_admin.initialize_app(
        cred,
        {
            "projectId": settings.gcp_project_id,
            "storageBucket": settings.storage_bucket_name,
        },
    )
    logger.info(
        "Firebase Admin SDK initialised (project=%s, bucket=%s)",
        settings.gcp_project_id,
        settings.storage_bucket_name,
    )
    return app


_app: firebase_admin.App = _initialise_app()

db: FirestoreClient = firestore.client()
bucket: Bucket = storage.bucket()

__all__ = ["db", "auth", "bucket"]
