# backend/services/users.py
"""User service layer.

Operations against /users/{uid} and /usernames/{username}. Username reservation
and profile creation happen in a single Firestore transaction so the two
documents can never get out of sync.
"""

from __future__ import annotations

import asyncio

from google.cloud import firestore
from google.cloud.firestore import DocumentReference, Transaction

from core.firebase import db
from models.user import UserProfile


class UsernameTaken(Exception):
    """Raised when the requested username is already owned by a different uid."""


class AlreadyOnboarded(Exception):
    """Raised when /users/{uid} already exists."""


def _username_ref(username: str) -> DocumentReference:
    return db.collection("usernames").document(username)


def _user_ref(uid: str) -> DocumentReference:
    return db.collection("users").document(uid)


async def reserve_username(
    *,
    uid: str,
    email: str | None,
    username: str,
    display_name: str,
    bio: str,
) -> UserProfile:
    """Atomically reserve a username and create the user profile.

    Both /usernames/{username} and /users/{uid} are written in a single
    transaction. A pre-existing username doc owned by the same uid is treated
    as a recoverable retry (e.g. previous onboarding attempt crashed after
    reservation but before user-doc write); a pre-existing user doc is not.

    Raises:
        UsernameTaken: /usernames/{username} exists and belongs to another uid.
        AlreadyOnboarded: /users/{uid} already exists.
    """
    username_ref = _username_ref(username)
    user_ref = _user_ref(uid)

    @firestore.transactional
    def _txn(transaction: Transaction) -> None:
        # All reads must happen before any writes within a Firestore txn.
        username_snap = username_ref.get(transaction=transaction)
        user_snap = user_ref.get(transaction=transaction)

        if username_snap.exists:
            owner_uid = (username_snap.to_dict() or {}).get("uid")
            if owner_uid != uid:
                raise UsernameTaken(username)

        if user_snap.exists:
            raise AlreadyOnboarded(uid)

        now = firestore.SERVER_TIMESTAMP
        transaction.set(
            username_ref,
            {"username": username, "uid": uid, "reserved_at": now},
        )
        transaction.set(
            user_ref,
            {
                "uid": uid,
                "email": email or "",
                "username": username,
                "display_name": display_name,
                "bio": bio,
                "photo_url": None,
                "follower_count": 0,
                "following_count": 0,
                "post_count": 0,
                "is_verified": False,
                "is_suspended": False,
                "created_at": now,
                "updated_at": now,
                "last_active_at": now,
                "private_account": False,
                "allow_messages_from": "everyone",
                "schema_version": 1,
            },
        )

    await asyncio.to_thread(_txn, db.transaction())

    # Refetch so the returned model carries resolved server timestamps
    # rather than the SERVER_TIMESTAMP sentinel.
    snapshot = await asyncio.to_thread(user_ref.get)
    return UserProfile.model_validate(snapshot.to_dict())


async def get_user_profile(uid: str) -> UserProfile | None:
    """Fetch /users/{uid}. Returns None if the user hasn't onboarded."""
    snapshot = await asyncio.to_thread(_user_ref(uid).get)
    if not snapshot.exists:
        return None
    return UserProfile.model_validate(snapshot.to_dict())
