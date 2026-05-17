# backend/services/notifications.py
"""Push notification service — FCM via Firebase Admin SDK.

All sends are fire-and-forget: failures are logged but never raised so that a
missing token or transient FCM error never blocks the calling coroutine.
"""

from __future__ import annotations

import asyncio
import logging

from firebase_admin import messaging

from core.firebase import db

logger = logging.getLogger(__name__)

FCM_TOKENS_COLLECTION = "fcm_tokens"
NOTIFICATION_BODY_MAX = 100


def _send_fcm(message: messaging.Message) -> None:
    """Thin wrapper around messaging.send — monkeypatch seam in tests."""
    messaging.send(message)


async def send_message_notification(
    recipient_uid: str,
    sender_display_name: str,
    message_text: str,
    chat_id: str,
) -> None:
    """Send a new-message push notification to recipient_uid via FCM.

    Fetches the FCM token from /fcm_tokens/{recipient_uid}. If the document
    doesn't exist or carries no token, the function returns silently — the
    user simply hasn't registered for push notifications.

    Both the token-fetch and the FCM send are fail-open: any exception is
    logged at WARNING level and swallowed so that a transient error never
    prevents a message from being delivered in-app.

    Args:
        recipient_uid: UID of the user to notify.
        sender_display_name: Shown as the notification title.
        message_text: Notification body — truncated to 100 chars.
        chat_id: Passed in the data payload for client-side deep-linking.
    """
    # ---- 1. Fetch FCM token -------------------------------------------------
    try:
        snap = await asyncio.to_thread(
            db.collection(FCM_TOKENS_COLLECTION).document(recipient_uid).get
        )
    except Exception as exc:
        logger.warning(
            "Failed to fetch FCM token for uid=%s: %s", recipient_uid, exc
        )
        return

    if not snap.exists:
        logger.info(
            "No FCM token for uid=%s — skipping push notification", recipient_uid
        )
        return

    token: str | None = (snap.to_dict() or {}).get("token")
    if not token:
        logger.info(
            "Empty FCM token for uid=%s — skipping push notification", recipient_uid
        )
        return

    # ---- 2. Build and send FCM message --------------------------------------
    body = message_text[:NOTIFICATION_BODY_MAX]
    fcm_message = messaging.Message(
        notification=messaging.Notification(
            title=sender_display_name,
            body=body,
        ),
        data={"chat_id": chat_id, "type": "new_message"},
        token=token,
    )

    try:
        await asyncio.to_thread(_send_fcm, fcm_message)
    except Exception as exc:
        logger.warning(
            "FCM send failed for uid=%s chat=%s: %s", recipient_uid, chat_id, exc
        )
