// frontend/hooks/useAuth.ts
/**
 * Auth hooks.
 *
 * useAuthListener — call once at the root layout to wire up Firebase's
 * onAuthStateChanged observer; feeds results into the Zustand auth store.
 *
 * useCurrentUser / useAuthLoading — selector hooks for components that only
 * need a slice of auth state without subscribing to the full store object.
 */

import { useEffect } from "react";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { useAuthStore } from "@/lib/store";

export function useAuthListener(): void {
  const setUser = useAuthStore((s) => s.setUser);
  const setLoading = useAuthStore((s) => s.setLoading);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (firebaseUser) => {
      setUser(firebaseUser);
      setLoading(false);
    });
    return unsubscribe;
  }, [setUser, setLoading]);
}

export function useCurrentUser() {
  return useAuthStore((s) => s.user);
}

export function useAuthLoading() {
  return useAuthStore((s) => s.isLoading);
}
