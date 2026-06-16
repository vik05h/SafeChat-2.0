import 'package:flutter/material.dart';
import 'material3_theme.dart';
import 'neobrutalism_theme.dart';
import 'dark_holo_theme.dart';

enum AppThemeMode {
  material3,
  neobrutalism,
  darkHolo,
}

class AppTheme {
  static ThemeData getLightTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.material3:
        return Material3Theme.lightTheme;
      case AppThemeMode.neobrutalism:
        return NeobrutalismTheme.lightTheme;
      case AppThemeMode.darkHolo:
        return DarkHoloTheme.lightTheme;
    }
  }

  static ThemeData getDarkTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.material3:
        return Material3Theme.darkTheme;
      case AppThemeMode.neobrutalism:
        return NeobrutalismTheme.darkTheme;
      case AppThemeMode.darkHolo:
        return DarkHoloTheme.darkTheme;
    }
  }
}
