import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import '../../../../firebase_options.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (mounted) {
        context.go('/login');
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
