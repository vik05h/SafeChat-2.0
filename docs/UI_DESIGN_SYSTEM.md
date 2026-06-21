# SafeChat UI Design System (V1)

SafeChat implements a multi-theme design system supporting exactly two distinct switchable designs. The UI components must adapt to both themes elegantly, as they serve different user preferences while maintaining the core mission of the app.

---

## Theme 1: Material 3 (Standard)

This design provides a familiar, system-native experience. It is highly accessible, legible, and professional. It serves as the standard, dependable fallback theme for SafeChat, ensuring users who prefer a conventional UI can navigate the app comfortably.

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

---

## Theme 2: Softer Neobrutalism (Custom)

This design directly targets the teenage demographic of SafeChat. By softening the classic "harsh" Neobrutalism (replacing pure black with dark grey, and bright primary colors with pastels), it maintains a trendy, modern look while feeling safe, welcoming, and less aggressive—aligning with the app's anti-bullying mission.

### 1. Style Definition
- **Type:** Playful, Accessible, Pastel, Structured
- **Keywords:** Pastel colors, dark grey borders, sharp offset shadows, clear typography, approachability, anti-cyberbullying
- **Light/Dark:** Light mode optimized (Pastels); Dark mode uses deep muted tones with lighter grey borders.

### 2. Color Palette
- **Primary Base:** Muted pastels (e.g., Soft Lavender, Mint Green, Peach)
- **Borders & Shadows:** Dark Grey (`#333333` or `#2D2D2D`) instead of pure black.
- **Background:** Off-white (`#F8F9FA`) or warm cream.

### 3. Visual Effects
- **Borders:** 2px to 3px solid dark grey.
- **Shadows:** Hard offset shadows without blur (e.g., `4px 4px 0px #333333`).
- **Corners:** Slightly rounded (e.g., `8px` or `12px` border radius) to maintain a soft, safe feel for the teen demographic.

### 4. Component Stylings (Flutter)
When building Flutter widgets for this theme, avoid standard Material widgets' default shadows/borders. Instead, use custom containers:

```dart
Container(
  decoration: BoxDecoration(
    color: pastelColor, // e.g., Color(0xFFB5EAD7)
    border: Border.all(color: const Color(0xFF333333), width: 2),
    borderRadius: BorderRadius.circular(8),
    boxShadow: const [
      BoxShadow(
        color: Color(0xFF333333),
        offset: Offset(4, 4),
        blurRadius: 0, // Sharp shadow
      ),
    ],
  ),
)
```
- **Inputs:** 2px border, slightly thicker on focus. Offset shadow active on focus.

### 5. Typography
- **Font Family:** A clean, geometric or slightly playful sans-serif (e.g., `Outfit`, `Epilogue`, or `Space Grotesk`).
- **Weights:** Heavy weights (700+) for headings to keep the brutalist structural feel, medium (500) for body text.
