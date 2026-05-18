// frontend/app/(app)/_layout.tsx
import { Tabs } from "expo-router";
import { View, Text, StyleSheet } from "react-native";
import { COLORS, BORDER_RADIUS } from "@/constants/theme";

export default function AppLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: COLORS.surface,
          borderTopColor: COLORS.border,
          borderTopWidth: 1,
        },
        tabBarActiveTintColor: COLORS.primary,
        tabBarInactiveTintColor: COLORS.textSecondary,
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: "500",
        },
      }}
    >
      <Tabs.Screen name="feed" options={{ title: "Feed" }} />
      <Tabs.Screen
        name="create-post"
        options={{
          title: "",
          tabBarLabel: "",
          tabBarIcon: ({ focused }) => (
            <View style={[styles.createIcon, focused && styles.createIconFocused]}>
              <Text style={styles.createIconText}>+</Text>
            </View>
          ),
        }}
      />
      <Tabs.Screen name="messages" options={{ title: "Messages" }} />
      <Tabs.Screen name="profile" options={{ title: "Profile" }} />
    </Tabs>
  );
}

const styles = StyleSheet.create({
  createIcon: {
    width: 44,
    height: 28,
    borderRadius: BORDER_RADIUS.md,
    backgroundColor: COLORS.primary,
    alignItems: "center",
    justifyContent: "center",
  },
  createIconFocused: {
    backgroundColor: COLORS.primaryDark,
  },
  createIconText: {
    color: COLORS.textPrimary,
    fontSize: 22,
    fontWeight: "300",
    lineHeight: 26,
  },
});
