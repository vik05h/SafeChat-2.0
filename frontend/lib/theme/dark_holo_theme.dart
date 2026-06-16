import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dark_holo_colors.dart';

class DarkHoloTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: HoloColors.bgVoid,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        surface: HoloColors.bgCard,
        surfaceContainer: HoloColors.bgSurface,
        primary: HoloColors.glowPurple,
        primaryContainer: Color(0xFF2D1B69),
        onPrimary: HoloColors.textPrimary,
        secondary: HoloColors.glowCyan,
        secondaryContainer: Color(0xFF0C3544),
        onSecondary: HoloColors.textPrimary,
        tertiary: HoloColors.glowPink,
        error: HoloColors.dangerRed,
        onSurface: HoloColors.textPrimary,
        onSurfaceVariant: HoloColors.textSecondary,
        outline: HoloColors.borderSubtle,
        outlineVariant: HoloColors.borderGlow,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.exo2(
          color: HoloColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.exo2(
          color: HoloColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.exo2(
          color: HoloColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.exo2(
          color: HoloColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          color: HoloColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: GoogleFonts.inter(
          color: HoloColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(color: HoloColors.textPrimary),
        bodyMedium: GoogleFonts.inter(color: HoloColors.textSecondary),
        labelSmall: GoogleFonts.jetBrainsMono(
          color: HoloColors.textSecondary,
          fontSize: 10,
        ),
      ),
      iconTheme: const IconThemeData(color: HoloColors.textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: HoloColors.bgVoid,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.exo2(
          color: HoloColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: HoloColors.textSecondary),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: HoloColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: HoloColors.borderGlow, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: HoloColors.borderSubtle,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HoloColors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HoloColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HoloColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HoloColors.glowPurple, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: HoloColors.textMuted),
      ),
    );
  }

  // Dark Holo is always dark — no light variant
  static ThemeData get lightTheme => darkTheme;
}
