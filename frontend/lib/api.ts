// frontend/lib/api.ts
/**
 * Axios instance pre-configured for the SafeChat backend.
 *
 * Request interceptor: attaches a fresh Firebase ID token as Bearer on every
 * call so the token is never stale.
 *
 * Response interceptor: normalises the error shape — callers always receive
 * an Error whose message is the detail string from the backend JSON body.
 * When detail is an object (e.g. moderation 422), the object's `code` field
 * is surfaced as the message so callers can branch on it.
 */

import axios, { type AxiosResponse } from "axios";
import { auth } from "./firebase";
import type { UserProfile } from "./store";

const BASE_URL =
  process.env.EXPO_PUBLIC_API_URL ?? "http://localhost:8000/api/v1";

const api = axios.create({
  baseURL: BASE_URL,
  headers: { "Content-Type": "application/json" },
});

// Attach Bearer token before every request.
api.interceptors.request.use(async (config) => {
  const user = auth.currentUser;
  if (user) {
    const token = await user.getIdToken();
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Normalise error shape — surface the backend detail string.
api.interceptors.response.use(
  (response: AxiosResponse) => response,
  (error: unknown) => {
    const axiosError = error as {
      response?: { data?: { detail?: unknown } };
      message?: string;
    };
    const detail = axiosError.response?.data?.detail;
    let message: string;
    if (typeof detail === "string") {
      message = detail;
    } else if (detail !== null && typeof detail === "object") {
      const d = detail as { code?: string; message?: string };
      message = d.code ?? d.message ?? JSON.stringify(detail);
    } else {
      message = axiosError.message ?? "An unknown error occurred.";
    }
    return Promise.reject(new Error(message));
  }
);

export default api;

// ── Shared types ───────────────────────────────────────────────────────────

export interface Post {
  id: string;
  author_uid: string;
  text: string;
  image_url: string | null;
  likes_count: number;
  created_at: string;
  status: string;
  /** Injected locally by the optimistic-update layer; not returned by /feed. */
  is_liked?: boolean;
}

export interface PostsResponse {
  data: { posts: Post[] };
  meta: Record<string, unknown>;
}

export interface PostResponse {
  data: { post: Post };
  meta: Record<string, unknown>;
}

export interface MeData {
  user: { uid: string; email: string };
  profile: UserProfile | null;
  needs_onboarding: boolean;
}

// ── Typed API helpers ──────────────────────────────────────────────────────

/**
 * Fetch the current user's profile from the backend.
 * Returns null on any error (network failure, unauthenticated, etc.).
 * The caller is responsible for deciding how to handle null.
 */
export async function getMe(): Promise<MeData | null> {
  try {
    const res = await api.get<{ data: MeData }>("/auth/me");
    return res.data.data;
  } catch {
    return null;
  }
}

export async function getFeed(limit = 20): Promise<PostsResponse> {
  const res = await api.get<PostsResponse>(`/posts/feed?limit=${limit}`);
  return res.data;
}

export async function likePost(postId: string): Promise<void> {
  await api.post(`/posts/${postId}/like`);
}

export async function unlikePost(postId: string): Promise<void> {
  await api.delete(`/posts/${postId}/like`);
}

export async function createPost(data: {
  text: string;
  image_url?: string;
}): Promise<PostResponse> {
  const res = await api.post<PostResponse>("/posts", data);
  return res.data;
}
