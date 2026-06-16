import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../theme/dark_holo_colors.dart';

// ─────────────────────────────────────────────
//  HOLO FEED VIEW
// ─────────────────────────────────────────────
class HoloFeedView extends StatefulWidget {
  const HoloFeedView({super.key});

  @override
  State<HoloFeedView> createState() => _HoloFeedViewState();
}

class _HoloFeedViewState extends State<HoloFeedView> {
  // Mock mood data for vibe bar
  final List<_VibeData> _vibes = [
    _VibeData(name: 'You', color: HoloColors.glowPurple, img: 'https://i.pravatar.cc/150?img=1', isOwn: true),
    _VibeData(name: 'kai.x', color: HoloColors.moodHappy, img: 'https://i.pravatar.cc/150?img=2'),
    _VibeData(name: 'z3ro', color: HoloColors.moodChill, img: 'https://i.pravatar.cc/150?img=3'),
    _VibeData(name: 'nova', color: HoloColors.moodHype, img: 'https://i.pravatar.cc/150?img=4'),
    _VibeData(name: 'echo_', color: HoloColors.moodSad, img: 'https://i.pravatar.cc/150?img=5'),
    _VibeData(name: 'pixel', color: HoloColors.moodAngry, img: 'https://i.pravatar.cc/150?img=6'),
    _VibeData(name: 'vex', color: HoloColors.glowCyan, img: 'https://i.pravatar.cc/150?img=7'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HoloColors.bgVoid,
      body: Stack(
        children: [
          // Main scrollable feed
          CustomScrollView(
            slivers: [
              // Top padding
              SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + 16)),

              // Vibe Bar (Stories)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 105,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _vibes.length,
                    itemBuilder: (context, i) => _HoloVibeRing(data: _vibes[i]),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Posts
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _HoloPostCard(index: index)
                      .animate()
                      .fadeIn(delay: (index * 80).ms, duration: 400.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                  childCount: 6,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 180)),
            ],
          ),

          // Floating Glass Header removed as requested
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  VIBE RING (Story Circle)
// ─────────────────────────────────────────────
class _HoloVibeRing extends StatefulWidget {
  final _VibeData data;
  const _HoloVibeRing({required this.data});

  @override
  State<_HoloVibeRing> createState() => _HoloVibeRingState();
}

class _HoloVibeRingState extends State<_HoloVibeRing> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500 + (math.Random().nextInt(800))),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                return Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.color.withOpacity(0.6 * _pulse.value),
                        blurRadius: 16 * _pulse.value,
                        spreadRadius: 2 * _pulse.value,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [widget.data.color, widget.data.color.withOpacity(0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(2.5),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.data.img),
                  backgroundColor: HoloColors.bgCard,
                  child: widget.data.isOwn
                      ? Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: HoloColors.glowPurple,
                              border: Border.all(color: HoloColors.bgVoid, width: 2),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 10),
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.data.name,
              style: const TextStyle(
                color: HoloColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HOLO POST CARD
// ─────────────────────────────────────────────
class _HoloPostCard extends StatefulWidget {
  final int index;
  const _HoloPostCard({required this.index});

  @override
  State<_HoloPostCard> createState() => _HoloPostCardState();
}

class _HoloPostCardState extends State<_HoloPostCard> {
  bool _liked = false;
  int _likeCount = 1024;

  void _handleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: HoloColors.bgCard.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: HoloColors.borderGlow, width: 1),
              boxShadow: [
                BoxShadow(
                  color: HoloColors.glowPurple.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: HoloColors.glowCyan, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: HoloColors.glowCyan.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=${widget.index + 10}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'user_${widget.index}',
                            style: const TextStyle(
                              color: HoloColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const Text(
                            '2m ago',
                            style: TextStyle(color: HoloColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _GlowIconButton(icon: Icons.more_horiz, onTap: () {}),
                    ],
                  ),
                ),

                // Image + right-side actions
                Stack(
                  children: [
                    // Post image
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(0),
                        right: Radius.circular(0),
                      ),
                      child: Image.network(
                        'https://picsum.photos/seed/${widget.index + 20}/600/500',
                        width: double.infinity,
                        height: 340,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 340,
                          color: HoloColors.bgSurface,
                          child: const Icon(Icons.image, color: HoloColors.textMuted, size: 48),
                        ),
                      ),
                    ),

                    // Gradient fade at bottom of image
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              HoloColors.bgCard.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Right-side vertical action column
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Column(
                        children: [
                          _ActionButton(
                            icon: _liked ? Icons.favorite : Icons.favorite_border,
                            color: _liked ? HoloColors.glowPink : HoloColors.textSecondary,
                            glowColor: HoloColors.glowPink,
                            count: _likeCount.toString(),
                            isActive: _liked,
                            onTap: _handleLike,
                          ),
                          const SizedBox(height: 16),
                          _ActionButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            color: HoloColors.textSecondary,
                            glowColor: HoloColors.glowCyan,
                            count: '42',
                            onTap: () {},
                          ),
                          const SizedBox(height: 16),
                          _ActionButton(
                            icon: Icons.near_me_outlined,
                            color: HoloColors.textSecondary,
                            glowColor: HoloColors.glowPurple,
                            count: 'Send',
                            onTap: () {},
                          ),
                          const SizedBox(height: 16),
                          _ActionButton(
                            icon: Icons.bookmark_border_rounded,
                            color: HoloColors.textSecondary,
                            glowColor: HoloColors.moodHappy,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Caption
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 80, 14),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'user_${widget.index} ',
                          style: const TextStyle(
                            color: HoloColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const TextSpan(
                          text: 'just dropped something 🔥 vibe check? #safe #gen_z',
                          style: TextStyle(color: HoloColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTION BUTTON (right side vertical)
// ─────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color glowColor;
  final String? count;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.glowColor,
    this.count,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HoloColors.bgCard.withOpacity(0.8),
                boxShadow: widget.isActive
                    ? [BoxShadow(color: widget.glowColor.withOpacity(0.5), blurRadius: 12)]
                    : null,
              ),
              child: Icon(widget.icon, color: widget.color, size: 22),
            ),
            if (widget.count != null) ...[
              const SizedBox(height: 3),
              Text(
                widget.count!,
                style: const TextStyle(
                  color: HoloColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GLOW ICON BUTTON
// ─────────────────────────────────────────────
class _GlowIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlowIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: HoloColors.bgSurface.withOpacity(0.7),
        ),
        child: Icon(icon, color: HoloColors.textSecondary, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────
class _VibeData {
  final String name;
  final Color color;
  final String img;
  final bool isOwn;

  const _VibeData({
    required this.name,
    required this.color,
    required this.img,
    this.isOwn = false,
  });
}
