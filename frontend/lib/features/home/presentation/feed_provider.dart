// frontend/lib/features/home/presentation/feed_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/feed_post_model.dart';
import '../data/post_repository.dart';

/// Fetches the public feed from the backend.
///
/// Call `ref.invalidate(feedPostsProvider)` to trigger a refresh (e.g. after
/// creating a new post).
final feedPostsProvider = AsyncNotifierProvider<FeedPostsNotifier, List<FeedPost>>(
  FeedPostsNotifier.new,
);

class FeedPostsNotifier extends AsyncNotifier<List<FeedPost>> {
  @override
  Future<List<FeedPost>> build() => _fetch();

  Future<List<FeedPost>> _fetch() {
    final repo = ref.read(postRepositoryProvider);
    return repo.getFeed();
  }

  /// Pull-to-refresh: reload the feed from scratch.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Prepend a locally-constructed optimistic post so the author sees their
  /// content immediately while the feed is being refreshed in the background.
  void prependOptimistic(FeedPost post) {
    final current = state.asData?.value ?? [];
    state = AsyncData([post, ...current]);
  }
}
