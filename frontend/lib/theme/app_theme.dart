import 'package:flutter/material.dart';
import 'material3_theme.dart';
import 'neobrutalism_theme.dart';

enum AppThemeMode {
  material3,
  neobrutalism,
}

class AppTheme {
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.material3:
        return Material3Theme.theme;
      case AppThemeMode.neobrutalism:
        return NeobrutalismTheme.theme;
    }
  }
}
