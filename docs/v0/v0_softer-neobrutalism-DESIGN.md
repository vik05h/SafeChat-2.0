# Design System: Softer Neobrutalism

## 1. Style Definition
- **Name:** Softer Neobrutalism
- **Type:** Playful, Accessible, Pastel, Structured
- **Keywords:** Pastel colors, dark grey borders, sharp offset shadows, clear typography, approachability, anti-cyberbullying
- **Era:** 2020s Modern
- **Light/Dark:** ✓ Light mode optimized (Pastels), Dark mode uses deep muted tones with lighter grey borders.

## 2. Color Palette
- **Primary Base:** Muted pastels (e.g., Soft Lavender, Mint Green, Peach)
- **Borders & Shadows:** Dark Grey (`#333333` or `#2D2D2D`) instead of pure black.
- **Background:** Off-white (`#F8F9FA`) or warm cream.

## 3. Visual Effects
- **Borders:** 2px to 3px solid dark grey.
- **Shadows:** Hard offset shadows without blur (e.g., `4px 4px 0px #333333`).
- **Corners:** Slightly rounded (e.g., `8px` or `12px` border radius) to maintain a soft, safe feel for the teen demographic.

## 4. Component Stylings (Flutter)
When building Flutter widgets for this theme, avoid standard Material widgets' default shadows/borders. Instead, use custom containers:

- **Buttons & Cards:**
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

## 5. Typography
- **Font Family:** A clean, geometric or slightly playful sans-serif (e.g., `Outfit`, `Epilogue`, or `Space Grotesk`).
- **Weights:** Heavy weights (700+) for headings to keep the brutalist structural feel, medium (500) for body text.

## 6. Atmosphere & Target Audience
This design directly targets the teenage demographic of SafeChat. By softening the classic "harsh" Neobrutalism (replacing pure black with dark grey, and bright primary colors with pastels), it maintains a trendy, modern look while feeling safe, welcoming, and less aggressive—aligning with the app's anti-bullying mission.
