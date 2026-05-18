// frontend/lib/store.ts
/**
 * Global client state via Zustand.
 *
 * Auth state is kept here (not in React context) so it's accessible
 * outside of components — e.g. inside API interceptors or background tasks.
 *
 * Profile state caches the /users/me response so screens don't re-fetch on
 * every mount.
 */

import { create } from "zustand";
import type { User } from "firebase/auth";

// ── Types ─────────────────────────────────────────────────────────────────

export interface UserProfile {
  uid: string;
  username: string;
  display_name: string;
  avatar_url: string | null;
  bio: string | null;
  followers_count: number;
  following_count: number;
}

// ── Auth slice ─────────────────────────────────────────────────────────────

interface AuthState {
  user: User | null;
  isLoading: boolean;
  setUser: (user: User | null) => void;
  setLoading: (loading: boolean) => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isLoading: true,
  setUser: (user) => set({ user }),
  setLoading: (isLoading) => set({ isLoading }),
}));

// ── Profile slice ──────────────────────────────────────────────────────────

interface ProfileState {
  profile: UserProfile | null;
  setProfile: (profile: UserProfile | null) => void;
  clearProfile: () => void;
}

export const useProfileStore = create<ProfileState>((set) => ({
  profile: null,
  setProfile: (profile) => set({ profile }),
  clearProfile: () => set({ profile: null }),
}));
