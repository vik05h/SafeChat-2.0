import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../theme/dark_holo_colors.dart';
import '../../../auth/presentation/auth_provider.dart';

class HoloProfileView extends ConsumerStatefulWidget {
  const HoloProfileView({super.key});

  @override
  ConsumerState<HoloProfileView> createState() => _HoloProfileViewState();
}

class _HoloProfileViewState extends ConsumerState<HoloProfileView>
    with TickerProviderStateMixin {
  late AnimationController _auraCtrl;
  late AnimationController _statsCtrl;

  @override
  void initState() {
    super.initState();
    _auraCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _statsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _auraCtrl.dispose();
    _statsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final profile = ref.watch(authStateProvider).profile;

    return Scaffold(
      backgroundColor: HoloColors.bgVoid,
      body: CustomScrollView(
        slivers: [
          // Custom header/avatar area
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16),
              child: Column(
                children: [
                  // Top Row: back area + settings icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          profile?.username ?? user?.displayName ?? 'you',
                          style: const TextStyle(
                            color: HoloColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: 0.3,
                          ),
                        ),
                        _GlowIconButton(
                          icon: Icons.settings_outlined,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const HoloSettingsView()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Animated Aura Avatar
                  _HoloAuraAvatar(
                    controller: _auraCtrl,
                    photoUrl: user?.photoURL,
                  ).animate().scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),

                  const SizedBox(height: 16),
                  Text(
                    profile?.displayName ?? user?.displayName ?? 'SafeChat User',
                    style: const TextStyle(
                      color: HoloColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'creating a safer digital space 🛡️',
                    style: TextStyle(color: HoloColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // Stat Cluster — icon-only, no text labels
                  _HoloStatCluster(controller: _statsCtrl),

                  const SizedBox(height: 20),

                  // Action Buttons (icon + minimal label)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _HoloOutlineButton(
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HoloOutlineButton(
                            icon: Icons.ios_share_outlined,
                            label: 'Share',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        _HoloOutlineButton(
                          icon: Icons.person_add_alt_1_outlined,
                          onTap: () {},
                          isSquare: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Post Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _HoloGridTile(index: index),
                childCount: 15,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 180)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AURA AVATAR
// ─────────────────────────────────────────────
class _HoloAuraAvatar extends StatelessWidget {
  final AnimationController controller;
  final String? photoUrl;

  const _HoloAuraAvatar({required this.controller, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        // Cycle through purple → cyan → pink → purple
        final hue = (t * 360) % 360;
        final auraColor = HSLColor.fromAHSL(1.0, hue, 0.8, 0.6).toColor();

        return Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: auraColor.withOpacity(0.7), blurRadius: 30, spreadRadius: 4),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                startAngle: t * 2 * math.pi,
                endAngle: t * 2 * math.pi + 2 * math.pi,
                colors: [
                  HoloColors.glowPurple,
                  HoloColors.glowCyan,
                  HoloColors.glowPink,
                  HoloColors.glowPurple,
                ],
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              backgroundColor: HoloColors.bgCard,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
              child: photoUrl == null
                  ? const Icon(Icons.person, color: HoloColors.textSecondary, size: 44)
                  : null,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  STAT CLUSTER
// ─────────────────────────────────────────────
class _HoloStatCluster extends StatelessWidget {
  final AnimationController controller;

  const _HoloStatCluster({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatPill(
          icon: Icons.auto_awesome,
          value: '10.4K',
          color: HoloColors.glowPurple,
          label: 'Vibes',
          controller: controller,
          delay: 0,
        ),
        const SizedBox(width: 10),
        _StatPill(
          icon: Icons.bolt,
          value: '14',
          color: HoloColors.moodHappy,
          label: 'Streak',
          controller: controller,
          delay: 150,
        ),
        const SizedBox(width: 10),
        _StatPill(
          icon: Icons.shield_rounded,
          value: '98',
          color: HoloColors.safeGreen,
          label: 'Safe',
          controller: controller,
          delay: 300,
        ),
        const SizedBox(width: 10),
        _StatPill(
          icon: Icons.grid_view_rounded,
          value: '12',
          color: HoloColors.glowCyan,
          label: 'Posts',
          controller: controller,
          delay: 450,
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final String label;
  final AnimationController controller;
  final int delay;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.color,
    required this.label,
    required this.controller,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: controller.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - controller.value)),
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.4), width: 1),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.2), blurRadius: 12),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: HoloColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(
          begin: 0.2,
          delay: delay.ms,
          duration: 500.ms,
          curve: Curves.easeOutBack,
        );
  }
}

// ─────────────────────────────────────────────
//  OUTLINE BUTTON
// ─────────────────────────────────────────────
class _HoloOutlineButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final bool isSquare;

  const _HoloOutlineButton({
    required this.icon,
    this.label,
    required this.onTap,
    this.isSquare = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: isSquare ? 42 : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HoloColors.borderGlow, width: 1),
          color: HoloColors.bgCard,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: HoloColors.textSecondary, size: 18),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: const TextStyle(
                  color: HoloColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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
//  GRID TILE
// ─────────────────────────────────────────────
class _HoloGridTile extends StatelessWidget {
  final int index;
  const _HoloGridTile({required this.index});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        'https://picsum.photos/seed/${index + 50}/300/300',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(color: HoloColors.bgSurface),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: HoloColors.bgSurface.withOpacity(0.7),
          border: Border.all(color: HoloColors.borderGlow, width: 1),
        ),
        child: Icon(icon, color: HoloColors.textSecondary, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HOLO SETTINGS VIEW
// ─────────────────────────────────────────────
class HoloSettingsView extends ConsumerWidget {
  const HoloSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HoloColors.bgVoid,
      appBar: AppBar(
        backgroundColor: HoloColors.bgVoid,
        title: const Text('Settings', style: TextStyle(color: HoloColors.textPrimary)),
        iconTheme: const IconThemeData(color: HoloColors.textSecondary),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HoloSettingsTile(
            icon: Icons.palette_outlined,
            title: 'App Theme',
            subtitle: 'Switch between Dark Holo, Material 3 & Neobrutalism',
            onTap: () {
              _showThemePicker(context, ref);
            },
          ),
          const SizedBox(height: 8),
          _HoloSettingsTile(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            subtitle: 'See you next time 👋',
            color: HoloColors.dangerRed,
            onTap: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HoloColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ThemePicker(),
    );
  }
}

class _HoloSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _HoloSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? HoloColors.glowPurple;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HoloColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.withOpacity(0.15),
              ),
              child: Icon(icon, color: c, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: c, fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: HoloColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: c.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

// Theme picker bottom sheet
class _ThemePicker extends ConsumerWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // import AppThemeMode
    return const SizedBox(); // placeholder — filled in after theme_provider update
  }
}
