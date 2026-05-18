// frontend/app/(app)/messages.tsx
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  RefreshControl,
  StyleSheet,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useGet } from "@/hooks/useApi";
import { useCurrentUser } from "@/hooks/useAuth";
import { COLORS } from "@/constants/theme";
import { LoadingSpinner } from "@/components/ui/LoadingSpinner";
import { Avatar } from "@/components/ui/Avatar";

interface Chat {
  id: string;
  participants: string[];
  last_message_text: string | null;
  last_message_at: string | null;
}

interface ChatsResponse {
  chats: Chat[];
}

export default function MessagesScreen() {
  const user = useCurrentUser();
  const { data, isLoading, isError, refetch, isRefetching } =
    useGet<ChatsResponse>(["chats"], "/chats");

  if (isLoading) {
    return (
      <SafeAreaView style={styles.centered}>
        <LoadingSpinner />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.heading}>Messages</Text>

      {isError ? (
        <Text style={styles.errorText}>Failed to load conversations.</Text>
      ) : (
        <FlatList
          data={data?.chats ?? []}
          keyExtractor={(item) => item.id}
          refreshControl={
            <RefreshControl
              refreshing={isRefetching}
              onRefresh={refetch}
              tintColor={COLORS.primary}
            />
          }
          ListEmptyComponent={
            <Text style={styles.empty}>No conversations yet.</Text>
          }
          renderItem={({ item }) => {
            const otherUid =
              item.participants.find((uid) => uid !== user?.uid) ??
              item.participants[0];
            return (
              <TouchableOpacity style={styles.row} activeOpacity={0.7}>
                <Avatar uid={otherUid} size={48} />
                <View style={styles.rowContent}>
                  <Text style={styles.rowTitle}>{otherUid}</Text>
                  {item.last_message_text ? (
                    <Text style={styles.rowSubtitle} numberOfLines={1}>
                      {item.last_message_text}
                    </Text>
                  ) : null}
                </View>
              </TouchableOpacity>
            );
          }}
          contentContainerStyle={{ paddingBottom: 32 }}
        />
      )}
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
  },
  heading: {
    color: COLORS.textPrimary,
    fontSize: 24,
    fontWeight: "bold",
    paddingHorizontal: 16,
    paddingTop: 16,
    paddingBottom: 8,
  },
  errorText: {
    color: COLORS.error,
    textAlign: "center",
    marginTop: 40,
    paddingHorizontal: 32,
  },
  empty: {
    color: COLORS.textSecondary,
    textAlign: "center",
    marginTop: 80,
  },
  row: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.surface,
  },
  rowContent: {
    marginLeft: 12,
    flex: 1,
  },
  rowTitle: {
    color: COLORS.textPrimary,
    fontWeight: "600",
    fontSize: 16,
  },
  rowSubtitle: {
    color: COLORS.textSecondary,
    fontSize: 14,
    marginTop: 2,
  },
});
