// frontend/components/ui/Button.tsx
import {
  TouchableOpacity,
  Text,
  ActivityIndicator,
  StyleSheet,
  type TouchableOpacityProps,
} from "react-native";
import { COLORS, BORDER_RADIUS } from "@/constants/theme";

type Variant = "primary" | "outline" | "ghost";

interface ButtonProps extends TouchableOpacityProps {
  title: string;
  loading?: boolean;
  variant?: Variant;
}

export function Button({
  title,
  loading = false,
  variant = "primary",
  disabled,
  style,
  ...rest
}: ButtonProps) {
  const isDisabled = disabled || loading;

  return (
    <TouchableOpacity
      style={[
        styles.base,
        variant === "primary" && styles.variantPrimary,
        variant === "outline" && styles.variantOutline,
        isDisabled && styles.disabled,
        style,
      ]}
      disabled={isDisabled}
      activeOpacity={0.8}
      {...rest}
    >
      {loading && (
        <ActivityIndicator
          size="small"
          color={variant === "primary" ? COLORS.textPrimary : COLORS.primary}
          style={{ marginRight: 8 }}
        />
      )}
      <Text
        style={[
          styles.text,
          variant !== "primary" && styles.textColored,
        ]}
      >
        {title}
      </Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  base: {
    borderRadius: BORDER_RADIUS.md,
    paddingVertical: 14,
    paddingHorizontal: 24,
    alignItems: "center",
    justifyContent: "center",
    flexDirection: "row",
  },
  variantPrimary: {
    backgroundColor: COLORS.primary,
  },
  variantOutline: {
    borderWidth: 1,
    borderColor: COLORS.primary,
    backgroundColor: "transparent",
  },
  disabled: {
    opacity: 0.5,
  },
  text: {
    fontWeight: "600",
    fontSize: 16,
    color: COLORS.textPrimary,
  },
  textColored: {
    color: COLORS.primary,
  },
});
