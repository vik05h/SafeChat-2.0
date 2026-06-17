import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../shared/utils/markdown_extensions.dart';
import '../../../theme/theme_provider.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../data/feed_post_model.dart';
import 'feed_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Feed root
// ─────────────────────────────────────────────────────────────────────────────

class FeedView extends ConsumerWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedPostsProvider);
    final layoutMode = ref.watch(feedLayoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SafeChat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(feedPostsProvider),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return _EmptyFeed(onRetry: () => ref.invalidate(feedPostsProvider));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(feedPostsProvider.notifier).refresh(),
            child: layoutMode == FeedLayoutMode.grid
                ? _buildGridView(context, posts)
                : _buildCardView(context, posts),
          );
        },
      ),
    );
  }

  Widget _buildGridView(BuildContext context, List<FeedPost> posts) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _PostOpenContainer(
          post: post,
          child: _GridPostCard(post: post),
        );
      },
    );
  }

  Widget _buildCardView(BuildContext context, List<FeedPost> posts) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final post = posts[index];
        return _PostOpenContainer(
          post: post,
          child: _ListPostCard(post: post),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / Error states
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyFeed extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyFeed({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined,
              size: 64, color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('No posts yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Follow people or create your first post!',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Couldn\'t load feed',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Open container wrapper (shared hero + page transition)
// ─────────────────────────────────────────────────────────────────────────────

class _PostOpenContainer extends StatelessWidget {
  final FeedPost post;
  final Widget child;

  const _PostOpenContainer({required this.post, required this.child});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedBuilder: (context, action) => child,
      openBuilder: (context, action) => _PostDetailScreen(post: post),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid card
// ─────────────────────────────────────────────────────────────────────────────

class _GridPostCard extends StatelessWidget {
  final FeedPost post;
  const _GridPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final thumb = post.displayUrls.isNotEmpty ? post.displayUrls.first : null;
    final height = 150.0 + (post.id.hashCode.abs() % 4) * 50.0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (thumb != null)
            Container(
              height: height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(thumb),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: height,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.article_outlined, size: 40)),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.text,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: post.authorPhotoUrl.isNotEmpty ? CachedNetworkImageProvider(post.authorPhotoUrl) : null,
                    child: post.authorPhotoUrl.isEmpty ? const Icon(Icons.person, size: 14) : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post.authorDisplayName,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List card
// ─────────────────────────────────────────────────────────────────────────────

class _ListPostCard extends StatelessWidget {
  final FeedPost post;
  const _ListPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final thumb = post.displayUrls.isNotEmpty ? post.displayUrls.first : null;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.authorPhotoUrl.isNotEmpty ? CachedNetworkImageProvider(post.authorPhotoUrl) : null,
              child: post.authorPhotoUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            title: Text(
              post.authorDisplayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              post.createdAt != null
                  ? _timeAgo(post.createdAt!)
                  : 'Just now',
            ),
          ),
          if (thumb != null)
            SizedBox(
              height: 300,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: thumb,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, _, _) => Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MarkdownBody(
              data: post.text,
              extensionSet: md.ExtensionSet.gitHubFlavored,
              inlineSyntaxes: [HighlightSyntax()],
              builders: {'highlight': HighlightBuilder(context)},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${post.likeCount}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 16),
                  const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}', style: const TextStyle(color: Colors.grey)),
                ]),
                Row(children: [
                  FloatingActionButton.small(
                    heroTag: 'like_${post.id}',
                    onPressed: () {},
                    child: const Icon(Icons.favorite_border),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    heroTag: 'comment_${post.id}',
                    onPressed: () => showCommentsBottomSheet(context),
                    child: const Icon(Icons.chat_bubble_outline),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Post detail screen (full-screen with ambient + image carousel)
// ─────────────────────────────────────────────────────────────────────────────

class _PostDetailScreen extends ConsumerStatefulWidget {
  final FeedPost post;
  const _PostDetailScreen({required this.post});

  @override
  ConsumerState<_PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<_PostDetailScreen> {
  int _currentPage = 0;

  List<String> get _mediaUrls => widget.post.displayUrls.isNotEmpty
      ? widget.post.displayUrls
      : ['https://picsum.photos/seed/${widget.post.id}/300/400'];

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final layoutStyle = ref.watch(postImageLayoutProvider);
    final isEdgeToEdge = layoutStyle == PostImageLayoutStyle.edgeToEdge;

    return Scaffold(
      extendBodyBehindAppBar: isEdgeToEdge,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isEdgeToEdge ? Colors.white : Theme.of(context).iconTheme.color,
          shadows: isEdgeToEdge ? const [Shadow(color: Colors.black45, blurRadius: 10)] : null,
        ),
      ),
      body: Stack(
        children: [
          // Dynamic ambient background synced to current page image.
          AnimatedAmbientBackground(
            key: ValueKey(_mediaUrls[_currentPage]),
            imageUrl: _mediaUrls[_currentPage],
            height: 800,
          ),

          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image carousel
                SizedBox(
                  height: 400,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: PageView.builder(
                          itemCount: _mediaUrls.length,
                          onPageChanged: (i) => setState(() => _currentPage = i),
                          itemBuilder: (context, i) => CachedNetworkImage(
                            imageUrl: _mediaUrls[i],
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                          ),
                        ),
                      ),
                      // Dot indicators.
                      if (_mediaUrls.length > 1)
                        Positioned(
                          bottom: 16, left: 0, right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_mediaUrls.length, (i) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == i ? 12 : 8,
                                height: _currentPage == i ? 12 : 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == i
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black45, blurRadius: 4)
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // User Info Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: widget.post.authorPhotoUrl.isNotEmpty ? CachedNetworkImageProvider(widget.post.authorPhotoUrl) : null,
                        child: widget.post.authorPhotoUrl.isEmpty ? const Icon(Icons.person, size: 28) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.authorDisplayName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '@${widget.post.authorUsername}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () {},
                        child: const Text('Follow'),
                      ),
                    ],
                  ),
                ),

                // Post Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.createdAt != null
                            ? _timeAgo(widget.post.createdAt!)
                            : 'Just now',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 24), // Pushes content downward
                      MarkdownBody(
                        data: widget.post.text,
                        extensionSet: md.ExtensionSet.gitHubFlavored,
                        inlineSyntaxes: [HighlightSyntax()],
                        builders: {'highlight': HighlightBuilder(context)},
                        styleSheet: MarkdownStyleSheet(
                          p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                          h1: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          h2: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          h3: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAction(Icons.favorite_border, 'Like', () {}),
                          _buildAction(
                            Icons.chat_bubble_outline,
                            'Comment',
                            () => showCommentsBottomSheet(context),
                          ),
                          _buildAction(Icons.share_outlined, 'Share', () {}),
                        ],
                      ),
                      const SizedBox(height: 48),
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

  Widget _buildAction(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        IconButton.filledTonal(onPressed: onTap, icon: Icon(icon), iconSize: 28),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Comments bottom sheet (reusable)
// ─────────────────────────────────────────────────────────────────────────────

void showCommentsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: 15,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=${index + 10}'),
                    ),
                    title: Text('Commenter $index',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle:
                        Text('This is an awesome comment $index! Looks so good!'),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite_border, size: 16),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24)),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send,
                            color: Theme.of(context).colorScheme.primary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
