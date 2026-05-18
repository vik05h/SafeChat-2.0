// frontend/app/(app)/feed.tsx
import { FlatList, RefreshControl, SafeAreaView, Text, StyleSheet } from "react-native";
import { useFeed } from "@/hooks/useFeed";
import { useCurrentUser } from "@/hooks/useAuth";
import { PostCard } from "@/components/post/PostCard";
import { LoadingSpinner } from "@/components/ui/LoadingSpinner";
import { COLORS } from "@/constants/theme";

export default function FeedScreen() {
  const user = useCurrentUser();
  const { posts, isLoading, isError, refetch, isRefetching, toggleLike } =
    useFeed();

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
        data={posts}
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
          <PostCard
            post={item}
            onLike={toggleLike}
            currentUserUid={user?.uid ?? ""}
          />
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
});
