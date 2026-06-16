import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

class SafeChatApp extends ConsumerWidget {
  const SafeChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeStyle = ref.watch(themeProvider);
    final themeMode = ref.watch(brightnessProvider);
    final router = ref.watch(appRouterProvider);

    // Dark Holo is always dark — force ThemeMode.dark
    final effectiveBrightness = themeStyle == AppThemeMode.darkHolo
        ? ThemeMode.dark
        : themeMode;

    return MaterialApp.router(
      title: 'SafeChat',
      debugShowCheckedModeBanner: false,
      themeMode: effectiveBrightness,
      theme: AppTheme.getLightTheme(themeStyle),
      darkTheme: AppTheme.getDarkTheme(themeStyle),
      routerConfig: router,
    );
  }
}
