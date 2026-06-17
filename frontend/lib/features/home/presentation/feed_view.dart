// removed dart:ui
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:animations/animations.dart';
import '../../../theme/theme_provider.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import 'create_post_view.dart';

class FeedView extends ConsumerWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutMode = ref.watch(feedLayoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SafeChat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: layoutMode == FeedLayoutMode.grid
          ? _buildGridView(context)
          : _buildCardView(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreatePostView()),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: 20,
      itemBuilder: (context, index) {
        return _PostOpenContainer(
          index: index,
          child: _GridPostCard(index: index),
        );
      },
    );
  }

  Widget _buildCardView(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        return _PostOpenContainer(
          index: index,
          child: _ListPostCard(index: index),
        );
      },
    );
  }
}

class _PostOpenContainer extends StatelessWidget {
  final int index;
  final Widget child;

  const _PostOpenContainer({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedBuilder: (context, action) => child,
      openBuilder: (context, action) => _PostDetailScreen(index: index),
    );
  }
}

class _GridPostCard extends StatelessWidget {
  final int index;

  const _GridPostCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final height = 150.0 + (index % 4) * 50.0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/$index/300/400'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Epic shot $index 📸',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=$index'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'User $index',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListPostCard extends StatelessWidget {
  final int index;

  const _ListPostCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=$index'),
            ),
            title: Text('User $index', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('2 hours ago'),
          ),
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/${index + 100}/600/400'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('This is the caption for the card feed post $index. Exploring the new Material 3 layout!'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'like_$index',
                  onPressed: () {},
                  child: const Icon(Icons.favorite_border),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  heroTag: 'comment_$index',
                  onPressed: () {},
                  child: const Icon(Icons.chat_bubble_outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostDetailScreen extends StatelessWidget {
  final int index;

  const _PostDetailScreen({required this.index});

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 10)]),
      ),
      body: Stack(
        children: [
          // Dynamic Animated Ambient Background
          AnimatedAmbientBackground(
            imageUrl: 'https://picsum.photos/seed/$index/300/400',
            height: 800, // Covers most of the screen
          ),
          
          // Scrolling Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image + Avatar Stack
                SizedBox(
                  height: 440, // 400 for image + 40 for avatar overlap
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 400,
                        child: Hero(
                          tag: 'post_image_$index',
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
                              ],
                              image: DecorationImage(
                                image: NetworkImage('https://picsum.photos/seed/$index/300/400'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Avatar overlapping bottom left
                      Positioned(
                        bottom: 0,
                        left: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: scaffoldColor, width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=$index'),
                          ),
                        ),
                      ),
                      // Follow Button overlapping bottom right
                      Positioned(
                        bottom: 12,
                        right: 24,
                        child: FilledButton.tonal(
                          onPressed: () {},
                          child: const Text('Follow'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User $index', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text('2 hours ago', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 24),
                      Text(
                        'Epic shot $index 📸',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This is the full detail view for post $index. It looks absolutely stunning in the new Material 3 design system. We can add comments, like buttons, and more rich content here!',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAction(Icons.favorite_border, 'Like'),
                          _buildAction(Icons.chat_bubble_outline, 'Comment'),
                          _buildAction(Icons.share_outlined, 'Share'),
                        ],
                      ),
                      const SizedBox(height: 48), // Bottom padding
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return Column(
      children: [
        IconButton.filledTonal(onPressed: () {}, icon: Icon(icon), iconSize: 28),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
