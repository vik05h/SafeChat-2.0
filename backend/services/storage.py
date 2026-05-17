# backend/services/storage.py
"""Image upload service — signed URL generation and public URL resolution.

generate_upload_url() is synchronous: signing is pure CPU work (no network I/O)
and fast enough to call directly from an async route handler.
"""

from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from core.storage import bucket
from models.storage import UploadUrlResponse

SIGNED_URL_TTL_MINUTES = 15

_CONTENT_TYPE_TO_EXT: dict[str, str] = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "image/webp": "webp",
}


class InvalidContentType(Exception):
    """Raised when an unsupported content type is requested."""


def generate_upload_url(
    uid: str,
    content_type: str,
    purpose: str,
) -> UploadUrlResponse:
    """Generate a signed GCS upload URL for the given user, content type, and purpose.

    Object path format: uploads/{purpose}/{uid}/{uuid4()}.{ext}

    The returned URL is valid for SIGNED_URL_TTL_MINUTES minutes and accepts
    a single HTTP PUT of the specified content type.

    Args:
        uid: The authenticated user's UID.
        content_type: MIME type — must be image/jpeg, image/png, or image/webp.
        purpose: Intended use — "post", "story", or "avatar".

    Raises:
        InvalidContentType: if content_type is not one of the allowed values.
    """
    ext = _CONTENT_TYPE_TO_EXT.get(content_type)
    if ext is None:
        raise InvalidContentType(content_type)

    object_path = f"uploads/{purpose}/{uid}/{uuid.uuid4()}.{ext}"
    expiration = timedelta(minutes=SIGNED_URL_TTL_MINUTES)
    expires_at = datetime.now(timezone.utc) + expiration

    blob = bucket.blob(object_path)
    upload_url: str = blob.generate_signed_url(
        expiration=expiration,
        method="PUT",
        content_type=content_type,
        version="v4",
    )

    return UploadUrlResponse(
        upload_url=upload_url,
        object_path=object_path,
        expires_at=expires_at,
    )


def get_public_url(object_path: str) -> str:
    """Return the public GCS URL for the given object path.

    Format: https://storage.googleapis.com/{bucket}/{object_path}
    """
    from core.config import get_settings

    bucket_name = get_settings().storage_bucket_name
    return f"https://storage.googleapis.com/{bucket_name}/{object_path}"
