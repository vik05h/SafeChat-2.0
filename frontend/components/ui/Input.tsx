// frontend/components/ui/Input.tsx
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  type TextInputProps,
  type ViewStyle,
} from "react-native";
import { COLORS, BORDER_RADIUS } from "@/constants/theme";

interface InputProps extends TextInputProps {
  label?: string;
  error?: string;
  containerStyle?: ViewStyle;
}

export function Input({ label, error, containerStyle, ...rest }: InputProps) {
  return (
    <View style={containerStyle}>
      {label ? (
        <Text style={styles.label}>{label}</Text>
      ) : null}
      <TextInput
        style={[styles.input, error ? styles.inputError : styles.inputNormal]}
        placeholderTextColor={COLORS.textTertiary}
        selectionColor={COLORS.primary}
        autoCorrect={false}
        {...rest}
      />
      {error ? (
        <Text style={styles.error}>{error}</Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  label: {
    color: COLORS.textSecondary,
    fontSize: 14,
    fontWeight: "500",
    marginBottom: 6,
  },
  input: {
    backgroundColor: COLORS.surface,
    borderWidth: 1,
    borderRadius: BORDER_RADIUS.md,
    paddingHorizontal: 16,
    paddingVertical: 14,
    color: COLORS.textPrimary,
    fontSize: 16,
  },
  inputNormal: {
    borderColor: COLORS.surface2,
  },
  inputError: {
    borderColor: COLORS.error,
  },
  error: {
    color: COLORS.error,
    fontSize: 12,
    marginTop: 6,
  },
});
