# backend/services/blocks.py
"""Block relationship service.

Blocks are unidirectional and stored at /blocks/{blocker_uid}_{blocked_uid}.
`block_user` and `unblock_user` are both idempotent.
"""

from __future__ import annotations

import asyncio

from google.cloud import firestore
from google.cloud.firestore import DocumentReference, FieldFilter

from core.firebase import db

BLOCKS_COLLECTION = "blocks"


class CannotBlockSelf(Exception):
    """Raised when a user attempts to block themselves."""


def _block_id(blocker_uid: str, blocked_uid: str) -> str:
    return f"{blocker_uid}_{blocked_uid}"


def _block_ref(blocker_uid: str, blocked_uid: str) -> DocumentReference:
    return db.collection(BLOCKS_COLLECTION).document(
        _block_id(blocker_uid, blocked_uid)
    )


async def block_user(blocker_uid: str, blocked_uid: str) -> None:
    """Block a user. Idempotent — a no-op (no rewrite) if already blocked.

    Raises:
        CannotBlockSelf: if blocker_uid == blocked_uid.
    """
    if blocker_uid == blocked_uid:
        raise CannotBlockSelf(blocker_uid)

    ref = _block_ref(blocker_uid, blocked_uid)

    def _create() -> None:
        if ref.get().exists:
            return  # Already blocked — preserve original created_at.
        ref.set(
            {
                "blocker_uid": blocker_uid,
                "blocked_uid": blocked_uid,
                "created_at": firestore.SERVER_TIMESTAMP,
            }
        )

    await asyncio.to_thread(_create)


async def unblock_user(blocker_uid: str, blocked_uid: str) -> None:
    """Unblock a user. Idempotent — Firestore delete of a missing doc is a no-op."""
    await asyncio.to_thread(_block_ref(blocker_uid, blocked_uid).delete)


async def is_blocked(blocker_uid: str, blocked_uid: str) -> bool:
    """Return True if blocker_uid has blocked blocked_uid. Unidirectional."""
    snapshot = await asyncio.to_thread(_block_ref(blocker_uid, blocked_uid).get)
    return bool(snapshot.exists)


async def get_blocked_users(blocker_uid: str) -> list[str]:
    """Return the list of uids that blocker_uid has blocked."""

    def _query() -> list[str]:
        stream = (
            db.collection(BLOCKS_COLLECTION)
            .where(filter=FieldFilter("blocker_uid", "==", blocker_uid))
            .stream()
        )
        return [
            str((snapshot.to_dict() or {}).get("blocked_uid", ""))
            for snapshot in stream
        ]

    return await asyncio.to_thread(_query)
