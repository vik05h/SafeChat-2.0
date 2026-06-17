import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../firebase_options.dart';
import 'auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      
      // Let the beautiful animation play for a moment
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        await ref.read(authControllerProvider.notifier).checkAuthStatus();
        final authState = ref.read(authStateProvider);
        
        if (mounted) {
          if (authState.isAuthenticated) {
            if (authState.needsOnboarding) {
              context.go('/onboarding');
            } else {
              context.go('/home');
            }
          } else {
            context.go('/login');
          }
        }
      }
    } catch (e) {
      debugPrint('Firebase init failed: $e');
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_rounded,
              size: 80,
              color: Colors.blueAccent,
            ).animate().fade(duration: 500.ms).scale(curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            const Text(
              'SafeChat',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fade(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.5, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 8),
            const Text(
              'A safe place to connect.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            )
                .animate()
                .fade(delay: 600.ms, duration: 500.ms)
                .slideY(begin: 0.5, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 48),
            const CircularProgressIndicator()
                .animate()
                .fade(delay: 900.ms),
          ],
        ),
      ),
    );
  }
}
