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

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(() {
  return ThemeNotifier();
});
