# backend/services/likes.py
"""Like/unlike service.

Likes are stored at /posts/{post_id}/likes/{user_uid} (subcollection).
post.like_count is kept in sync via batch writes alongside the like document.
"""

from __future__ import annotations

import asyncio

from google.cloud import firestore
from google.cloud.firestore import DocumentReference

from core.firebase import db

POSTS_COLLECTION = "posts"
LIKES_SUBCOLLECTION = "likes"


def _like_ref(post_id: str, user_uid: str) -> DocumentReference:
    return (
        db.collection(POSTS_COLLECTION)
        .document(post_id)
        .collection(LIKES_SUBCOLLECTION)
        .document(user_uid)
    )


def _post_ref(post_id: str) -> DocumentReference:
    return db.collection(POSTS_COLLECTION).document(post_id)


async def like_post(user_uid: str, post_id: str) -> None:
    """Like a post. Idempotent — no-op if already liked.

    Atomically creates the like document and increments post.like_count.
    """
    def _write() -> None:
        like_ref = _like_ref(post_id, user_uid)
        if like_ref.get().exists:
            return  # Already liked — preserve original created_at.
        batch = db.batch()
        batch.set(
            like_ref,
            {
                "user_uid": user_uid,
                "post_id": post_id,
                "created_at": firestore.SERVER_TIMESTAMP,
            },
        )
        batch.update(_post_ref(post_id), {"like_count": firestore.Increment(1)})
        batch.commit()

    await asyncio.to_thread(_write)


async def unlike_post(user_uid: str, post_id: str) -> None:
    """Unlike a post. Idempotent — no-op if not currently liked.

    Atomically deletes the like document and decrements post.like_count.
    """
    def _delete() -> None:
        like_ref = _like_ref(post_id, user_uid)
        if not like_ref.get().exists:
            return  # Not liked — nothing to undo.
        batch = db.batch()
        batch.delete(like_ref)
        batch.update(_post_ref(post_id), {"like_count": firestore.Increment(-1)})
        batch.commit()

    await asyncio.to_thread(_delete)


async def is_liked(user_uid: str, post_id: str) -> bool:
    """Return True if user_uid has liked post_id."""
    snap = await asyncio.to_thread(_like_ref(post_id, user_uid).get)
    return bool(snap.exists)


async def get_like_count(post_id: str) -> int:
    """Return the current like_count from the post document."""
    snap = await asyncio.to_thread(_post_ref(post_id).get)
    if not snap.exists:
        return 0
    return int((snap.to_dict() or {}).get("like_count", 0))
