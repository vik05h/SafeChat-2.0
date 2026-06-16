import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/theme_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeChat Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome to SafeChat!'),
      ),
    );
  }
}
