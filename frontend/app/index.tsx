// frontend/app/index.tsx
/**
 * Root index — delegates immediately to the auth screen.
 * RootLayoutInner will redirect away from login if the user is already
 * signed in, so this is safe as a default redirect target.
 */

import { Redirect } from "expo-router";

export default function Index() {
  return <Redirect href="/(auth)/login" />;
}
