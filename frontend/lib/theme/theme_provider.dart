import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    return AppThemeMode.material3;
  }

  void toggleTheme() {
    state = state == AppThemeMode.material3
        ? AppThemeMode.neobrutalism
        : AppThemeMode.material3;
  }
  
  void setTheme(AppThemeMode mode) {
    state = mode;
  }
}

class BrightnessNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.system; // Default to system brightness
  }

  void toggleBrightness() {
    if (state == ThemeMode.system) {
      state = ThemeMode.dark;
    } else if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }

  void setBrightness(ThemeMode mode) {
    state = mode;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(() {
  return ThemeNotifier();
});

final brightnessProvider = NotifierProvider<BrightnessNotifier, ThemeMode>(() {
  return BrightnessNotifier();
});
