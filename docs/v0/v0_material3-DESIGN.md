# Design System: Material 3 (Standard)

## 1. Style Definition
- **Name:** Material Design 3 (M3)
- **Type:** Clean, Professional, System-Native, Fluid
- **Keywords:** Dynamic color, tonal palettes, soft shadows, large rounded corners, typography-driven, predictable
- **Era:** Modern Android / Cross-platform
- **Light/Dark:** ✓ Full dynamic Light and Dark mode support.

## 2. Color Palette
- **Primary Base:** Dynamic (can be extracted from user wallpaper on Android) or a set brand color (e.g., Deep Blue or Purple) expanded into a tonal palette (tones 0 to 100).
- **Surfaces:** `surface`, `surfaceContainer`, `surfaceContainerHighest` using tonal elevation.
- **Accents:** `primary`, `secondary`, `tertiary` with their respective `onPrimary`, `primaryContainer`, etc.

## 3. Visual Effects
- **Borders:** Rarely used. When used (like Outlined buttons), they are thin (1px) and use the `outline` color token.
- **Shadows:** Soft, blurred shadows for elevation (e.g., Level 1 to Level 5 standard Material elevations).
- **Corners:** Heavily rounded. Large components (Cards, Dialogs) often use `24px` to `28px` border radius. Buttons use full rounded pill shapes (`StadiumBorder`).

## 4. Component Stylings (Flutter)
Flutter natively supports Material 3, so implementation relies on built-in widgets and `ThemeData(useMaterial3: true)`.

- **Buttons:**
  - Use built-in `FilledButton`, `ElevatedButton`, `OutlinedButton`, `TextButton`.
  - Rely on `ThemeData` for automatic styling (stadium borders, tonal backgrounds).
- **Cards/Posts:**
  - Use built-in `Card` widget with `elevation: 1` or `elevation: 0` with `color: Theme.of(context).colorScheme.surfaceContainer`.
- **Inputs:**
  - Use `TextField` with `InputDecoration` using `OutlineInputBorder` or `UnderlineInputBorder` strictly following M3 specs.

## 5. Typography
- **Font Family:** `Roboto` or system default.
- **Scale:** Material 3 Type Scale (`displayLarge`, `headlineMedium`, `bodyLarge`, `labelSmall`, etc.).
- **Weights:** Standard weights (400 for body, 500 for titles, 400 for large display text).

## 6. Atmosphere & Target Audience
This design provides a familiar, system-native experience. It is highly accessible, legible, and professional. It serves as the standard, dependable fallback theme for SafeChat, ensuring users who prefer a conventional UI can navigate the app comfortably.
