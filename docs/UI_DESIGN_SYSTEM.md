# SafeChat UI Design System (V1)

SafeChat implements a clean, professional design system based on Material 3. The UI components are built to be accessible, legible, and consistent across all platforms.

---

## Theme: Material 3 (Standard)

This design provides a familiar, system-native experience. It serves as the standard, dependable theme for SafeChat, ensuring users can navigate the app comfortably while maintaining the core mission of the app.

### 1. Style Definition
- **Type:** Clean, Professional, System-Native, Fluid
- **Keywords:** Dynamic color, tonal palettes, soft shadows, large rounded corners, typography-driven, predictable
- **Light/Dark:** Full dynamic Light and Dark mode support.

### 2. Color Palette
- **Primary Base:** Dynamic (can be extracted from user wallpaper on Android) or a set brand color (e.g., Deep Blue or Purple) expanded into a tonal palette (tones 0 to 100).
- **Surfaces:** `surface`, `surfaceContainer`, `surfaceContainerHighest` using tonal elevation.
- **Accents:** `primary`, `secondary`, `tertiary` with their respective container colors.

### 3. Visual Effects
- **Borders:** Rarely used. When used (like Outlined buttons), they are thin (1px) and use the `outline` color token.
- **Shadows:** Soft, blurred shadows for elevation (e.g., Level 1 to Level 5 standard Material elevations).
- **Corners:** Heavily rounded. Large components (Cards, Dialogs) often use `24px` to `28px` border radius. Buttons use full rounded pill shapes (`StadiumBorder`).

### 4. Component Stylings (Flutter)
Flutter natively supports Material 3, so implementation relies on built-in widgets and `ThemeData(useMaterial3: true)`.
- **Buttons:** Use built-in `FilledButton`, `ElevatedButton`, `OutlinedButton`, `TextButton`.
- **Cards/Posts:** Use built-in `Card` widget with `elevation: 1` or `elevation: 0` with `color: Theme.of(context).colorScheme.surfaceContainer`.
- **Inputs:** Use `TextField` with standard `OutlineInputBorder` or `UnderlineInputBorder`.
