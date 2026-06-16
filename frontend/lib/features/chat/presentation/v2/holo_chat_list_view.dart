import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/dark_holo_colors.dart';

class HoloChatListView extends StatelessWidget {
  const HoloChatListView({super.key});

  final List<_ChatData> _chats = const [
    _ChatData(name: 'kai.x', msg: 'bro that post was 🔥', time: '2m', status: _Status.online, img: 'https://i.pravatar.cc/150?img=2', unread: 3),
    _ChatData(name: 'z3ro', msg: 'dropping something soon 👀', time: '15m', status: _Status.inFlow, img: 'https://i.pravatar.cc/150?img=3'),
    _ChatData(name: 'nova_sky', msg: 'Did you see the new update?', time: '1h', status: _Status.onStory, img: 'https://i.pravatar.cc/150?img=4', unread: 1),
    _ChatData(name: 'echo_vibe', msg: 'same time tomorrow?', time: '3h', status: _Status.offline, img: 'https://i.pravatar.cc/150?img=5'),
    _ChatData(name: 'pixel404', msg: 'lol no way 😂', time: '5h', status: _Status.online, img: 'https://i.pravatar.cc/150?img=6'),
    _ChatData(name: 'vex_mode', msg: 'sent you something', time: '1d', status: _Status.offline, img: 'https://i.pravatar.cc/150?img=7'),
    _ChatData(name: 'aurora_z', msg: 'check my story!', time: '2d', status: _Status.onStory, img: 'https://i.pravatar.cc/150?img=8'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HoloColors.bgVoid,
      body: Stack(
        children: [
          // Subtle gradient background pulse
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [HoloColors.glowPurple.withOpacity(0.08), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [HoloColors.glowCyan.withOpacity(0.06), Colors.transparent],
                ),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 20,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Signals',
                        style: TextStyle(
                          color: HoloColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                      const Spacer(),
                      _GlowIconButton(
                        icon: Icons.search_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _GlowIconButton(
                        icon: Icons.edit_square,
                        onTap: () {},
                        isPrimary: true,
                      ),
                    ],
                  ),
                ),
              ),

              // Chat list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _HoloChatTile(data: _chats[i])
                      .animate()
                      .fadeIn(delay: (i * 60).ms, duration: 350.ms)
                      .slideX(begin: -0.05),
                  childCount: _chats.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 180)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HoloChatTile extends StatelessWidget {
  final _ChatData data;
  const _HoloChatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (data.status) {
      _Status.online => HoloColors.statusOnline,
      _Status.inFlow => HoloColors.statusInFlow,
      _Status.onStory => HoloColors.statusOnStory,
      _Status.offline => HoloColors.statusOffline,
    };

    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: data.unread != null
                    ? HoloColors.bgCard.withOpacity(0.95)
                    : HoloColors.bgCard.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: data.unread != null
                      ? HoloColors.borderGlow
                      : HoloColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Avatar with status aura
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(data.status == _Status.offline ? 0 : 0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                          border: Border.all(
                            color: data.status == _Status.offline
                                ? Colors.transparent
                                : statusColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(data.img),
                          backgroundColor: HoloColors.bgSurface,
                        ),
                      ),
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: HoloColors.bgVoid, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 14),

                  // Name + message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: TextStyle(
                            color: HoloColors.textPrimary,
                            fontWeight: data.unread != null ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.msg,
                          style: TextStyle(
                            color: data.unread != null
                                ? HoloColors.textSecondary
                                : HoloColors.textMuted,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Time + unread badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        data.time,
                        style: const TextStyle(color: HoloColors.textMuted, fontSize: 11),
                      ),
                      if (data.unread != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: HoloColors.glowPurple,
                            boxShadow: [
                              BoxShadow(
                                color: HoloColors.glowPurple.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${data.unread}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _GlowIconButton({required this.icon, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary
              ? HoloColors.glowPurple.withOpacity(0.2)
              : HoloColors.bgSurface.withOpacity(0.7),
          border: Border.all(
            color: isPrimary ? HoloColors.glowPurple : HoloColors.borderSubtle,
            width: 1,
          ),
          boxShadow: isPrimary
              ? [BoxShadow(color: HoloColors.glowPurple.withOpacity(0.3), blurRadius: 10)]
              : null,
        ),
        child: Icon(
          icon,
          color: isPrimary ? HoloColors.glowPurple : HoloColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}

enum _Status { online, inFlow, onStory, offline }

class _ChatData {
  final String name;
  final String msg;
  final String time;
  final _Status status;
  final String img;
  final int? unread;

  const _ChatData({
    required this.name,
    required this.msg,
    required this.time,
    required this.status,
    required this.img,
    this.unread,
  });
}
