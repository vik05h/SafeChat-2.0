import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class NeobrutalismTheme {
  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      background: AppColors.neoBackgroundLight,
      primary: AppColors.neoPrimaryLight,
      secondary: AppColors.neoSecondaryLight,
      surface: AppColors.neoSurfaceLight,
      border: AppColors.neoBorderLight,
      textPrimary: AppColors.textPrimaryLight,
      textSecondary: AppColors.textSecondaryLight,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      background: AppColors.neoBackgroundDark,
      primary: AppColors.neoPrimaryDark,
      secondary: AppColors.neoSecondaryDark,
      surface: AppColors.neoSurfaceDark,
      border: AppColors.neoBorderDark,
      textPrimary: AppColors.textPrimaryDark,
      textSecondary: AppColors.textSecondaryDark,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: textPrimary,
        secondary: secondary,
        onSecondary: textPrimary,
        surface: surface,
        onSurface: textPrimary,
        error: AppColors.neoError,
        onError: textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: border,
            width: AppColors.neoBorderWidth,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: border,
              width: AppColors.neoBorderWidth,
            ),
          ),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) => 0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: border,
              width: AppColors.neoBorderWidth,
            ),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: border,
            width: AppColors.neoBorderWidth,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: border,
            width: AppColors.neoBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: border,
            width: AppColors.neoBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: border,
            width: AppColors.neoBorderWidth + 1,
          ),
        ),
        labelStyle: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: textPrimary,
        suffixIconColor: textPrimary,
      ),
    );
  }
}
