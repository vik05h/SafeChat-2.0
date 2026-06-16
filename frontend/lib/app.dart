import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'router/app_router.dart';

class SafeChatApp extends ConsumerWidget {
  const SafeChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'SafeChat',
      theme: AppTheme.getTheme(themeMode),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
