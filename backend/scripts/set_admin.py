# backend/scripts/set_admin.py
"""Grant or revoke the ``admin`` custom claim on a Firebase user.

The admin claim gates the moderation review portal (``/admin/moderation/*``);
it is enforced server-side by ``middleware.auth.require_admin``.

Usage (from the backend directory, with the venv active)::

    python -m scripts.set_admin <uid>
    python -m scripts.set_admin --email user@example.com
    python -m scripts.set_admin <uid> --revoke

After the claim changes the user must obtain a fresh ID token (sign out/in or a
token refresh) before it takes effect.
"""

from __future__ import annotations

import argparse

from core.firebase import auth


def _resolve_uid(uid: str | None, email: str | None) -> str:
    if uid:
        return uid
    if email:
        return str(auth.get_user_by_email(email).uid)
    raise SystemExit("Provide a <uid> argument or --email.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Set or unset the admin custom claim.")
    parser.add_argument("uid", nargs="?", help="Firebase UID of the target user")
    parser.add_argument("--email", help="Look up the user by email instead of UID")
    parser.add_argument("--revoke", action="store_true", help="Remove admin instead of granting it")
    args = parser.parse_args()

    uid = _resolve_uid(args.uid, args.email)
    user = auth.get_user(uid)
    claims = dict(user.custom_claims or {})

    if args.revoke:
        claims.pop("admin", None)
    else:
        claims["admin"] = True

    auth.set_custom_user_claims(uid, claims)
    action = "revoked" if args.revoke else "granted"
    print(f"Admin {action} for uid={uid} ({user.email}). The user must refresh their token.")


if __name__ == "__main__":
    main()
