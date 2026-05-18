// frontend/app/(app)/profile.tsx
import { View, Text, StyleSheet } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { signOut } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { useCurrentUser } from "@/hooks/useAuth";
import { useProfileStore } from "@/lib/store";
import { Avatar } from "@/components/ui/Avatar";
import { Button } from "@/components/ui/Button";
import { COLORS } from "@/constants/theme";

export default function ProfileScreen() {
  const user = useCurrentUser();
  const profile = useProfileStore((s) => s.profile);
  const clearProfile = useProfileStore((s) => s.clearProfile);

  async function handleSignOut() {
    clearProfile();
    await signOut(auth);
  }

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.heading}>Profile</Text>

      <View style={styles.profileSection}>
        <Avatar
          uid={user?.uid ?? ""}
          size={84}
          displayName={user?.displayName ?? undefined}
        />
        <Text style={styles.displayName}>
          {user?.displayName ?? "Anonymous"}
        </Text>
        {profile?.username ? (
          <Text style={styles.username}>@{profile.username}</Text>
        ) : null}
        {user?.email ? (
          <Text style={styles.email}>{user.email}</Text>
        ) : null}

        {profile && (
          <View style={styles.statsRow}>
            <View style={styles.stat}>
              <Text style={styles.statNumber}>{profile.followers_count}</Text>
              <Text style={styles.statLabel}>Followers</Text>
            </View>
            <View style={styles.stat}>
              <Text style={styles.statNumber}>{profile.following_count}</Text>
              <Text style={styles.statLabel}>Following</Text>
            </View>
          </View>
        )}
      </View>

      <Button title="Sign Out" onPress={handleSignOut} variant="outline" />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
    paddingHorizontal: 24,
  },
  heading: {
    color: COLORS.textPrimary,
    fontSize: 24,
    fontWeight: "bold",
    paddingTop: 16,
    paddingBottom: 8,
  },
  profileSection: {
    alignItems: "center",
    marginTop: 24,
    marginBottom: 40,
  },
  displayName: {
    color: COLORS.textPrimary,
    fontSize: 20,
    fontWeight: "bold",
    marginTop: 16,
  },
  username: {
    color: COLORS.textSecondary,
    fontSize: 16,
    marginTop: 4,
  },
  email: {
    color: COLORS.textTertiary,
    fontSize: 14,
    marginTop: 4,
  },
  statsRow: {
    flexDirection: "row",
    marginTop: 24,
    gap: 32,
  },
  stat: {
    alignItems: "center",
  },
  statNumber: {
    color: COLORS.textPrimary,
    fontSize: 18,
    fontWeight: "bold",
  },
  statLabel: {
    color: COLORS.textSecondary,
    fontSize: 12,
  },
});
