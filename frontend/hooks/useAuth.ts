// frontend/hooks/useAuth.ts
/**
 * Auth hooks.
 *
 * useAuthListener — call once at the root layout to wire up Firebase's
 * onAuthStateChanged observer. On sign-in, calls GET /auth/me to resolve
 * onboarding status before unblocking the rest of the app:
 *   - needs_onboarding: true  → navigate to onboarding flow
 *   - needs_onboarding: false → populate profile store, continue
 *   - getMe() error           → fail-open (set user, skip profile)
 *
 * useCurrentUser / useAuthLoading — selector hooks for components that only
 * need a slice of auth state without subscribing to the full store object.
 */

import { useEffect } from "react";
import { onAuthStateChanged } from "firebase/auth";
import { useRouter } from "expo-router";
import { auth } from "@/lib/firebase";
import { getMe } from "@/lib/api";
import { useAuthStore, useProfileStore, type UserProfile } from "@/lib/store";

export function useAuthListener(): void {
  const setUser = useAuthStore((s) => s.setUser);
  const setLoading = useAuthStore((s) => s.setLoading);
  const setProfile = useProfileStore((s) => s.setProfile);
  const router = useRouter();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      // ── Signed out ─────────────────────────────────────────────────────
      if (!firebaseUser) {
        setUser(null);
        setLoading(false);
        return;
      }

      // ── Signed in — check onboarding status before unblocking UI ───────
      try {
        const me = await getMe();

        if (me === null) {
          // Network error — fail-open, let the user through without a profile.
          setUser(firebaseUser);
          setLoading(false);
          return;
        }

        if (me.needs_onboarding) {
          // User exists in Firebase Auth but has no Firestore profile yet.
          setUser(firebaseUser);
          setLoading(false);
          router.replace("/(onboarding)/username");
          return;
        }

        // Fully onboarded — populate profile store.
        if (me.profile) {
          setProfile(me.profile as UserProfile);
        }
        setUser(firebaseUser);
        setLoading(false);
      } catch {
        // Unexpected error — fail-open.
        setUser(firebaseUser);
        setLoading(false);
      }
    });

    return unsubscribe;
  }, [setUser, setLoading, setProfile, router]);
}

export function useCurrentUser() {
  return useAuthStore((s) => s.user);
}

export function useAuthLoading() {
  return useAuthStore((s) => s.isLoading);
}
