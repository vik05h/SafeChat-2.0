// frontend/components/ui/LoadingSpinner.tsx
import { ActivityIndicator, View, type ViewStyle } from "react-native";
import { COLORS } from "@/constants/theme";

interface LoadingSpinnerProps {
  size?: "small" | "large";
  color?: string;
  style?: ViewStyle;
}

export function LoadingSpinner({
  size = "large",
  color = COLORS.primary,
  style,
}: LoadingSpinnerProps) {
  return (
    <View style={[{ alignItems: "center", justifyContent: "center" }, style]}>
      <ActivityIndicator size={size} color={color} />
    </View>
  );
}
