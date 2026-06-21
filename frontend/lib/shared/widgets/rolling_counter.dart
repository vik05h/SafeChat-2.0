import 'package:flutter/material.dart';

class RollingCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const RollingCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<RollingCounter> createState() => _RollingCounterState();
}

class _RollingCounterState extends State<RollingCounter> {
  late int _oldCount;

  @override
  void initState() {
    super.initState();
    _oldCount = widget.value;
  }

  @override
  void didUpdateWidget(covariant RollingCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldCount = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncreasing = widget.value > _oldCount;

    return AnimatedSwitcher(
      duration: widget.duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // If the child is the current widget (entering)
        final isEntering = child.key == ValueKey(widget.value);

        Offset beginOffset;
        if (isEntering) {
          beginOffset = isIncreasing
              ? const Offset(0.0, 1.0)
              : const Offset(0.0, -1.0);
        } else {
          beginOffset = isIncreasing
              ? const Offset(0.0, -1.0)
              : const Offset(0.0, 1.0);
        }

        return ClipRect(
          child: SlideTransition(
            position: Tween<Offset>(begin: beginOffset, end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: FadeTransition(opacity: animation, child: child),
          ),
        );
      },
      child: Text(
        '${widget.value}',
        key: ValueKey<int>(widget.value),
        style: widget.style,
      ),
    );
  }
}
