import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../theme/theme_provider.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final layout = ref.watch(profileLayoutProvider);

    return Scaffold(
      body: layout == ProfileLayoutStyle.modernCover
          ? _buildModernCover(context, user)
          : _buildCenteredMinimalist(context, user),
    );
  }

  Widget _buildModernCover(BuildContext context, dynamic user) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsView())),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://picsum.photos/seed/cover/800/400',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent, Theme.of(context).scaffoldBackgroundColor],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                          child: user?.photoURL == null ? const Icon(Icons.person, size: 40) : null,
                        ),
                      ),
                      const Spacer(),
                      FilledButton.tonal(
                        onPressed: () {},
                        child: const Text('Edit Profile'),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'SafeChat User',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('@${user?.displayName?.toLowerCase().replaceAll(' ', '') ?? 'user'}'),
                      const SizedBox(height: 16),
                      const Text('Creating a safer social space 🛡️\n#flutter #dev'),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatColumn(label: 'Posts', count: '12'),
                            _StatColumn(label: 'Followers', count: '1.2k'),
                            _StatColumn(label: 'Following', count: '450'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildGrid(),
      ],
    );
  }

  Widget _buildCenteredMinimalist(BuildContext context, dynamic user) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(user?.displayName ?? 'Profile'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsView())),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? 'SafeChat User',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Creating a safer social space 🛡️\n#flutter #dev', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatColumn(label: 'Posts', count: '12'),
                    SizedBox(width: 32),
                    _StatColumn(label: 'Followers', count: '1.2k'),
                    SizedBox(width: 32),
                    _StatColumn(label: 'Following', count: '450'),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.tonal(
                      onPressed: () {},
                      child: const Text('Edit Profile'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.tonal(
                      onPressed: () {},
                      child: const Text('Share Profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(),
              ],
            ),
          ),
        ),
        _buildGrid(),
      ],
    );
  }

  Widget _buildGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            image: DecorationImage(
              image: NetworkImage('https://picsum.photos/seed/${index + 50}/300/300'),
              fit: BoxFit.cover,
            ),
          ),
        );
      }, childCount: 15),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String count;

  const _StatColumn({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLayout = ref.watch(feedLayoutProvider);
    final navbarStyle = ref.watch(navbarStyleProvider);
    final profileLayout = ref.watch(profileLayoutProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Feed Layout',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LayoutCard(
                label: 'Grid Feed',
                icon: Icons.grid_view_rounded,
                color: Theme.of(context).colorScheme.primary,
                isSelected: currentLayout == FeedLayoutMode.grid,
                onTap: () => ref.read(feedLayoutProvider.notifier).setLayout(FeedLayoutMode.grid),
              ),
              const SizedBox(width: 16),
              _LayoutCard(
                label: 'Card Feed',
                icon: Icons.view_agenda_rounded,
                color: Theme.of(context).colorScheme.secondary,
                isSelected: currentLayout == FeedLayoutMode.card,
                onTap: () => ref.read(feedLayoutProvider.notifier).setLayout(FeedLayoutMode.card),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Profile Layout',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SegmentedButton<ProfileLayoutStyle>(
            segments: const [
              ButtonSegment(
                value: ProfileLayoutStyle.modernCover,
                label: Text('Modern Cover', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.panorama),
              ),
              ButtonSegment(
                value: ProfileLayoutStyle.centeredMinimalist,
                label: Text('Minimalist', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.align_vertical_center),
              ),
            ],
            selected: {profileLayout},
            onSelectionChanged: (Set<ProfileLayoutStyle> newSelection) {
              ref.read(profileLayoutProvider.notifier).setStyle(newSelection.first);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Navigation Style',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SegmentedButton<NavbarStyle>(
            segments: const [
              ButtonSegment(
                value: NavbarStyle.standard,
                label: Text('Standard', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.horizontal_rule_rounded),
              ),
              ButtonSegment(
                value: NavbarStyle.hiddenLabels,
                label: Text('Hidden', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.more_horiz),
              ),
              ButtonSegment(
                value: NavbarStyle.floatingPill,
                label: Text('Floating', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.lens_blur),
              ),
            ],
            selected: {navbarStyle},
            onSelectionChanged: (Set<NavbarStyle> newSelection) {
              ref.read(navbarStyleProvider.notifier).setStyle(newSelection.first);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Color Theme',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Consumer(builder: (context, ref, _) {
            final colorTheme = ref.watch(colorThemeProvider);
            return SegmentedButton<ColorThemeStyle>(
              segments: const [
                ButtonSegment(
                  value: ColorThemeStyle.pastelPop,
                  label: Text('Pastel Pop', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.bubble_chart),
                ),
                ButtonSegment(
                  value: ColorThemeStyle.cyberNeon,
                  label: Text('Cyber Neon', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.bolt),
                ),
                ButtonSegment(
                  value: ColorThemeStyle.ultraMinimalist,
                  label: Text('Minimalist', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.architecture),
                ),
              ],
              selected: {colorTheme},
              onSelectionChanged: (Set<ColorThemeStyle> newSelection) {
                ref.read(colorThemeProvider.notifier).setStyle(newSelection.first);
              },
            );
          }),
          const SizedBox(height: 24),
          const Text(
            'Dark Mode',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Consumer(builder: (context, ref, _) {
            final brightness = ref.watch(brightnessProvider);
            return SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.settings_system_daydream),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {brightness},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                ref.read(brightnessProvider.notifier).setBrightness(newSelection.first);
              },
            );
          }),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}

class _LayoutCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _LayoutCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
