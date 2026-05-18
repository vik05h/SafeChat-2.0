// frontend/app/_layout.tsx
/**
 * Root layout — mounts once for the lifetime of the app.
 *
 * Responsibilities:
 *   1. Wrap the tree with QueryClientProvider and SafeAreaProvider.
 *   2. Start the Firebase auth listener via useAuthListener().
 *   3. Once auth state is resolved, hide the splash screen and redirect:
 *        - Unauthenticated → /(auth)/login
 *        - Authenticated & in auth group → /(app)/feed
 */

import { useEffect } from "react";
import { Stack, useRouter, useSegments } from "expo-router";
import { StatusBar } from "expo-status-bar";
import * as SplashScreen from "expo-splash-screen";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { useAuthListener, useAuthLoading, useCurrentUser } from "@/hooks/useAuth";

SplashScreen.preventAutoHideAsync();

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      staleTime: 30_000,
    },
  },
});

function RootLayoutInner() {
  const isLoading = useAuthLoading();
  const user = useCurrentUser();
  const router = useRouter();
  const segments = useSegments();

  useAuthListener();

  useEffect(() => {
    if (isLoading) return;

    void SplashScreen.hideAsync();

    const inAuthGroup = segments[0] === "(auth)";

    if (!user && !inAuthGroup) {
      router.navigate("/(auth)/login");
    } else if (user && inAuthGroup) {
      router.replace("/(app)/feed");
    }
  }, [user, isLoading, segments, router]);

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="(auth)" />
      <Stack.Screen name="(onboarding)" />
      <Stack.Screen name="(app)" />
    </Stack>
  );
}

export default function RootLayout() {
  return (
    <QueryClientProvider client={queryClient}>
      <SafeAreaProvider>
        <StatusBar style="light" />
        <RootLayoutInner />
      </SafeAreaProvider>
    </QueryClientProvider>
  );
}
