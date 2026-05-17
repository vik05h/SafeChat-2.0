# backend/core/storage.py
"""Google Cloud Storage client initialisation.

Uses explicit service-account credentials (the same key file as Firebase Admin)
so that Blob.generate_signed_url() has a Signer available. The firebase_admin
bucket returned by storage.bucket() may rely on ADC which lacks signing support.
"""

from __future__ import annotations

import logging

from google.cloud import storage as gcs
from google.cloud.storage import Bucket, Client
from google.oauth2 import service_account

from core.config import get_settings

logger = logging.getLogger(__name__)


def _init_storage() -> tuple[Client, Bucket]:
    settings = get_settings()
    creds = service_account.Credentials.from_service_account_file(
        str(settings.firebase_admin_key_path),
        scopes=["https://www.googleapis.com/auth/cloud-platform"],
    )
    client = gcs.Client(project=settings.gcp_project_id, credentials=creds)
    bucket = client.bucket(settings.storage_bucket_name)
    logger.info(
        "GCS storage client initialised (bucket=%s)", settings.storage_bucket_name
    )
    return client, bucket


storage_client, bucket = _init_storage()

__all__ = ["storage_client", "bucket"]
