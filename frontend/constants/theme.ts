// frontend/constants/theme.ts
/**
 * Design tokens — single source of truth for colours, spacing, and typography.
 * NativeWind covers most cases; use these constants in StyleSheet or inline
 * style props where Tailwind class interpolation isn't possible.
 */

export const COLORS = {
  primary: "#6366F1",
  primaryLight: "#818CF8",
  primaryDark: "#4F46E5",
  background: "#0F0F0F",
  surface: "#1A1A1A",
  surface2: "#2A2A2A",
  textPrimary: "#FFFFFF",
  textSecondary: "#A1A1AA",
  textTertiary: "#71717A",
  error: "#EF4444",
  success: "#22C55E",
  warning: "#F59E0B",
  border: "#27272A",
} as const;

export const FONT_SIZES = {
  xs: 12,
  sm: 14,
  base: 16,
  lg: 18,
  xl: 20,
  "2xl": 24,
  "3xl": 30,
} as const;

export const SPACING = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  "2xl": 48,
} as const;

export const BORDER_RADIUS = {
  sm: 6,
  md: 10,
  lg: 16,
  full: 9999,
} as const;
