# SafeChat API Contracts

REST API specification for SafeChat backend. Base URL: `/api/v1`

---

## 1. Conventions

### Authentication

All endpoints (except `/auth/*`) require a Firebase ID token:

```
Authorization: Bearer <firebase_id_token>
```

Backend verifies the token via Firebase Admin SDK on every request.

### Request format

```
Content-Type: application/json
Accept: application/json
```

### Response envelope

**Success:**
```json
{
  "data": { ... },
  "meta": { "request_id": "...", "timestamp": "..." }
}
```

**Error:**
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable description",
    "field": "fieldName"
  },
  "meta": { "request_id": "...", "timestamp": "..." }
}
```

### Error codes

| HTTP | Code | Meaning |
|---|---|---|
| 400 | `INVALID_INPUT` | Validation failed |
| 401 | `UNAUTHENTICATED` | Missing or invalid token |
| 403 | `FORBIDDEN` | Authenticated but not authorized |
| 404 | `NOT_FOUND` | Resource doesn't exist |
| 409 | `CONFLICT` | Resource state conflict |
| 422 | `MODERATION_BLOCKED` | Content blocked by moderation |
| 429 | `RATE_LIMITED` | Too many requests |
| 500 | `INTERNAL_ERROR` | Server error |
| 503 | `SERVICE_UNAVAILABLE` | Dependency down |

### Pagination

Cursor-based pagination for all list endpoints:

```
GET /api/v1/posts/feed?cursor=<opaque>&limit=20
```

Response includes:
```json
{
  "data": [...],
  "meta": {
    "next_cursor": "...",
    "has_more": true
  }
}
```

### Timestamps

All timestamps are ISO 8601 UTC: `2026-11-15T14:30:00.000Z`

---

## 2. Authentication

### POST `/api/v1/auth/me`

Verify current token and return user info.

**Request:** No body, just bearer token.

**Response 200:**
```json
{
  "data": {
    "uid": "abc123",
    "email": "user@example.com",
    "username": "adnan_z",
    "display_name": "Adnan Zeya",
    "photo_url": "https://...",
    "created_at": "2026-11-15T14:30:00.000Z"
  }
}
```

### POST `/api/v1/auth/onboard`

Called after first sign-in to create user profile in Firestore.

**Request:**
```json
{
  "username": "adnan_z",
  "display_name": "Adnan Zeya",
  "bio": "Optional bio"
}
```

**Response 201:** Same as `/me` above.

**Errors:**
- 409 `USERNAME_TAKEN`
- 422 `MODERATION_BLOCKED` (bio or username contains slurs)

---

## 3. Users

### GET `/api/v1/users/{username}`

Get public profile of a user.

**Response 200:**
```json
{
  "data": {
    "uid": "abc123",
    "username": "adnan_z",
    "display_name": "Adnan Zeya",
    "bio": "...",
    "photo_url": "https://...",
    "follower_count": 142,
    "following_count": 87,
    "post_count": 23,
    "is_following": false,
    "is_followed_by": false,
    "is_blocked": false
  }
}
```

### PATCH `/api/v1/users/me`

Update own profile.

**Request:**
```json
{
  "display_name": "...",
  "bio": "...",
  "photo_url": "..."
}
```

All fields optional. Each field passes through moderation cascade.

**Response 200:** Updated user object.

### POST `/api/v1/users/{uid}/follow`

Follow a user.

**Response 204:** No content.

### DELETE `/api/v1/users/{uid}/follow`

Unfollow a user.

**Response 204:** No content.

### POST `/api/v1/users/{uid}/block`

Block a user. Prevents all interaction.

**Response 204:** No content.

### GET `/api/v1/users/search?q={query}`

Search users by username or display name.

**Response 200:**
```json
{
  "data": [
    { "uid": "...", "username": "...", "display_name": "...", "photo_url": "..." }
  ]
}
```

---

## 4. Posts

### POST `/api/v1/posts`

Create a post.

**Request:**
```json
{
  "caption": "Loving the sunset tonight",
  "media_urls": ["https://storage.../image1.jpg"],
  "media_type": "image"
}
```

**Response 201:**
```json
{
  "data": {
    "id": "post_xyz",
    "author_uid": "...",
    "caption": "...",
    "media_urls": ["..."],
    "media_type": "image",
    "status": "approved",
    "like_count": 0,
    "comment_count": 0,
    "created_at": "..."
  }
}
```

**Errors:**
- 422 `MODERATION_BLOCKED` with details on which content failed (caption / image)

### GET `/api/v1/posts/feed`

Personalized feed for authenticated user (posts from followed users + algorithm).

**Query params:** `cursor`, `limit` (max 50, default 20)

**Response 200:** List of post objects.

### GET `/api/v1/posts/{postId}`

Get a single post.

### DELETE `/api/v1/posts/{postId}`

Delete own post.

**Response 204:** No content.

### POST `/api/v1/posts/{postId}/like`

Like a post.

### DELETE `/api/v1/posts/{postId}/like`

Unlike a post.

---

## 5. Comments

### POST `/api/v1/posts/{postId}/comments`

Add a comment.

**Request:**
```json
{
  "text": "Great photo!",
  "parent_comment_id": null
}
```

**Response 201:**
```json
{
  "data": {
    "id": "comment_xyz",
    "post_id": "...",
    "author_uid": "...",
    "text": "...",
    "parent_comment_id": null,
    "like_count": 0,
    "reply_count": 0,
    "created_at": "..."
  }
}
```

**Errors:** 422 `MODERATION_BLOCKED`

### GET `/api/v1/posts/{postId}/comments`

List comments on a post.

### DELETE `/api/v1/comments/{commentId}`

Delete own comment.

---

## 6. Messages

### POST `/api/v1/messages`

Send a direct message.

**Request:**
```json
{
  "recipient_uid": "abc123",
  "text": "Hey, what's up?",
  "media_url": null
}
```

**Response 201:**
```json
{
  "data": {
    "id": "msg_xyz",
    "chat_id": "chat_abc",
    "sender_uid": "...",
    "recipient_uid": "...",
    "text": "...",
    "media_url": null,
    "created_at": "...",
    "read_at": null
  }
}
```

**Errors:** 422 `MODERATION_BLOCKED` (message is silently dropped, never reaches recipient)

### GET `/api/v1/chats`

List user's chats.

### GET `/api/v1/chats/{chatId}/messages`

Get message history (paginated, newest first).

**Note:** Frontend primarily uses Firestore real-time listeners for chat. This endpoint exists for initial load and pagination.

### POST `/api/v1/chats/{chatId}/read`

Mark all messages in chat as read.

---

## 7. Stories

### POST `/api/v1/stories`

Post a story (auto-expires after 24 hours).

**Request:**
```json
{
  "media_url": "https://storage.../story.jpg",
  "media_type": "image",
  "caption": "Optional"
}
```

**Response 201:** Story object with `expires_at` field.

### GET `/api/v1/stories/feed`

Get stories from followed users (not expired).

### POST `/api/v1/stories/{storyId}/view`

Mark a story as viewed by current user.

---

## 8. Media Uploads

### POST `/api/v1/uploads/sign`

Request a signed Firebase Storage URL for upload.

**Request:**
```json
{
  "content_type": "image/jpeg",
  "size_bytes": 2048576,
  "purpose": "post" | "story" | "profile" | "message"
}
```

**Response 200:**
```json
{
  "data": {
    "upload_url": "https://storage.googleapis.com/...",
    "file_url": "https://storage.googleapis.com/.../path",
    "expires_at": "..."
  }
}
```

**Errors:**
- 400 `INVALID_CONTENT_TYPE` (must be image/jpeg, image/png, image/webp, video/mp4)
- 400 `FILE_TOO_LARGE` (max 10 MB images, 100 MB videos)

**Flow:**
1. Client requests signed URL
2. Client uploads directly to Firebase Storage (faster, doesn't go through backend)
3. Client provides `file_url` to subsequent API call (e.g., `POST /posts`)
4. Backend runs moderation on the file when post/story is created

---

## 9. Notifications

### GET `/api/v1/notifications`

Get notifications for current user.

**Response 200:**
```json
{
  "data": [
    {
      "id": "...",
      "type": "like" | "comment" | "follow" | "mention" | "message",
      "actor_uid": "...",
      "target_id": "...",
      "read": false,
      "created_at": "..."
    }
  ]
}
```

### POST `/api/v1/notifications/read`

Mark notifications as read.

**Request:**
```json
{ "ids": ["notif_1", "notif_2"] }
```

### POST `/api/v1/notifications/fcm-token`

Register FCM token for push notifications.

**Request:**
```json
{ "token": "fcm_token_string", "device_type": "android" | "web" }
```

---

## 10. Reporting

### POST `/api/v1/reports`

Report content.

**Request:**
```json
{
  "target_type": "message" | "post" | "comment" | "story" | "user",
  "target_id": "...",
  "reason": "harassment" | "spam" | "hate" | "threat" | "impersonation" | "other",
  "description": "Optional details"
}
```

**Response 201:** Report object with status `pending`.

---

## 11. Admin Endpoints

Admin endpoints require `admin: true` custom claim on user's Firebase Auth token.

### GET `/api/v1/admin/reports`

List pending reports.

**Query:** `status=pending`, `cursor`, `limit`

### POST `/api/v1/admin/reports/{reportId}/resolve`

**Request:**
```json
{
  "action": "block_content" | "warn_user" | "suspend_user" | "dismiss",
  "notes": "..."
}
```

### GET `/api/v1/admin/posts/pending`

Posts/stories in `pending_review` status.

### POST `/api/v1/admin/posts/{postId}/approve`

### POST `/api/v1/admin/posts/{postId}/block`

### GET `/api/v1/admin/moderation/keywords`

List dynamic keyword filter entries.

### POST `/api/v1/admin/moderation/keywords`

Add a new keyword.

**Request:**
```json
{
  "category": "english_slurs" | "hindi_slurs" | "hinglish_slurs" | "threats",
  "value": "...",
  "notes": "..."
}
```

### DELETE `/api/v1/admin/moderation/keywords/{keywordId}`

### GET `/api/v1/admin/moderation/test`

Test the moderation cascade with arbitrary input.

**Request:**
```json
{ "text": "test phrase here" }
```

**Response:**
```json
{
  "data": {
    "verdict": "blocked" | "approved",
    "layer_triggered": "keyword" | "openai" | "gemini",
    "category": "...",
    "scores": { ... },
    "latency_ms": 142
  }
}
```

---

## 12. Health & Status

### GET `/api/v1/health`

**Response 200:**
```json
{
  "data": {
    "status": "ok",
    "version": "0.1.0",
    "dependencies": {
      "firestore": "ok",
      "openai": "ok",
      "gemini": "ok",
      "vision": "ok"
    }
  }
}
```

---

## 13. WebSocket / Real-time

SafeChat does NOT expose custom WebSockets. Real-time features use Firestore listeners directly from the client SDK:

- **Chat messages:** Listen to `/chats/{chatId}/messages` ordered by `created_at`
- **Notifications:** Listen to `/users/{uid}/notifications`
- **Feed updates:** Periodic refresh of `/posts/feed` endpoint

Security rules enforce read permissions on these listeners.

---

## 14. Rate Limits

| Endpoint group | Limit |
|---|---|
| `/auth/*` | 10/min per IP |
| `/messages` (POST) | 30/min per user |
| `/posts` (POST) | 10/hour per user |
| `/comments` (POST) | 30/hour per user |
| `/reports` (POST) | 20/day per user |
| All others | 600/min per user |

Limits are enforced via middleware. Exceeded limits return `429 RATE_LIMITED` with `Retry-After` header.

---

## 15. Versioning

This is `v1` of the API. Breaking changes require a `v2` namespace.

When `v2` is introduced, `v1` is supported for minimum 6 months with deprecation notices.

---

*Last updated: November 2026*
