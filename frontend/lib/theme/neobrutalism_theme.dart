import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class NeobrutalismTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.neoBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.neoPrimary,
        secondary: AppColors.neoSecondary,
        surface: AppColors.neoSurface,
        error: AppColors.neoError,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neoBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: AppColors.neoBorder,
            width: AppColors.neoBorderWidth,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neoPrimary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: AppColors.neoBorder,
              width: AppColors.neoBorderWidth,
            ),
          ),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return 0; // Flat when pressed
            }
            return 0; // We handle the shadow in a custom wrapper usually, but for standard buttons:
          }),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.neoSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.neoBorder,
            width: AppColors.neoBorderWidth,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neoSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.neoBorder,
            width: AppColors.neoBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.neoBorder,
            width: AppColors.neoBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.neoBorder,
            width: AppColors.neoBorderWidth + 1,
          ),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
