import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'theme/material3_theme.dart';
import 'theme/neobrutalism_theme.dart';
import 'router/app_router.dart';

class SafeChatApp extends ConsumerWidget {
  const SafeChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeStyle = ref.watch(themeProvider);
    final themeMode = ref.watch(brightnessProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'SafeChat',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: themeStyle == AppThemeMode.material3 
          ? Material3Theme.lightTheme 
          : NeobrutalismTheme.lightTheme,
      darkTheme: themeStyle == AppThemeMode.material3
          ? Material3Theme.darkTheme
          : NeobrutalismTheme.darkTheme,
      routerConfig: router,
    );
  }
}
