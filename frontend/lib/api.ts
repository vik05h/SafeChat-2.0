// frontend/lib/api.ts
/**
 * Axios instance pre-configured for the SafeChat backend.
 *
 * Request interceptor: attaches a fresh Firebase ID token as Bearer on every
 * call so the token is never stale (Firebase refreshes it automatically when
 * it's within the expiry window).
 *
 * Response interceptor: normalises the error shape — callers always receive
 * an Error whose message is the detail string from the backend JSON body.
 */

import axios, { type AxiosResponse } from "axios";
import { auth } from "./firebase";

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
      response?: { data?: { detail?: string } };
      message?: string;
    };
    const message =
      axiosError.response?.data?.detail ??
      axiosError.message ??
      "An unknown error occurred.";
    return Promise.reject(new Error(message));
  }
);

export default api;
