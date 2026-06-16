import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class DialerGestureNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const DialerGestureNav({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  State<DialerGestureNav> createState() => _DialerGestureNavState();
}

class _DialerGestureNavState extends State<DialerGestureNav> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  
  bool _isActive = false;
  int _hoveredIndex = -1;

  final double _maxRadius = 140.0;

  final List<IconData> _icons = [
    Icons.home_filled,
    Icons.search,
    Icons.add_box,
    Icons.chat_bubble,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _expandAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isActive = true;
      _hoveredIndex = widget.currentIndex;
    });
    _controller.forward();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      // The GestureDetector wraps the SizedBox of size (_maxRadius * 2, _maxRadius + 40).
      // The trigger button is at the bottom center of this box.
      // We want to calculate the angle relative to the center of the trigger button.
      // The X center is at width / 2 = _maxRadius.
      // The Y center of the trigger button is at height - 30.
      final originX = _maxRadius;
      final originY = _maxRadius + 40.0 - 30.0;
      
      final dx = details.localPosition.dx - originX;
      // In Flutter, Y grows downward. We want positive Y to be UP, so we invert.
      final dy = originY - details.localPosition.dy;
      
      final distance = math.sqrt(dx * dx + dy * dy);
      
      if (distance > 40) {
        // Find angle in degrees (0 to 180, where 90 is straight up)
        double angle = math.atan2(dy, dx) * 180 / math.pi;
        if (angle < 0) angle += 360; // Just in case they drag down
        
        // Target angles: 0(Profile=20), 1(Messages=55), 2(Create=90), 3(Search=125), 4(Home=160)
        // Note: The UI is Home (0) at left, meaning 160 deg.
        final targetAngles = [160.0, 125.0, 90.0, 55.0, 20.0];
        
        int closestIndex = _hoveredIndex;
        double minDiff = 360.0;
        
        for (int i = 0; i < targetAngles.length; i++) {
          final diff = (angle - targetAngles[i]).abs();
          if (diff < minDiff) {
            minDiff = diff;
            closestIndex = i;
          }
        }
        
        // Only switch if we are pointing roughly within the top half
        if (dy > 0 || distance > 80) {
           _hoveredIndex = closestIndex;
        }
      } else {
        _hoveredIndex = widget.currentIndex;
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_hoveredIndex != -1 && _hoveredIndex != widget.currentIndex) {
      widget.onDestinationSelected(_hoveredIndex);
    }
    
    setState(() {
      _isActive = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _expandAnimation.value;
        final blur = val * 8.0;
        
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background Blur Overlay
            if (val > 0)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    color: Theme.of(context).colorScheme.surface.withOpacity(val * 0.4),
                  ),
                ),
              ),
              
            // The Dial Area
            Positioned(
              bottom: 30,
              child: GestureDetector(
                onPanStart: _handlePanStart,
                onPanUpdate: _handlePanUpdate,
                onPanEnd: _handlePanEnd,
                child: SizedBox(
                  width: _maxRadius * 2,
                  height: _maxRadius + 40,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Render Icons
                      for (int i = 0; i < _icons.length; i++)
                        _buildNavItem(i, val),
                        
                      // Trigger Button
                      Positioned(
                        bottom: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isActive ? 60 : 180,
                          height: _isActive ? 60 : 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                          ),
                          child: Center(
                            child: _isActive 
                              ? Icon(Icons.touch_app, color: Theme.of(context).colorScheme.onPrimaryContainer)
                              : Text(
                                  'Hold & Drag to Navigate', 
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem(int index, double animationValue) {
    final targetAngles = [160.0, 125.0, 90.0, 55.0, 20.0];
    final angle = targetAngles[index] * math.pi / 180;
    
    // Calculate final position
    final dx = math.cos(angle) * _maxRadius;
    final dy = -(math.sin(angle) * _maxRadius); // negative because Y goes down
    
    final isHovered = index == _hoveredIndex;
    final isSelected = index == widget.currentIndex;
    
    // Animate position from origin (0,0) to target (dx, dy)
    final currentDx = dx * animationValue;
    final currentDy = dy * animationValue;
    
    // Scale and color based on hover state
    final scale = isHovered ? 1.3 : (isSelected && animationValue < 0.1 ? 1.1 : 1.0);
    final color = isHovered 
        ? Theme.of(context).colorScheme.primary 
        : Theme.of(context).colorScheme.onSurface;

    return Positioned(
      bottom: 30 - currentDy, // 30 is to align with the center of the trigger button
      left: _maxRadius + currentDx - 25, // center horizontally
      child: Transform.scale(
        scale: scale * (0.2 + animationValue * 0.8), // start tiny, grow to full size
        child: Opacity(
          opacity: animationValue.clamp(0.0, 1.0),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHovered 
                  ? Theme.of(context).colorScheme.primaryContainer 
                  : Theme.of(context).colorScheme.surface,
              boxShadow: isHovered ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ] : [],
            ),
            child: Icon(
              _icons[index],
              color: color,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
