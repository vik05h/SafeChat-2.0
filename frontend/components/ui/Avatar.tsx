// frontend/components/ui/Avatar.tsx
/**
 * Displays a user's avatar.
 * Falls back to a coloured circle with initials when no image URL is provided.
 */

import { View, Text, Image } from "react-native";
import { COLORS } from "@/constants/theme";

interface AvatarProps {
  uid: string;
  size?: number;
  avatarUrl?: string | null;
  displayName?: string;
}

export function Avatar({
  uid,
  size = 40,
  avatarUrl,
  displayName,
}: AvatarProps) {
  const initials = displayName
    ? displayName.slice(0, 2).toUpperCase()
    : uid.slice(0, 2).toUpperCase();

  const radius = size / 2;
  const fontSize = Math.round(size * 0.36);

  if (avatarUrl) {
    return (
      <Image
        source={{ uri: avatarUrl }}
        style={{
          width: size,
          height: size,
          borderRadius: radius,
          backgroundColor: COLORS.surface2,
        }}
      />
    );
  }

  return (
    <View
      style={{
        width: size,
        height: size,
        borderRadius: radius,
        backgroundColor: COLORS.primary,
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <Text
        style={{
          color: COLORS.textPrimary,
          fontSize,
          fontWeight: "600",
          lineHeight: fontSize * 1.2,
        }}
      >
        {initials}
      </Text>
    </View>
  );
}
