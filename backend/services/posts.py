# backend/services/posts.py
"""Post service layer.

Posts are stored at /posts/{post_id} (uuid4). Counter field author.post_count
is incremented/decremented atomically via Firestore batch writes.
"""

from __future__ import annotations

import asyncio
import uuid
from datetime import datetime
from typing import Any

from google.cloud import firestore
from google.cloud.firestore import DocumentReference, FieldFilter

from core.firebase import db
from models.post import Post
from moderation.engine import moderate_text
from services import follows as follows_service

POSTS_COLLECTION = "posts"


class PostBlocked(Exception):
    """Raised when post text is rejected by the moderation cascade."""

    def __init__(
        self, layer: str | None = None, reason: str | None = None
    ) -> None:
        self.layer = layer
        self.reason = reason
        super().__init__(reason or "Post blocked by content moderation.")


class PostNotFound(Exception):
    """Raised when a requested post document does not exist."""


class NotAuthorized(Exception):
    """Raised when the requesting user may not perform the action."""


def _post_ref(post_id: str) -> DocumentReference:
    return db.collection(POSTS_COLLECTION).document(post_id)


def _user_ref(uid: str) -> DocumentReference:
    return db.collection("users").document(uid)


async def create_post(
    author_uid: str,
    text: str,
    image_url: str | None = None,
) -> Post:
    """Moderate then persist a new post. Atomically increments author.post_count.

    Raises:
        PostBlocked: if the moderation cascade rejects the text.
    """
    result = await moderate_text(text)
    if result.blocked:
        raise PostBlocked(layer=result.layer, reason=result.reason)

    post_id = str(uuid.uuid4())
    now = firestore.SERVER_TIMESTAMP
    post_data: dict[str, Any] = {
        "id": post_id,
        "author_uid": author_uid,
        "text": text,
        "image_url": image_url,
        "status": "approved",
        "like_count": 0,
        "comment_count": 0,
        "created_at": now,
        "updated_at": now,
        "schema_version": 1,
    }

    def _write() -> None:
        batch = db.batch()
        batch.set(_post_ref(post_id), post_data)
        batch.update(_user_ref(author_uid), {"post_count": firestore.Increment(1)})
        batch.commit()

    await asyncio.to_thread(_write)

    # Refetch so the returned model carries resolved server timestamps.
    snap = await asyncio.to_thread(_post_ref(post_id).get)
    return Post.model_validate(snap.to_dict())


async def get_post(post_id: str) -> Post | None:
    """Fetch a single post by ID. Returns None if it doesn't exist."""
    snap = await asyncio.to_thread(_post_ref(post_id).get)
    if not snap.exists:
        return None
    return Post.model_validate(snap.to_dict())


async def delete_post(
    post_id: str,
    requesting_uid: str,
    is_admin: bool = False,
) -> None:
    """Delete a post. Only the author or an admin may delete.

    Atomically decrements author.post_count on success.

    Raises:
        PostNotFound: if the post does not exist.
        NotAuthorized: if requesting_uid is neither the author nor an admin.
    """
    snap = await asyncio.to_thread(_post_ref(post_id).get)
    if not snap.exists:
        raise PostNotFound(post_id)

    data = snap.to_dict() or {}
    author_uid = str(data.get("author_uid", ""))

    if requesting_uid != author_uid and not is_admin:
        raise NotAuthorized(requesting_uid)

    def _delete() -> None:
        batch = db.batch()
        batch.delete(_post_ref(post_id))
        batch.update(_user_ref(author_uid), {"post_count": firestore.Increment(-1)})
        batch.commit()

    await asyncio.to_thread(_delete)


async def get_feed(
    viewer_uid: str,
    limit: int = 20,
    before_created_at: str | None = None,
) -> list[Post]:
    """Pull feed: approved posts from followed users, newest first.

    Uses cursor pagination via `before_created_at` (ISO-format datetime string).
    Returns an empty list when the viewer follows nobody.
    Limit is capped at 20. Firestore `in` queries are chunked at 30 values.

    # TODO: filter out posts from users the viewer has blocked (Step 2 block system)
    """
    following = await follows_service.get_following(viewer_uid)
    if not following:
        return []

    cap = min(limit, 20)

    before_dt: datetime | None = None
    if before_created_at:
        try:
            before_dt = datetime.fromisoformat(before_created_at)
        except ValueError:
            before_dt = None

    def _query() -> list[Post]:
        chunks = [following[i : i + 30] for i in range(0, len(following), 30)]
        all_posts: list[Post] = []

        for chunk in chunks:
            q = (
                db.collection(POSTS_COLLECTION)
                .where(filter=FieldFilter("author_uid", "in", chunk))
                .where(filter=FieldFilter("status", "==", "approved"))
                .order_by("created_at", direction=firestore.Query.DESCENDING)
            )
            if before_dt is not None:
                q = q.where(filter=FieldFilter("created_at", "<", before_dt))

            for snap in q.stream():
                d = snap.to_dict() or {}
                all_posts.append(Post.model_validate(d))

        # Merge chunk results, re-sort globally, then cap to limit.
        all_posts.sort(key=lambda p: p.created_at, reverse=True)
        return all_posts[:cap]

    return await asyncio.to_thread(_query)
