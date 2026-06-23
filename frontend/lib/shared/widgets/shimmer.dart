import 'package:flutter/material.dart';

/// Wraps [child] in an animated left-to-right shimmer sweep. Use with opaque
/// skeleton shapes ([ShimmerBox] / [ShimmerFill]) for loading states.
class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Color.lerp(
      base,
      Theme.of(context).colorScheme.onSurface,
      0.10,
    )!;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.30, 0.50, 0.70],
              transform: _SlideGradient(_controller.value * 2 - 1),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double slidePercent;
  const _SlideGradient(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
}

/// A single shimmering skeleton block. Set [shimmer] to false when many boxes
/// share a single parent [Shimmer] (cheaper — one animation drives all of them).
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final bool circle;
  final bool shimmer;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.circle = false,
    this.shimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
    return shimmer ? Shimmer(child: box) : box;
  }
}

/// A shimmering fill that expands to its parent — ideal as an image/media
/// loading placeholder (replaces spinner "dots").
class ShimmerFill extends StatelessWidget {
  const ShimmerFill({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const SizedBox.expand(),
      ),
    );
  }
}
