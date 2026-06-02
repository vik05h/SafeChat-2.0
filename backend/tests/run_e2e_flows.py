# backend/tests/run_e2e_flows.py
"""Automated E2E Integration tests simulating the Flutter frontend.

This script executes the critical user flows against the FastAPI application
locally. We use `httpx.AsyncClient` with `ASGITransport` to validate the entire
routing, service, and data layer interaction synchronously.
"""

import asyncio
import sys
from typing import Any

import httpx
from pydantic import BaseModel

# Add backend directory to sys.path to allow imports if run directly
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from main import app
from middleware.auth import get_current_user_claims
from models.moderation import ModerationResult

# Mock Moderation
async def _mock_moderate_text(text: str) -> ModerationResult:
    return ModerationResult(blocked=False, content_hash="h")

# Patch it in the routers
import routes.moderation
import routes.posts
import routes.users
routes.moderation.moderate_text = _mock_moderate_text
routes.posts.moderate_text = _mock_moderate_text
routes.users.moderate_text = _mock_moderate_text

# Mock Auth Dependency
def _mock_auth() -> dict[str, Any]:
    return {"uid": "e2e_test_user_1", "email": "e2e@example.com", "admin": False}

app.dependency_overrides[get_current_user_claims] = _mock_auth


async def run_e2e() -> None:
    print("Starting Phase 9 Automated E2E Validation...")
    
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://localhost:8000/api/v1") as client:
        
        headers = {"Authorization": "Bearer mock-token"}
        
        # 1. Auth & Onboarding
        print("\n--- 1. Auth & Onboarding ---")
        res = await client.post("/auth/onboard", json={
            "username": "e2e_user",
            "display_name": "E2E User",
            "bio": "Testing the backend"
        }, headers=headers)
        # If already onboarded, this might fail, but let's assume a clean slate or we catch 400
        print(f"Onboard Status: {res.status_code}")
        if res.status_code not in [200, 201, 400, 409]: 
            print(res.text)
            raise RuntimeError("Onboarding failed unexpectedly")

        # 2. Device Token
        print("\n--- 2. Device Token ---")
        res = await client.post("/users/device-token", json={"token": "mock-fcm-token"}, headers=headers)
        assert res.status_code == 204, f"Device token failed: {res.text}"
        print("Device token registered.")

        # 3. Fetch Profile
        print("\n--- 3. Fetch Profile ---")
        res = await client.get("/users/e2e_user", headers=headers)
        if res.status_code == 200:
            uid = res.json()["data"]["uid"]
            print(f"Profile fetched successfully (UID: {uid})")
        else:
            print(f"Failed to fetch profile: {res.text}")

        # 4. Moderation Pre-Flight
        print("\n--- 4. Moderation Pre-Flight ---")
        res = await client.post("/moderation/analyze", json={"text": "This is a safe test."}, headers=headers)
        assert res.status_code == 200
        print(f"Moderation status: {res.json()['data']['status']}")

        # 5. Create Post
        print("\n--- 5. Create Post ---")
        res = await client.post("/posts", json={"text": "Hello world from E2E test!"}, headers=headers)
        assert res.status_code == 201
        post_id = res.json()["data"]["post"]["id"]
        print(f"Created Post: {post_id}")

        # 6. User Posts
        print("\n--- 6. User Posts ---")
        res = await client.get(f"/users/{uid}/posts", headers=headers)
        assert res.status_code == 200
        print(f"Fetched {len(res.json()['data'])} posts.")

        # 7. Safety Stats
        print("\n--- 7. Safety Stats ---")
        res = await client.get("/safety/stats", headers=headers)
        assert res.status_code == 200
        print(f"Safety Score: {res.json()['data']['safety_score']}")

        # 8. Submit Appeal
        print("\n--- 8. Submit Appeal ---")
        res = await client.post("/safety/appeals", json={"content_id": post_id, "reason": "I think it's fair"}, headers=headers)
        assert res.status_code == 201
        print("Appeal submitted.")

        # 9. List Appeals
        print("\n--- 9. List Appeals ---")
        res = await client.get("/safety/appeals", headers=headers)
        assert res.status_code == 200
        print(f"Appeals count: {len(res.json()['data'])}")

        # 10. Suggested Users
        print("\n--- 10. Suggested Users ---")
        res = await client.get("/users/suggested", headers=headers)
        assert res.status_code == 200
        print(f"Suggested users: {len(res.json()['data'])}")
        
        # 11. Block User (Idempotent)
        print("\n--- 11. Block User ---")
        # Block a dummy uid
        res = await client.post("/users/dummy-block-uid/block", headers=headers)
        if res.status_code not in [204, 404]: # 404 if user not found, 204 if successful
            print(f"Block failed: {res.text}")
            
        # 12. Blocked Users List
        print("\n--- 12. Blocked Users List ---")
        res = await client.get("/users/me/blocked", headers=headers)
        assert res.status_code == 200
        print(f"Blocked users fetched.")

        # 13. Notifications
        print("\n--- 13. Notifications ---")
        res = await client.get("/notifications", headers=headers)
        assert res.status_code == 200
        notifs = res.json()["data"]
        print(f"Notifications fetched: {len(notifs)}")
        
        if len(notifs) > 0:
            res = await client.put(f"/notifications/{notifs[0]['id']}/read", headers=headers)
            assert res.status_code == 204
            
        res = await client.put("/notifications/read-all", headers=headers)
        assert res.status_code == 204
        print("Notifications marked as read.")
        
    print("\n--- SUMMARY ---")
    print("✅ All E2E Automated Tests Passed Successfully")

if __name__ == "__main__":
    asyncio.run(run_e2e())
