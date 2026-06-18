import 'dart:ui' as dart_ui;
import 'dart:math' as math;
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // 12 second loop for slow motion
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPulseMode(Widget baseImage) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Pulse scales up and down smoothly
        final scale = 1.0 + 0.15 * math.sin(_controller.value * math.pi * 2).abs();
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: baseImage,
    );
  }

  Widget _buildAuroraMode(Widget baseImage) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * math.pi * 2;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Blob 1 orbiting clockwise
            Transform.translate(
              offset: Offset(math.cos(t) * 120, math.sin(t) * 80),
              child: Transform.scale(scale: 1.2, child: child),
            ),
            // Blob 2 orbiting counter-clockwise and opposite phase
            Transform.translate(
              offset: Offset(math.sin(t * -1) * 100, math.cos(t * -1) * 60),
              child: Transform.scale(scale: 1.3, child: child),
            ),
          ],
        );
      },
      child: baseImage,
    );
  }

  Widget _buildWaveMode(Widget baseImage) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * math.pi * 2;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1 waving up
            Transform.translate(
              offset: Offset(0, math.sin(t) * 120),
              child: Transform.scale(scale: 1.3, child: child),
            ),
            // Layer 2 waving opposite
            Transform.translate(
              offset: Offset(0, math.sin(t + math.pi) * 100),
              child: Transform.scale(scale: 1.2, child: child),
            ),
          ],
        );
      },
      child: baseImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAmbientEnabled = ref.watch(ambientModeProvider);
    final physicsMode = ref.watch(ambientPhysicsProvider);

    if (!isAmbientEnabled) {
      return const SizedBox.shrink(); // Turns off completely
    }

    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    // Cache the extreme blur calculation using RepaintBoundary for performance!
    final baseImage = RepaintBoundary(
      child: ImageFiltered(
        imageFilter: dart_ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );

    Widget physicsWidget;
    switch (physicsMode) {
      case AmbientPhysicsMode.aurora:
        physicsWidget = _buildAuroraMode(baseImage);
        break;
      case AmbientPhysicsMode.wave:
        physicsWidget = _buildWaveMode(baseImage);
        break;
      case AmbientPhysicsMode.pulse:
        physicsWidget = _buildPulseMode(baseImage);
        break;
    }

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            bottom: -100,
            left: -150, // Overscan slightly for scaling bounds
            right: -150,
            child: physicsWidget,
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
