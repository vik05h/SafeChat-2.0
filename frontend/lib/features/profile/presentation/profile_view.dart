import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../theme/theme_provider.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import 'edit_profile_view.dart';
import 'follow_providers.dart';
import 'network_graph_view.dart';
import 'content_status_view.dart';
import '../../../shared/widgets/firebase_image.dart';
import 'user_posts_provider.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final layout = ref.watch(profileLayoutProvider);

    return Scaffold(
      body: layout == ProfileLayoutStyle.modernCover
          ? _buildModernCover(context, user, ref)
          : _buildCenteredMinimalist(context, user, ref),
    );
  }

  Widget _buildModernCover(BuildContext context, dynamic user, WidgetRef ref) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final profile = ref.watch(authStateProvider).profile;
    final coverAlignment = ref.watch(coverAlignmentProvider);
    final avatarAlignment = ref.watch(avatarAlignmentProvider);

    return Stack(
      children: [
        // 1. Dynamic Animated Ambient Background
        if (profile?.backgroundUrl != null)
          AnimatedAmbientBackground(
            imageUrl: profile!.backgroundUrl!,
            height: 800,
          ),

        // 2. Scrolling Content
        CustomScrollView(
          slivers: [
            // Edge-to-Edge Cover Photo & Avatar
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260, // 200 for cover + 60 for avatar overlap
                child: Stack(
                  children: [
                    // Sharp Edge-to-Edge Cover Photo
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 200,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (profile?.backgroundUrl != null)
                            FirebaseCachedNetworkImage(
                              imageUrl: profile!.backgroundUrl!,
                              fit: BoxFit.cover,
                              alignment: coverAlignment,
                              placeholder: (_, __) => _buildGradientCover(user),
                              errorWidget: (_, __, ___) => _buildGradientCover(user),
                            )
                          else
                            _buildGradientCover(user),
                          if (profile?.backgroundUrl != null)
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _openRepositionSheet(context, ref, isAvatar: false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.open_with, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text('Reposition', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Action Buttons in Safe Area
                    Positioned(
                      top: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton.filledTonal(
                                icon: const Icon(Icons.edit),
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileView())),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.settings),
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsView())),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Avatar perfectly overlapping the bottom edge
                    Positioned(
                      top: 155,
                      left: 16,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: scaffoldColor, width: 4),
                            ),
                            child: ClipOval(
                              child: SizedBox(
                                width: 90,
                                height: 90,
                                child: _buildAvatarImage(profile, user, avatarAlignment),
                              ),
                            ),
                          ),
                          if ((profile?.photoUrl ?? user?.photoURL) != null)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: () => _openRepositionSheet(context, ref, isAvatar: true),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Icon(Icons.open_with, size: 13, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Action buttons to the right of avatar
                    Positioned(
                      top: 210, // Just below the cover photo
                      right: 16,
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NetworkGraphView())),
                            icon: const Icon(Icons.hub),
                            tooltip: 'Network Graph',
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContentStatusView())),
                            icon: const Icon(Icons.gavel),
                            tooltip: 'Content Status / Appeals',
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: () {},
                            icon: const Icon(Icons.share),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Profile Info Below
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Profile Info
                    Text(
                      profile?.displayName ?? user?.displayName ?? 'SafeChat User',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('@${profile?.username ?? user?.displayName?.toLowerCase().replaceAll(' ', '') ?? 'user'}'),
                    const SizedBox(height: 16),
                    Text(profile?.bio?.isNotEmpty == true ? profile!.bio! : 'Creating a safer social space 🛡️\n#flutter #dev'),
                    const SizedBox(height: 24),
                    // Stats Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Consumer(
                        builder: (context, ref, _) {
                          final uid = user?.uid ?? '';
                          final followersAsync = ref.watch(followersCountProvider(uid));
                          final followingAsync = ref.watch(followingCountProvider(uid));
                          final friendsAsync = ref.watch(friendsProvider(uid));
                          
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatColumn(
                                label: 'Followers', 
                                count: followersAsync.value?.toString() ?? '-',
                              ),
                              _StatColumn(
                                label: 'Following', 
                                count: followingAsync.value?.toString() ?? '-',
                              ),
                              _StatColumn(
                                label: 'Friends', 
                                count: friendsAsync.value?.length.toString() ?? '-',
                              ),
                            ],
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            _buildGrid(ref, user?.uid ?? ''),
          ],
        ),
      ],
    );
  }

  Widget _buildCenteredMinimalist(BuildContext context, dynamic user, WidgetRef ref) {
    final profile = ref.watch(authStateProvider).profile;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(user?.displayName ?? 'Profile'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileView())),
            ),
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
                  profile?.displayName ?? user?.displayName ?? 'SafeChat User',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(profile?.bio?.isNotEmpty == true ? profile!.bio! : 'Creating a safer social space 🛡️\n#flutter #dev', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Consumer(
                  builder: (context, ref, _) {
                    final uid = user?.uid ?? '';
                    final followersAsync = ref.watch(followersCountProvider(uid));
                    final followingAsync = ref.watch(followingCountProvider(uid));
                    final friendsAsync = ref.watch(friendsProvider(uid));
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatColumn(
                          label: 'Followers', 
                          count: followersAsync.value?.toString() ?? '-',
                        ),
                        const SizedBox(width: 32),
                        _StatColumn(
                          label: 'Following', 
                          count: followingAsync.value?.toString() ?? '-',
                        ),
                        const SizedBox(width: 32),
                        _StatColumn(
                          label: 'Friends', 
                          count: friendsAsync.value?.length.toString() ?? '-',
                        ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NetworkGraphView())),
                      icon: const Icon(Icons.hub),
                      tooltip: 'Network Graph',
                    ),
                    const SizedBox(width: 16),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContentStatusView())),
                      icon: const Icon(Icons.gavel),
                      tooltip: 'Content Status / Appeals',
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
        _buildGrid(ref, user?.uid ?? ''),
      ],
    );
  }

  Widget _buildGrid(WidgetRef ref, String uid) {
    final userPostsAsync = ref.watch(userPostsProvider(uid));
    
    return userPostsAsync.when(
      loading: () => const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))),
      error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
      data: (posts) {
        if (posts.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('No posts yet')),
            ),
          );
        }
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final post = posts[index];
            final thumb = post.displayUrls.isNotEmpty ? post.displayUrls.first : '';
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: thumb.isNotEmpty
                  ? FirebaseCachedNetworkImage(
                      imageUrl: thumb,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined)),
                    )
                  : const Center(child: Icon(Icons.article_outlined)),
            );
          }, childCount: posts.length),
        );
      },
    );
  }

  Widget _buildGradientCover(dynamic user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HSLColor.fromAHSL(1.0, ((user?.uid ?? 'a').hashCode % 360).toDouble(), 0.7, 0.6).toColor(),
            HSLColor.fromAHSL(1.0, (((user?.uid ?? 'a').hashCode >> 8) % 360).toDouble(), 0.7, 0.6).toColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildAvatarImage(dynamic profile, dynamic user, Alignment alignment) {
    final photoUrl = (profile?.photoUrl as String?) ?? (user?.photoURL as String?);
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return FirebaseCachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        alignment: alignment,
        placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (_, __, ___) => const Icon(Icons.person, size: 45),
      );
    }
    return const Icon(Icons.person, size: 45);
  }

  Future<void> _openRepositionSheet(
    BuildContext context,
    WidgetRef ref, {
    required bool isAvatar,
  }) async {
    final profile = ref.read(authStateProvider).profile;
    final user = ref.read(authStateProvider).user;
    final imageUrl = isAvatar
        ? ((profile?.photoUrl as String?) ?? (user?.photoURL as String?))
        : (profile?.backgroundUrl as String?);
    if (imageUrl == null || imageUrl.isEmpty) return;

    final currentAlignment = isAvatar
        ? ref.read(avatarAlignmentProvider)
        : ref.read(coverAlignmentProvider);

    if (!context.mounted) return;
    final result = await Navigator.of(context).push<Alignment>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _RepositionSheet(
          imageUrl: imageUrl,
          initialAlignment: currentAlignment,
          isCircular: isAvatar,
        ),
      ),
    );

    if (result != null) {
      if (isAvatar) {
        ref.read(avatarAlignmentProvider.notifier).set(result);
      } else {
        ref.read(coverAlignmentProvider.notifier).set(result);
      }
    }
  }
}

class _RepositionSheet extends StatefulWidget {
  final String imageUrl;
  final Alignment initialAlignment;
  final bool isCircular;

  const _RepositionSheet({
    required this.imageUrl,
    required this.initialAlignment,
    this.isCircular = false,
  });

  @override
  State<_RepositionSheet> createState() => _RepositionSheetState();
}

class _RepositionSheetState extends State<_RepositionSheet> {
  late Alignment _alignment;

  @override
  void initState() {
    super.initState();
    _alignment = widget.initialAlignment;
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      // Image follows finger: dragging right reveals left side → alignment.x decreases
      final sx = 2.0 / size.width;
      final sy = 2.0 / size.height;
      _alignment = Alignment(
        (_alignment.x - details.delta.dx * sx).clamp(-1.0, 1.0),
        (_alignment.y - details.delta.dy * sy).clamp(-1.0, 1.0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        leadingWidth: 80,
        title: const Text('Reposition', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _alignment),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => _onPanUpdate(d, size),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.cover,
              alignment: _alignment,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
              ),
            ),
            CustomPaint(
              painter: _ViewfinderPainter(isCircular: widget.isCircular),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Icon(Icons.open_with, color: Colors.white70, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    'Drag to reposition',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  final bool isCircular;

  const _ViewfinderPainter({required this.isCircular});

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (isCircular) {
      final diameter = size.width * 0.72;
      final center = Offset(size.width / 2, size.height / 2);
      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addOval(Rect.fromCenter(center: center, width: diameter, height: diameter))
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(path, overlay);
      canvas.drawCircle(center, diameter / 2, border);
    } else {
      const viewH = 200.0;
      final topH = (size.height - viewH) / 2;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, topH), overlay);
      canvas.drawRect(Rect.fromLTWH(0, topH + viewH, size.width, size.height - topH - viewH), overlay);
      canvas.drawRect(Rect.fromLTWH(0, topH, size.width, viewH), border);
    }
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter old) => old.isCircular != isCircular;
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
            'Post Image Layout',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Consumer(builder: (context, ref, _) {
            final postLayout = ref.watch(postImageLayoutProvider);
            return SegmentedButton<PostImageLayoutStyle>(
              segments: const [
                ButtonSegment(
                  value: PostImageLayoutStyle.edgeToEdge,
                  label: Text('Edge-to-Edge', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.fullscreen),
                ),
                ButtonSegment(
                  value: PostImageLayoutStyle.padded,
                  label: Text('Padded', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.padding),
                ),
              ],
              selected: {postLayout},
              onSelectionChanged: (Set<PostImageLayoutStyle> newSelection) {
                ref.read(postImageLayoutProvider.notifier).setStyle(newSelection.first);
              },
            );
          }),
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
          const Text(
            'Ambient Mode',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Consumer(builder: (context, ref, _) {
            final isAmbientEnabled = ref.watch(ambientModeProvider);
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dynamic Ambient Glow', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Creates a breathing light effect behind content', style: TextStyle(fontSize: 12, color: Colors.grey)),
              value: isAmbientEnabled,
              onChanged: (value) {
                ref.read(ambientModeProvider.notifier).toggleAmbientMode();
              },
            );
          }),
          const SizedBox(height: 12),
          Consumer(builder: (context, ref, _) {
            final physicsMode = ref.watch(ambientPhysicsProvider);
            return SegmentedButton<AmbientPhysicsMode>(
              segments: const [
                ButtonSegment(
                  value: AmbientPhysicsMode.pulse,
                  label: Text('Pulse', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.waves),
                ),
                ButtonSegment(
                  value: AmbientPhysicsMode.aurora,
                  label: Text('Aurora', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.blur_on),
                ),
                ButtonSegment(
                  value: AmbientPhysicsMode.wave,
                  label: Text('Wave', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.water),
                ),
              ],
              selected: {physicsMode},
              onSelectionChanged: (Set<AmbientPhysicsMode> newSelection) {
                ref.read(ambientPhysicsProvider.notifier).setMode(newSelection.first);
              },
            );
          }),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('Verify Phone Number'),
            subtitle: const Text('Link your phone number to secure your account'),
            onTap: () {
              // Note: Implementation for phone verification in settings.
              // We just show a snackbar for now to signify the entry point.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone Verification flow will open here. Please make sure Phone Auth is enabled in Firebase.')),
              );
            },
          ),
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
