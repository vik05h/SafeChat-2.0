import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'theme_provider.dart';

class Material3Theme {
  static ThemeData lightTheme(ColorThemeStyle style) {
    return _buildTheme(Brightness.light, style);
  }

  static ThemeData darkTheme(ColorThemeStyle style) {
    return _buildTheme(Brightness.dark, style);
  }

  static ThemeData _buildTheme(Brightness brightness, ColorThemeStyle style) {
    Color seedColor;
    switch (style) {
      case ColorThemeStyle.pastelPop:
        seedColor = AppColors.pastelPopSeed;
        break;
      case ColorThemeStyle.cyberNeon:
        seedColor = AppColors.cyberNeonSeed;
        break;
      case ColorThemeStyle.ultraMinimalist:
        seedColor = AppColors.minimalistSeed;
        break;
    }

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final baseTextTheme = ThemeData(brightness: brightness).textTheme;
    final outfitTextTheme = GoogleFonts.outfitTextTheme(baseTextTheme);

    final customTextTheme = outfitTextTheme.copyWith(
      displayLarge: outfitTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1.0),
      displayMedium: outfitTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
      displaySmall: outfitTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
      headlineLarge: outfitTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: outfitTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: outfitTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: outfitTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.15),
      titleMedium: outfitTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.15),
      titleSmall: outfitTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
      bodyLarge: outfitTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, height: 1.5),
      bodyMedium: outfitTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, height: 1.4),
      bodySmall: outfitTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, height: 1.3),
      labelLarge: outfitTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelMedium: outfitTextTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelSmall: outfitTextTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: customTextTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: customTextTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: customTextTheme.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
}
