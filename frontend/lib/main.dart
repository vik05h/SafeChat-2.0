import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/router/router.dart';
import 'app/theme/app_theme.dart';
import 'features/notifications/services/fcm_service.dart';
import 'shared/widgets/no_connection_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Assuming options will be added later based on the actual platform)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: SafeChatApp(),
    ),
  );
}

class SafeChatApp extends ConsumerStatefulWidget {
  const SafeChatApp({super.key});

  @override
  ConsumerState<SafeChatApp> createState() => _SafeChatAppState();
}

class _SafeChatAppState extends ConsumerState<SafeChatApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);
      ref.read(fcmServiceProvider).initialize(router);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SafeChat',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Enforce dark mode as per spec
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return NoConnectionBanner(child: child!);
      },
    );
  }
}
