import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:animations/animations.dart';
import '../../../theme/theme_provider.dart';
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
            child: Text(
              'Grid Post Title $index',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: Center(
        child: Text('Full content for post $index'),
      ),
    );
  }
}
