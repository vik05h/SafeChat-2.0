# backend/services/messages.py
"""Direct-messaging service layer.

Chats live at /chats/{chat_id}.
Messages live at /chats/{chat_id}/messages/{message_id}.

Chat IDs are deterministic: "{min(uid_a, uid_b)}_{max(uid_a, uid_b)}", so
there is always at most one chat document between any user-pair regardless of
which side initiates.
"""

from __future__ import annotations

import asyncio
import logging
import uuid
from datetime import datetime
from typing import Any

from google.cloud import firestore
from google.cloud.firestore import DocumentReference, FieldFilter

from core.firebase import db
from models.message import Chat, Message
from moderation.engine import moderate_text
from services.notifications import send_message_notification

logger = logging.getLogger(__name__)

CHATS_COLLECTION = "chats"
MESSAGES_SUBCOLLECTION = "messages"
USERS_COLLECTION = "users"


class CannotMessageSelf(Exception):
    """Raised when a user tries to start a chat with themselves."""


class MessageBlocked(Exception):
    """Raised when message text is rejected by the moderation cascade."""

    def __init__(
        self, layer: str | None = None, reason: str | None = None
    ) -> None:
        self.layer = layer
        self.reason = reason
        super().__init__(reason or "Message blocked by content moderation.")


class NotAuthorized(Exception):
    """Raised when the requesting user is not a participant in the chat."""


class ChatNotFound(Exception):
    """Raised when the requested chat document does not exist."""


class MessageNotFound(Exception):
    """Raised when the requested message document does not exist."""


def _chat_ref(chat_id: str) -> DocumentReference:
    return db.collection(CHATS_COLLECTION).document(chat_id)


def _message_ref(chat_id: str, message_id: str) -> DocumentReference:
    return (
        db.collection(CHATS_COLLECTION)
        .document(chat_id)
        .collection(MESSAGES_SUBCOLLECTION)
        .document(message_id)
    )


async def get_or_create_chat(uid_a: str, uid_b: str) -> Chat:
    """Return the chat between uid_a and uid_b, creating it if it doesn't exist.

    The chat_id is deterministic so there is always at most one chat document
    per user-pair regardless of call order.

    Raises:
        CannotMessageSelf: if uid_a == uid_b.
    """
    if uid_a == uid_b:
        raise CannotMessageSelf("You cannot start a chat with yourself.")

    chat_id = f"{min(uid_a, uid_b)}_{max(uid_a, uid_b)}"

    snap = await asyncio.to_thread(_chat_ref(chat_id).get)
    if snap.exists:
        return Chat.model_validate(snap.to_dict())

    now = firestore.SERVER_TIMESTAMP
    chat_data: dict[str, Any] = {
        "id": chat_id,
        "participants": sorted([uid_a, uid_b]),
        "last_message_text": None,
        "last_message_at": None,
        "created_at": now,
        "updated_at": now,
        "schema_version": 1,
    }

    await asyncio.to_thread(_chat_ref(chat_id).set, chat_data)

    # Refetch to resolve SERVER_TIMESTAMP.
    snap = await asyncio.to_thread(_chat_ref(chat_id).get)
    return Chat.model_validate(snap.to_dict())


async def send_message(
    chat_id: str,
    sender_uid: str,
    text: str,
    image_url: str | None = None,
) -> Message:
    """Moderate then persist a message; atomically updates chat metadata.

    After the message is stored a fire-and-forget push notification is sent
    to the other participant via FCM. Notification failures are silently
    swallowed and never affect the returned Message.

    Args:
        chat_id: The chat document ID.
        sender_uid: UID of the sender — must be a participant.
        text: Message body (1–1000 chars, validated at route level).
        image_url: Optional image attachment URL.

    Raises:
        ChatNotFound: if the chat document does not exist.
        NotAuthorized: if sender_uid is not a participant in the chat.
        MessageBlocked: if the moderation cascade rejects the text.
    """
    chat_snap = await asyncio.to_thread(_chat_ref(chat_id).get)
    if not chat_snap.exists:
        raise ChatNotFound(chat_id)

    chat_data = chat_snap.to_dict() or {}
    if sender_uid not in chat_data.get("participants", []):
        raise NotAuthorized(sender_uid)

    result = await moderate_text(text)
    if result.blocked:
        raise MessageBlocked(layer=result.layer, reason=result.reason)

    message_id = str(uuid.uuid4())
    now = firestore.SERVER_TIMESTAMP
    message_data: dict[str, Any] = {
        "id": message_id,
        "chat_id": chat_id,
        "sender_uid": sender_uid,
        "text": text,
        "image_url": image_url,
        "read_at": None,
        "created_at": now,
        "updated_at": now,
        "schema_version": 1,
    }

    def _write() -> None:
        batch = db.batch()
        batch.set(_message_ref(chat_id, message_id), message_data)
        batch.update(
            _chat_ref(chat_id),
            {
                "last_message_text": text,
                "last_message_at": firestore.SERVER_TIMESTAMP,
                "updated_at": firestore.SERVER_TIMESTAMP,
            },
        )
        batch.commit()

    await asyncio.to_thread(_write)

    # Refetch to resolve SERVER_TIMESTAMP.
    snap = await asyncio.to_thread(_message_ref(chat_id, message_id).get)
    message = Message.model_validate(snap.to_dict())

    # Fire-and-forget push notification to the other participant.
    # Runs after the message is already stored so delivery is never blocked
    # by a missing token or a transient FCM error.
    participants = chat_data.get("participants", [])
    recipient_uid = next((uid for uid in participants if uid != sender_uid), None)
    if recipient_uid:
        sender_snap = await asyncio.to_thread(
            db.collection(USERS_COLLECTION).document(sender_uid).get
        )
        display_name: str = (
            (sender_snap.to_dict() or {}).get("display_name") or "Someone"
        )
        asyncio.create_task(
            send_message_notification(recipient_uid, display_name, text, chat_id)
        )

    return message


async def get_messages(
    chat_id: str,
    requesting_uid: str,
    limit: int = 50,
    before_created_at: str | None = None,
) -> list[Message]:
    """Return messages in a chat, newest first.

    Cursor pagination via `before_created_at` (ISO-format datetime string).
    Limit is capped at 50.

    Raises:
        ChatNotFound: if the chat document does not exist.
        NotAuthorized: if requesting_uid is not a participant.
    """
    chat_snap = await asyncio.to_thread(_chat_ref(chat_id).get)
    if not chat_snap.exists:
        raise ChatNotFound(chat_id)

    chat_data = chat_snap.to_dict() or {}
    if requesting_uid not in chat_data.get("participants", []):
        raise NotAuthorized(requesting_uid)

    cap = min(limit, 50)

    before_dt: datetime | None = None
    if before_created_at:
        try:
            before_dt = datetime.fromisoformat(before_created_at)
        except ValueError:
            before_dt = None

    def _query() -> list[Message]:
        q = (
            db.collection(CHATS_COLLECTION)
            .document(chat_id)
            .collection(MESSAGES_SUBCOLLECTION)
            .order_by("created_at", direction=firestore.Query.DESCENDING)
        )
        if before_dt is not None:
            q = q.where(filter=FieldFilter("created_at", "<", before_dt))
        q = q.limit(cap)
        return [
            Message.model_validate(snap.to_dict())
            for snap in q.stream()
            if snap.to_dict()
        ]

    return await asyncio.to_thread(_query)


async def get_chats(uid: str) -> list[Chat]:
    """Return all chats the user participates in, ordered by last_message_at desc.

    Args:
        uid: The requesting user's UID.
    """

    def _query() -> list[Chat]:
        q = (
            db.collection(CHATS_COLLECTION)
            .where(filter=FieldFilter("participants", "array_contains", uid))
            .order_by("last_message_at", direction=firestore.Query.DESCENDING)
        )
        return [Chat.model_validate(snap.to_dict()) for snap in q.stream()]

    return await asyncio.to_thread(_query)


async def mark_read(
    chat_id: str,
    message_id: str,
    reader_uid: str,
) -> None:
    """Mark a message as read by setting its read_at to SERVER_TIMESTAMP.

    Raises:
        ChatNotFound: if the chat document does not exist.
        NotAuthorized: if reader_uid is not a participant.
        MessageNotFound: if the message document does not exist.
    """
    chat_snap = await asyncio.to_thread(_chat_ref(chat_id).get)
    if not chat_snap.exists:
        raise ChatNotFound(chat_id)

    chat_data = chat_snap.to_dict() or {}
    if reader_uid not in chat_data.get("participants", []):
        raise NotAuthorized(reader_uid)

    msg_snap = await asyncio.to_thread(_message_ref(chat_id, message_id).get)
    if not msg_snap.exists:
        raise MessageNotFound(message_id)

    await asyncio.to_thread(
        _message_ref(chat_id, message_id).update,
        {"read_at": firestore.SERVER_TIMESTAMP},
    )
