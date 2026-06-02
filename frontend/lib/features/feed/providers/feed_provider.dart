import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../../shared/models/post.dart';
import '../services/feed_service.dart';

final feedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<Post>>>((ref) {
  final feedService = ref.watch(feedServiceProvider);
  return FeedNotifier(feedService)..loadInitialFeed();
});

class FeedNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final FeedService _feedService;
  String? _nextCursor;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  FeedNotifier(this._feedService) : super(const AsyncValue.loading());

  Future<void> loadInitialFeed() async {
    state = const AsyncValue.loading();
    try {
      final posts = await _feedService.getFeed();
      // Simple pagination simulation, ideally we get nextCursor from API meta
      if (posts.isNotEmpty) {
        _nextCursor = posts.last.createdAt.toIso8601String();
      }
      state = AsyncValue.data(posts);
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Failed to load initial feed');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    
    final currentPosts = state.value ?? [];
    _isLoadingMore = true;
    
    try {
      final newPosts = await _feedService.getFeed(cursor: _nextCursor);
      if (newPosts.isEmpty) {
        _hasMore = false;
      } else {
        _nextCursor = newPosts.last.createdAt.toIso8601String();
        state = AsyncValue.data([...currentPosts, ...newPosts]);
      }
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Failed to load more posts for feed');
      state = AsyncValue.error(e, st).copyWithPrevious(state);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> toggleLike(String postId) async {
    final currentPosts = state.value;
    if (currentPosts == null) return;

    final postIndex = currentPosts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = currentPosts[postIndex];
    final isLiked = post.isLiked;

    // Optimistic update
    final updatedPost = post.copyWith(
      isLiked: !isLiked,
      likeCount: isLiked ? post.likeCount - 1 : post.likeCount + 1,
    );
    
    final newPosts = List<Post>.from(currentPosts);
    newPosts[postIndex] = updatedPost;
    state = AsyncValue.data(newPosts);

    // Network request
    try {
      if (isLiked) {
        await _feedService.unlikePost(postId);
      } else {
        await _feedService.likePost(postId);
      }
    } catch (e) {
      // Revert on failure
      final revertedPosts = List<Post>.from(currentPosts);
      revertedPosts[postIndex] = post;
      state = AsyncValue.data(revertedPosts);
    }
  }
}
