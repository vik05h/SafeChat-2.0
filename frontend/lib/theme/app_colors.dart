import 'package:flutter/material.dart';

class AppColors {
  // --- New Material 3 Seeds ---

  // 1. Pastel Pop (Vibrant, welcoming, youthful)
  static const Color pastelPopSeed = Color(0xFF9D84FF); // Electric Lavender

  // 2. Cyber Neon (High-energy, gaming-inspired)
  static const Color cyberNeonSeed = Color(0xFFFF007F); // Hot Pink

  // 3. Ultra Minimalist (Stark, high-contrast, slight slate tint)
  static const Color minimalistSeed = Color(0xFF546E7A); // Cool Slate

  // Legacy fallback if needed
  static const Color m3SeedColor = Color(0xFF6200EE);

  /// Brand accent gradient derived from the active color scheme, so it adapts
  /// to every theme variant (Pastel Pop / Cyber Neon / Minimalist). Use for the
  /// wordmark, key CTAs, and highlight surfaces.
  static LinearGradient brandGradient(ColorScheme scheme) => LinearGradient(
    colors: [scheme.primary, scheme.tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
