// frontend/app/(auth)/login.tsx
import { View, Text, Alert, StyleSheet } from "react-native";
import { Link } from "expo-router";
import { signInWithEmailAndPassword } from "firebase/auth";
import { useState } from "react";
import { SafeAreaView } from "react-native-safe-area-context";
import { auth } from "@/lib/firebase";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { GoogleSignInButton } from "@/components/auth/GoogleSignInButton";
import { COLORS } from "@/constants/theme";

export default function LoginScreen() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleLogin() {
    if (!email.trim() || !password) {
      Alert.alert("Error", "Please fill in all fields.");
      return;
    }
    setLoading(true);
    try {
      await signInWithEmailAndPassword(auth, email.trim(), password);
    } catch (err: unknown) {
      const message =
        err instanceof Error ? err.message : "Login failed.";
      Alert.alert("Login failed", message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>Welcome back</Text>
      <Text style={styles.subtitle}>Sign in to SafeChat</Text>

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
        placeholder="••••••••"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        containerStyle={styles.inputGapLg}
      />

      <Button
        title="Sign In"
        onPress={handleLogin}
        loading={loading}
        style={styles.btnGap}
      />
      <GoogleSignInButton style={styles.btnGapLg} />

      <View style={styles.footer}>
        <Text style={{ color: COLORS.textSecondary }}>
          Don't have an account?{" "}
        </Text>
        <Link href="/(auth)/signup">
          <Text style={styles.link}>Sign up</Text>
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
