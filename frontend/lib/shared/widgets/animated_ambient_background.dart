import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme_provider.dart';

class AnimatedAmbientBackground extends ConsumerStatefulWidget {
  final String imageUrl;
  final double height;

  const AnimatedAmbientBackground({
    super.key,
    required this.imageUrl,
    this.height = 800, // Extends deep into the content area
  });

  @override
  ConsumerState<AnimatedAmbientBackground> createState() => _AnimatedAmbientBackgroundState();
}

class _AnimatedAmbientBackgroundState extends ConsumerState<AnimatedAmbientBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Extremely slow pulse
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAmbientEnabled = ref.watch(ambientModeProvider);

    if (!isAmbientEnabled) {
      return const SizedBox.shrink(); // Turns off completely
    }

    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: -100, // Overscan slightly for scaling bounds
            right: -100,
            height: widget.height,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: ImageFiltered(
                imageFilter: dart_ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scaffoldColor.withValues(alpha: 0.1),
                    scaffoldColor.withValues(alpha: 0.8),
                    scaffoldColor,
                  ],
                  stops: const [0.0, 0.4, 0.7],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
