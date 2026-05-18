// frontend/app/(auth)/signup.tsx
import { View, Text, Alert, StyleSheet } from "react-native";
import { Link, useRouter } from "expo-router";
import { createUserWithEmailAndPassword, updateProfile } from "firebase/auth";
import { useState } from "react";
import { SafeAreaView } from "react-native-safe-area-context";
import { auth } from "@/lib/firebase";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { GoogleSignInButton } from "@/components/auth/GoogleSignInButton";
import { COLORS } from "@/constants/theme";

export default function SignupScreen() {
  const router = useRouter();
  const [displayName, setDisplayName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSignup() {
    if (!displayName.trim() || !email.trim() || !password) {
      Alert.alert("Error", "Please fill in all fields.");
      return;
    }
    if (password.length < 8) {
      Alert.alert("Error", "Password must be at least 8 characters.");
      return;
    }
    setLoading(true);
    try {
      const { user } = await createUserWithEmailAndPassword(
        auth,
        email.trim(),
        password
      );
      await updateProfile(user, { displayName: displayName.trim() });
      router.replace("/(onboarding)/username");
    } catch (err: unknown) {
      const message =
        err instanceof Error ? err.message : "Sign up failed.";
      Alert.alert("Sign up failed", message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>Create account</Text>
      <Text style={styles.subtitle}>Join SafeChat today</Text>

      <Input
        label="Display name"
        placeholder="Jane Doe"
        value={displayName}
        onChangeText={setDisplayName}
        autoCapitalize="words"
        containerStyle={styles.inputGap}
      />
      <Input
        label="Email"
        placeholder="you@example.com"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
        containerStyle={styles.inputGap}
      />
      <Input
        label="Password"
        placeholder="Min. 8 characters"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        containerStyle={styles.inputGapLg}
      />

      <Button
        title="Create Account"
        onPress={handleSignup}
        loading={loading}
        style={styles.btnGap}
      />
      <GoogleSignInButton style={styles.btnGapLg} />

      <View style={styles.footer}>
        <Text style={{ color: COLORS.textSecondary }}>
          Already have an account?{" "}
        </Text>
        <Link href="/(auth)/login">
          <Text style={styles.link}>Sign in</Text>
        </Link>
      </View>
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
  inputGapLg: { marginBottom: 24 },
  btnGap: { marginBottom: 12 },
  btnGapLg: { marginBottom: 40 },
  footer: {
    flexDirection: "row",
    justifyContent: "center",
  },
  link: {
    color: COLORS.primary,
    fontWeight: "600",
  },
});
