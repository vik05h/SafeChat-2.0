// frontend/app/(onboarding)/username.tsx
/**
 * Onboarding step: complete profile.
 * POSTs to /auth/onboard with username, display_name, and optional bio.
 * On success lands in the main app.
 */

import { Text, Alert, StyleSheet } from "react-native";
import { useRouter } from "expo-router";
import { useState } from "react";
import { SafeAreaView } from "react-native-safe-area-context";
import api from "@/lib/api";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { COLORS } from "@/constants/theme";

const USERNAME_REGEX = /^[a-z0-9_]{3,30}$/;

export default function UsernameScreen() {
  const router = useRouter();
  const [displayName, setDisplayName] = useState("");
  const [username, setUsername] = useState("");
  const [bio, setBio] = useState("");
  const [loading, setLoading] = useState(false);

  function handleUsernameChange(value: string) {
    setUsername(value.toLowerCase().replace(/[^a-z0-9_]/g, ""));
  }

  async function handleContinue() {
    if (!displayName.trim()) {
      Alert.alert("Error", "Please enter your display name.");
      return;
    }
    if (displayName.trim().length > 50) {
      Alert.alert("Error", "Display name must be 50 characters or fewer.");
      return;
    }
    if (!USERNAME_REGEX.test(username)) {
      Alert.alert(
        "Invalid username",
        "3–30 characters: lowercase letters, numbers, or underscores only."
      );
      return;
    }
    setLoading(true);
    try {
      await api.post("/auth/onboard", {
        username,
        display_name: displayName.trim(),
        bio: bio.trim() || undefined,
      });
      router.replace("/(app)/feed");
    } catch (err: unknown) {
      const message =
        err instanceof Error ? err.message : "Could not complete setup.";
      Alert.alert("Error", message);
    } finally {
      setLoading(false);
    }
  }

  const canSubmit =
    displayName.trim().length >= 1 && username.length >= 3 && !loading;

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>Complete your profile</Text>
      <Text style={styles.subtitle}>
        This is how you'll appear to others on SafeChat.
      </Text>

      <Input
        label="Display name"
        placeholder="Jane Doe"
        value={displayName}
        onChangeText={setDisplayName}
        autoCapitalize="words"
        maxLength={50}
        containerStyle={styles.inputGap}
      />
      <Input
        label="Username"
        placeholder="jane_doe"
        value={username}
        onChangeText={handleUsernameChange}
        autoCapitalize="none"
        autoCorrect={false}
        maxLength={30}
        containerStyle={styles.inputGap}
      />
      <Input
        label="Bio (optional)"
        placeholder="Tell people about yourself"
        value={bio}
        onChangeText={setBio}
        autoCapitalize="sentences"
        maxLength={160}
        multiline
        numberOfLines={3}
        containerStyle={styles.inputGapXl}
      />

      <Button
        title="Continue"
        onPress={handleContinue}
        loading={loading}
        disabled={!canSubmit}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
    paddingHorizontal: 24,
    justifyContent: "center",
  },
  title: {
    color: COLORS.textPrimary,
    fontSize: 30,
    fontWeight: "bold",
    marginBottom: 8,
  },
  subtitle: {
    color: COLORS.textSecondary,
    marginBottom: 40,
  },
  inputGap: { marginBottom: 16 },
  inputGapXl: { marginBottom: 32 },
});
