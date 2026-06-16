import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/dark_holo_colors.dart';

class HoloSearchView extends StatefulWidget {
  const HoloSearchView({super.key});

  @override
  State<HoloSearchView> createState() => _HoloSearchViewState();
}

class _HoloSearchViewState extends State<HoloSearchView> {
  final _controller = TextEditingController();
  bool _focused = false;

  final List<_TrendTag> _tags = const [
    _TrendTag(tag: '#flutter', count: '42K'),
    _TrendTag(tag: '#gen_z', count: '19K'),
    _TrendTag(tag: '#safespace', count: '9.1K'),
    _TrendTag(tag: '#nocyberbully', count: '6.3K'),
    _TrendTag(tag: '#vibecheck', count: '88K'),
    _TrendTag(tag: '#dropthat', count: '11K'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HoloColors.bgVoid,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover',
                  style: TextStyle(
                    color: HoloColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 12),
                // Glass search pill
                GestureDetector(
                  onTap: () => setState(() => _focused = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: HoloColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _focused ? HoloColors.glowPurple : HoloColors.borderSubtle,
                        width: _focused ? 1.5 : 1,
                      ),
                      boxShadow: _focused
                          ? [BoxShadow(color: HoloColors.glowPurple.withOpacity(0.2), blurRadius: 12)]
                          : null,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search_rounded, color: HoloColors.textMuted, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onChanged: (_) => setState(() {}),
                            onTap: () => setState(() => _focused = true),
                            style: const TextStyle(color: HoloColors.textPrimary, fontSize: 15),
                            decoration: const InputDecoration(
                              hintText: 'Search people, tags...',
                              hintStyle: TextStyle(color: HoloColors.textMuted),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _controller.clear()),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 14),
                              child: Icon(Icons.close_rounded, color: HoloColors.textMuted, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trending tags
                  const Text(
                    '🔥 Trending',
                    style: TextStyle(
                      color: HoloColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags
                        .asMap()
                        .entries
                        .map((e) => _TrendChip(tag: e.value)
                            .animate()
                            .fadeIn(delay: (e.key * 50).ms)
                            .slideX(begin: -0.1))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // Suggested users
                  const Text(
                    '✨ People you might vibe with',
                    style: TextStyle(
                      color: HoloColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    6,
                    (i) => _SuggestedUserTile(index: i)
                        .animate()
                        .fadeIn(delay: (i * 70).ms)
                        .slideX(begin: 0.05),
                  ),
                  const SizedBox(height: 24),

                  // Photo grid
                  const Text(
                    '📸 Explore',
                    style: TextStyle(
                      color: HoloColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://picsum.photos/seed/${i + 100}/300/300',
                        fit: BoxFit.cover,
                      ),
                    ).animate().fadeIn(delay: (i * 40).ms),
                  ),
                  const SizedBox(height: 180),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  final _TrendTag tag;
  const _TrendChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: HoloColors.glowPurple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: HoloColors.borderGlow, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tag.tag,
                style: const TextStyle(
                  color: HoloColors.glowPurpleLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                tag.count,
                style: const TextStyle(color: HoloColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestedUserTile extends StatelessWidget {
  final int index;
  const _SuggestedUserTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      HoloColors.glowPurple,
      HoloColors.glowCyan,
      HoloColors.glowPink,
      HoloColors.moodHappy,
      HoloColors.safeGreen,
      HoloColors.moodChill,
    ];
    final c = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: HoloColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HoloColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c, width: 2),
                boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 8)],
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${index + 20}'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'user_drop_$index',
                    style: const TextStyle(
                      color: HoloColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${(index + 1) * 312} vibes',
                    style: const TextStyle(color: HoloColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: c.withOpacity(0.15),
                border: Border.all(color: c.withOpacity(0.5)),
              ),
              child: Icon(Icons.person_add_alt_1_rounded, color: c, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendTag {
  final String tag;
  final String count;
  const _TrendTag({required this.tag, required this.count});
}
