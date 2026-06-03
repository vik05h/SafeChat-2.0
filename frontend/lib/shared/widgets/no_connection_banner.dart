import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/connectivity_provider.dart';
import '../../app/theme/app_colors.dart';

class NoConnectionBanner extends ConsumerWidget {
  final Widget child;

  const NoConnectionBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectivityProvider);

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        if (connectionState != ConnectionStateStatus.connected)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: connectionState == ConnectionStateStatus.disconnected
                  ? AppColors.error
                  : AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      connectionState == ConnectionStateStatus.disconnected
                          ? Icons.wifi_off
                          : Icons.wifi,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      connectionState == ConnectionStateStatus.disconnected
                          ? 'No Internet Connection'
                          : 'Back Online',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
