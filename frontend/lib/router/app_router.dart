import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/auth/presentation/auth_provider.dart';

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isSplash = state.uri.path == '/splash';
      final isLoggingIn = state.uri.path == '/login';
      final isOnboarding = state.uri.path == '/onboarding';

      // CRITICAL FIX: While auth is loading (or we're on the splash screen),
      // never redirect. Let the SplashScreen handle navigation itself.
      if (isSplash || authState.isLoading) return null;

      final isAuth = authState.isAuthenticated;
      final needsOnboard = authState.needsOnboarding;

      if (!isAuth) {
        return isLoggingIn ? null : '/login';
      }

      if (isAuth && needsOnboard) {
        return isOnboarding ? null : '/onboarding';
      }

      if (isAuth && !needsOnboard) {
        if (isLoggingIn || isOnboarding) {
          return '/home';
        }
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}', textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});
