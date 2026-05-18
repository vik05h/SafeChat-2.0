// frontend/lib/firebase.ts
/**
 * Firebase CLIENT SDK initialisation — never import firebase-admin here.
 * Only one App instance is created regardless of how many times this module
 * is imported (getApps() guard).
 */

import { initializeApp, getApps } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: process.env.EXPO_PUBLIC_FIREBASE_API_KEY!,
  authDomain: process.env.EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN!,
  projectId: process.env.EXPO_PUBLIC_FIREBASE_PROJECT_ID!,
  storageBucket: process.env.EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET!,
  messagingSenderId: process.env.EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID!,
  appId: process.env.EXPO_PUBLIC_FIREBASE_APP_ID!,
};

const app =
  getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];

export const auth = getAuth(app);
export const firestore = getFirestore(app);

export default app;
