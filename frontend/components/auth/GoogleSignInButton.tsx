// frontend/components/auth/GoogleSignInButton.tsx
/**
 * Google OAuth sign-in via expo-auth-session.
 * On success, exchanges the Google id_token for a Firebase credential and
 * calls signInWithCredential — RootLayoutInner handles navigation from there.
 */

import { Alert, type ViewStyle } from "react-native";
import * as Google from "expo-auth-session/providers/google";
import { GoogleAuthProvider, signInWithCredential } from "firebase/auth";
import { useEffect } from "react";
import { auth } from "@/lib/firebase";
import { Button } from "@/components/ui/Button";

interface GoogleSignInButtonProps {
  style?: ViewStyle;
}

export function GoogleSignInButton({ style }: GoogleSignInButtonProps) {
  const [request, response, promptAsync] = Google.useAuthRequest({
    clientId: process.env.EXPO_PUBLIC_GOOGLE_CLIENT_ID,
  });

  useEffect(() => {
    if (response?.type !== "success") return;

    const { id_token } = response.params;
    if (!id_token) {
      Alert.alert("Google sign-in error", "No ID token returned.");
      return;
    }

    const credential = GoogleAuthProvider.credential(id_token);
    signInWithCredential(auth, credential).catch((err: unknown) => {
      const message =
        err instanceof Error ? err.message : "Google sign-in failed.";
      Alert.alert("Google sign-in error", message);
    });
  }, [response]);

  return (
    <Button
      title="Continue with Google"
      variant="outline"
      onPress={() => promptAsync()}
      disabled={!request}
      style={style}
    />
  );
}
