import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/theme_provider.dart';
import 'theme/material3_theme.dart';
import 'router/app_router.dart';

class SafeChatApp extends ConsumerWidget {
  const SafeChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(brightnessProvider);
    final router = ref.watch(appRouterProvider);
    final colorThemeStyle = ref.watch(colorThemeProvider);

    return MaterialApp.router(
      title: 'SafeChat',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: Material3Theme.lightTheme(colorThemeStyle),
      darkTheme: Material3Theme.darkTheme(colorThemeStyle),
      routerConfig: router,
    );
  }
}
