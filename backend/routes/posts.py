# backend/routes/posts.py
"""Post routes."""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, Response
from fastapi.responses import JSONResponse

from middleware.auth import get_current_user_claims
from models.comment import CreateCommentRequest
from models.post import CreatePostRequest
from services import comments as comments_service
from services import likes as likes_service
from services import posts as posts_service

router = APIRouter(prefix="/posts", tags=["posts"])

_FEED_LIMIT_DEFAULT = 20
_FEED_LIMIT_MAX = 20
_COMMENTS_LIMIT_DEFAULT = 20
_COMMENTS_LIMIT_MAX = 50


def _meta() -> dict[str, str]:
    return {
        "request_id": str(uuid.uuid4()),
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


def _post_not_found(post_id: str) -> HTTPException:
    return HTTPException(
        status_code=404,
        detail={"code": "NOT_FOUND", "message": f"Post '{post_id}' not found."},
    )


def _comment_not_found(comment_id: str) -> HTTPException:
    return HTTPException(
        status_code=404,
        detail={"code": "NOT_FOUND", "message": f"Comment '{comment_id}' not found."},
    )


# NOTE: /feed is declared before /{post_id} so the literal path wins.
@router.get("/feed")
async def get_feed(
    limit: int = _FEED_LIMIT_DEFAULT,
    before: str | None = None,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Paginated feed of approved posts from followed users, newest first."""
    cap = max(1, min(limit, _FEED_LIMIT_MAX))
    posts = await posts_service.get_feed(
        viewer_uid=claims["uid"],
        limit=cap,
        before_created_at=before,
    )
    return JSONResponse(
        content={
            "data": {"posts": [p.model_dump(mode="json") for p in posts]},
            "meta": _meta(),
        }
    )


@router.post("", status_code=201)
async def create_post(
    payload: CreatePostRequest,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Create a new post. Text is run through content moderation before saving."""
    try:
        post = await posts_service.create_post(
            author_uid=claims["uid"],
            text=payload.text,
            image_url=payload.image_url,
        )
    except posts_service.PostBlocked as exc:
        raise HTTPException(
            status_code=422,
            detail={
                "code": "MODERATION_BLOCKED",
                "message": "Post was blocked by content moderation.",
                "field": "text",
            },
        ) from exc

    return JSONResponse(
        status_code=201,
        content={"data": {"post": post.model_dump(mode="json")}, "meta": _meta()},
    )


# NOTE: /{post_id}/like and /{post_id}/comments/* are declared before /{post_id}
# so multi-segment paths are matched before the single-segment catch-all.
@router.post("/{post_id}/like", status_code=204)
async def like_post(
    post_id: str,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> Response:
    """Like a post. Idempotent."""
    if await posts_service.get_post(post_id) is None:
        raise _post_not_found(post_id)
    await likes_service.like_post(claims["uid"], post_id)
    return Response(status_code=204)


@router.delete("/{post_id}/like", status_code=204)
async def unlike_post(
    post_id: str,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> Response:
    """Unlike a post. Idempotent."""
    if await posts_service.get_post(post_id) is None:
        raise _post_not_found(post_id)
    await likes_service.unlike_post(claims["uid"], post_id)
    return Response(status_code=204)


# NOTE: three-segment path declared before two-segment /comments.
@router.delete("/{post_id}/comments/{comment_id}", status_code=204)
async def delete_comment(
    post_id: str,
    comment_id: str,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> Response:
    """Delete a comment. Only the author or an admin may delete."""
    try:
        await comments_service.delete_comment(
            post_id=post_id,
            comment_id=comment_id,
            requesting_uid=claims["uid"],
            is_admin=bool(claims.get("admin", False)),
        )
    except comments_service.CommentNotFound as exc:
        raise _comment_not_found(comment_id) from exc
    except comments_service.NotAuthorized as exc:
        raise HTTPException(
            status_code=403,
            detail={
                "code": "FORBIDDEN",
                "message": "You are not allowed to delete this comment.",
            },
        ) from exc

    return Response(status_code=204)


@router.post("/{post_id}/comments", status_code=201)
async def create_comment(
    post_id: str,
    payload: CreateCommentRequest,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Create a comment on a post."""
    try:
        comment = await comments_service.create_comment(
            post_id=post_id,
            author_uid=claims["uid"],
            text=payload.text,
        )
    except comments_service.PostNotFound as exc:
        raise _post_not_found(post_id) from exc
    except comments_service.CommentBlocked as exc:
        raise HTTPException(
            status_code=422,
            detail={
                "code": "MODERATION_BLOCKED",
                "message": "Comment was blocked by content moderation.",
                "field": "text",
            },
        ) from exc

    return JSONResponse(
        status_code=201,
        content={"data": {"comment": comment.model_dump(mode="json")}, "meta": _meta()},
    )


@router.get("/{post_id}/comments")
async def get_comments(
    post_id: str,
    limit: int = _COMMENTS_LIMIT_DEFAULT,
    before: str | None = None,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Fetch comments for a post, oldest first."""
    cap = max(1, min(limit, _COMMENTS_LIMIT_MAX))
    comment_list = await comments_service.get_comments(
        post_id=post_id,
        limit=cap,
        before_created_at=before,
    )
    return JSONResponse(
        content={
            "data": {"comments": [c.model_dump(mode="json") for c in comment_list]},
            "meta": _meta(),
        }
    )


@router.get("/{post_id}")
async def get_post(
    post_id: str,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> JSONResponse:
    """Fetch a single post by ID. Includes is_liked for the requesting user."""
    post = await posts_service.get_post(post_id)
    if post is None:
        raise _post_not_found(post_id)

    viewer_uid = claims["uid"]
    liked = await likes_service.is_liked(viewer_uid, post_id)

    return JSONResponse(
        content={
            "data": {"post": {**post.model_dump(mode="json"), "is_liked": liked}},
            "meta": _meta(),
        }
    )


@router.delete("/{post_id}", status_code=204)
async def delete_post(
    post_id: str,
    claims: dict[str, Any] = Depends(get_current_user_claims),
) -> Response:
    """Delete a post. Only the author or an admin may delete."""
    try:
        await posts_service.delete_post(
            post_id=post_id,
            requesting_uid=claims["uid"],
            is_admin=bool(claims.get("admin", False)),
        )
    except posts_service.PostNotFound as exc:
        raise HTTPException(
            status_code=404,
            detail={"code": "NOT_FOUND", "message": f"Post '{post_id}' not found."},
        ) from exc
    except posts_service.NotAuthorized as exc:
        raise HTTPException(
            status_code=403,
            detail={
                "code": "FORBIDDEN",
                "message": "You are not allowed to delete this post.",
            },
        ) from exc

    return Response(status_code=204)
