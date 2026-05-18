// frontend/app/(app)/feed.tsx
import { View, Text, FlatList, RefreshControl, StyleSheet } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useGet } from "@/hooks/useApi";
import { COLORS, BORDER_RADIUS } from "@/constants/theme";
import { LoadingSpinner } from "@/components/ui/LoadingSpinner";

interface Post {
  id: string;
  author_uid: string;
  text: string;
  image_url: string | null;
  likes_count: number;
  created_at: string;
}

interface PostsResponse {
  posts: Post[];
  next_cursor: string | null;
}

export default function FeedScreen() {
  const { data, isLoading, isError, refetch, isRefetching } =
    useGet<PostsResponse>(["feed"], "/posts/feed?limit=20");

  if (isLoading) {
    return (
      <SafeAreaView style={styles.centered}>
        <LoadingSpinner />
      </SafeAreaView>
    );
  }

  if (isError) {
    return (
      <SafeAreaView style={styles.centered}>
        <Text style={styles.errorText}>
          Failed to load feed. Pull down to retry.
        </Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <FlatList
        data={data?.posts ?? []}
        keyExtractor={(item) => item.id}
        refreshControl={
          <RefreshControl
            refreshing={isRefetching}
            onRefresh={refetch}
            tintColor={COLORS.primary}
          />
        }
        ListHeaderComponent={
          <Text style={styles.heading}>Feed</Text>
        }
        ListEmptyComponent={
          <Text style={styles.empty}>Nothing to show yet.</Text>
        }
        renderItem={({ item }) => (
          <View style={styles.card}>
            <Text style={styles.cardDate}>{item.created_at}</Text>
            <Text style={styles.cardText}>{item.text}</Text>
            {item.likes_count > 0 && (
              <Text style={styles.cardMeta}>
                {item.likes_count}{" "}
                {item.likes_count === 1 ? "like" : "likes"}
              </Text>
            )}
          </View>
        )}
        contentContainerStyle={{ paddingBottom: 32 }}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  centered: {
    flex: 1,
    backgroundColor: COLORS.background,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 32,
  },
  errorText: {
    color: COLORS.error,
    textAlign: "center",
    fontSize: 16,
  },
  heading: {
    color: COLORS.textPrimary,
    fontSize: 24,
    fontWeight: "bold",
    paddingHorizontal: 16,
    paddingTop: 16,
    paddingBottom: 8,
  },
  empty: {
    color: COLORS.textSecondary,
    textAlign: "center",
    marginTop: 80,
  },
  card: {
    backgroundColor: COLORS.surface,
    marginHorizontal: 16,
    marginBottom: 12,
    borderRadius: BORDER_RADIUS.lg,
    padding: 16,
  },
  cardDate: {
    color: COLORS.textSecondary,
    fontSize: 12,
    marginBottom: 8,
  },
  cardText: {
    color: COLORS.textPrimary,
    fontSize: 16,
    lineHeight: 24,
  },
  cardMeta: {
    color: COLORS.textSecondary,
    fontSize: 12,
    marginTop: 12,
  },
});
