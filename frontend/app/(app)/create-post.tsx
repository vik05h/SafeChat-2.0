// frontend/app/(app)/create-post.tsx
/**
 * Create Post screen.
 *
 * Submits to POST /posts. On success, invalidates the feed cache and
 * navigates back to the Feed tab. Handles moderation 422 separately.
 */

import {
  View,
  Text,
  TextInput,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  Alert,
  StyleSheet,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { createPost } from "@/lib/api";
import { FEED_QUERY_KEY } from "@/hooks/useFeed";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { COLORS, BORDER_RADIUS } from "@/constants/theme";

const MAX_CHARS = 500;

export default function CreatePostScreen() {
  const router = useRouter();
  const queryClient = useQueryClient();

  const [text, setText] = useState("");
  const [imageUrl, setImageUrl] = useState("");
  const [loading, setLoading] = useState(false);

  const remaining = MAX_CHARS - text.length;
  const canSubmit = text.trim().length > 0 && !loading;

  async function handleSubmit() {
    if (!canSubmit) return;
    setLoading(true);
    try {
      await createPost({
        text: text.trim(),
        image_url: imageUrl.trim() || undefined,
      });
      // Invalidate feed so the new post appears immediately on return.
      await queryClient.invalidateQueries({ queryKey: FEED_QUERY_KEY });
      router.navigate("/(app)/feed");
    } catch (err: unknown) {
      const message =
        err instanceof Error ? err.message : "Failed to create post.";
      if (message === "MODERATION_BLOCKED") {
        Alert.alert(
          "Post blocked",
          "Your post was blocked by content moderation."
        );
      } else {
        Alert.alert("Error", message);
      }
    } finally {
      setLoading(false);
    }
  }

  return (
    <SafeAreaView style={styles.container}>
      {/* ── Header ── */}
      <View style={styles.header}>
        <Text style={styles.title}>New Post</Text>
      </View>

      {/* ── Body ── */}
      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === "ios" ? "padding" : undefined}
      >
        <ScrollView
          style={styles.flex}
          contentContainerStyle={styles.scrollContent}
          keyboardShouldPersistTaps="handled"
        >
          {/* Main text input */}
          <TextInput
            style={styles.textInput}
            placeholder="What's on your mind?"
            placeholderTextColor={COLORS.textTertiary}
            value={text}
            onChangeText={setText}
            multiline
            maxLength={MAX_CHARS}
            autoFocus
            textAlignVertical="top"
          />

          {/* Character counter */}
          <Text
            style={[
              styles.counter,
              remaining <= 50 && styles.counterWarning,
              remaining <= 0 && styles.counterError,
            ]}
          >
            {remaining}/{MAX_CHARS}
          </Text>

          {/* Optional image URL */}
          <Input
            label="Image URL (optional)"
            placeholder="https://example.com/image.jpg"
            value={imageUrl}
            onChangeText={setImageUrl}
            keyboardType="url"
            autoCapitalize="none"
            autoCorrect={false}
            containerStyle={styles.imageInput}
          />
        </ScrollView>
      </KeyboardAvoidingView>

      {/* ── Footer ── */}
      <View style={styles.footer}>
        <Button
          title="Post"
          onPress={handleSubmit}
          loading={loading}
          disabled={!canSubmit}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  flex: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 24,
    paddingTop: 16,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  title: {
    color: COLORS.textPrimary,
    fontSize: 20,
    fontWeight: "bold",
  },
  scrollContent: {
    padding: 24,
  },
  textInput: {
    backgroundColor: COLORS.surface,
    borderWidth: 1,
    borderColor: COLORS.surface2,
    borderRadius: BORDER_RADIUS.md,
    padding: 16,
    color: COLORS.textPrimary,
    fontSize: 16,
    lineHeight: 24,
    minHeight: 140,
  },
  counter: {
    color: COLORS.textSecondary,
    fontSize: 12,
    textAlign: "right",
    marginTop: 6,
    marginBottom: 24,
  },
  counterWarning: {
    color: COLORS.warning,
  },
  counterError: {
    color: COLORS.error,
  },
  imageInput: {
    marginBottom: 8,
  },
  footer: {
    paddingHorizontal: 24,
    paddingVertical: 16,
    borderTopWidth: 1,
    borderTopColor: COLORS.border,
  },
});
