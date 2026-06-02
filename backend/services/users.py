# backend/services/users.py
"""User service layer.

Operations against /users/{uid} and /usernames/{username}. Username reservation
and profile creation happen in a single Firestore transaction so the two
documents can never get out of sync.
"""

from __future__ import annotations

import asyncio
from typing import Any

from google.api_core.exceptions import NotFound
from google.cloud import firestore
from google.cloud.firestore import DocumentReference, FieldFilter, Transaction

from core.firebase import db
from models.user import UserProfile, UserSearchResult


class UsernameTaken(Exception):
    """Raised when the requested username is already owned by a different uid."""


class AlreadyOnboarded(Exception):
    """Raised when /users/{uid} already exists."""


class ProfileNotFound(Exception):
    """Raised when an update targets a /users/{uid} doc that doesn't exist."""


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


async def get_profile_by_username(username: str) -> UserProfile | None:
    """Resolve username -> uid via /usernames/{username}, then fetch the profile.

    Returns None if the username is unreserved or the user doc is missing.
    """
    normalised = username.strip().lower()
    if not normalised:
        return None

    username_snap = await asyncio.to_thread(_username_ref(normalised).get)
    if not username_snap.exists:
        return None

    uid = (username_snap.to_dict() or {}).get("uid")
    if not uid:
        return None

    return await get_user_profile(str(uid))


async def update_profile(uid: str, fields: dict[str, Any]) -> UserProfile:
    """Apply a partial update to /users/{uid} and return the refreshed profile.

    `updated_at` is always bumped to the server timestamp. Raises
    ProfileNotFound if the user has no profile document.
    """
    user_ref = _user_ref(uid)
    payload: dict[str, Any] = {**fields, "updated_at": firestore.SERVER_TIMESTAMP}

    try:
        await asyncio.to_thread(lambda: user_ref.update(payload))
    except NotFound as exc:
        raise ProfileNotFound(uid) from exc

    snapshot = await asyncio.to_thread(user_ref.get)
    return UserProfile.model_validate(snapshot.to_dict())


async def search_users(query: str, limit: int) -> list[dict[str, Any]]:
    """Prefix-search users by username (case-insensitive).

    Usernames are stored lowercase, so the standard Firestore range trick
    (`>= q` and `< q + '\\uf8ff'`) gives a case-insensitive prefix match.
    An empty query returns an empty list without touching Firestore.
    """
    normalised = query.strip().lower()
    if not normalised:
        return []

    def _run_search() -> list[dict[str, Any]]:
        end = normalised + ""
        firestore_query = (
            db.collection("users")
            .where(filter=FieldFilter("username", ">=", normalised))
            .where(filter=FieldFilter("username", "<", end))
            .limit(limit)
        )
        results: list[dict[str, Any]] = []
        for snapshot in firestore_query.stream():
            data = snapshot.to_dict() or {}
            results.append(
                UserSearchResult(
                    uid=str(data.get("uid", "")),
                    username=str(data.get("username", "")),
                    display_name=str(data.get("display_name", "")),
                    photo_url=data.get("photo_url"),
                ).model_dump()
            )
        return results

    return await asyncio.to_thread(_run_search)


async def register_device_token(uid: str, token: str) -> None:
    """Store an FCM device token on the user doc."""
    user_ref = _user_ref(uid)
    payload = {"fcm_tokens": firestore.ArrayUnion([token])}
    
    def _update() -> None:
        try:
            user_ref.update(payload)
        except NotFound:
            # If they don't exist yet, we can't store the token
            pass

    await asyncio.to_thread(_update)


async def get_blocked_users_profiles(uid: str) -> list[dict[str, Any]]:
    """Return UserSearchResult dicts for blocked users."""
    from services import blocks as blocks_service
    blocked_uids = await blocks_service.get_blocked_users(uid)
    if not blocked_uids:
        return []
        
    def _query() -> list[dict[str, Any]]:
        results = []
        for b_uid in blocked_uids:
            snap = _user_ref(b_uid).get()
            if snap.exists:
                data = snap.to_dict() or {}
                results.append(
                    UserSearchResult(
                        uid=str(data.get("uid", "")),
                        username=str(data.get("username", "")),
                        display_name=str(data.get("display_name", "")),
                        photo_url=data.get("photo_url"),
                    ).model_dump()
                )
        return results
    return await asyncio.to_thread(_query)


async def get_suggested_users(uid: str, limit: int = 10) -> list[dict[str, Any]]:
    """Return suggested UserProfile dicts.
    
    Ranking ideally incorporates Trust Level, Reputation Score, and Activity.
    For Phase B Beta, we pull recent active users not followed or blocked.
    """
    from services import blocks as blocks_service
    from services import follows as follows_service
    
    blocked_uids = await blocks_service.get_blocked_users(uid)
    following_uids = await follows_service.get_following(uid)
    exclude_uids = set(blocked_uids) | set(following_uids) | {uid}
    
    def _query() -> list[dict[str, Any]]:
        q = (
            db.collection("users")
            .order_by("last_active_at", direction=firestore.Query.DESCENDING)
            .limit(50)
        )
        results = []
        for snap in q.stream():
            data = snap.to_dict() or {}
            c_uid = str(data.get("uid", ""))
            if c_uid not in exclude_uids:
                results.append(UserProfile.model_validate(data).model_dump(mode="json"))
            if len(results) >= limit:
                break
        return results
        
    return await asyncio.to_thread(_query)
