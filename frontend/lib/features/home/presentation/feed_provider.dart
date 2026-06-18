// frontend/lib/features/home/presentation/feed_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/feed_post_model.dart';

/// Fetches the public feed directly from Firestore.
final feedPostsProvider = AsyncNotifierProvider.family<FeedPostsNotifier, List<FeedPost>, String>(
  (arg) => FeedPostsNotifier(arg),
);

class FeedPostsNotifier extends AsyncNotifier<List<FeedPost>> {
  final String arg;
  
  FeedPostsNotifier(this.arg);

  @override
  Future<List<FeedPost>> build() => _fetch();

  Future<List<FeedPost>> _fetch() async {
    final query = FirebaseFirestore.instance
        .collection('posts')
        .where('status', isEqualTo: 'approved');

    if (arg == 'following') {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];
      
      // Get the users the current user is following
      final followingSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .where('follower_uid', isEqualTo: user.uid)
          .get();
          
      if (followingSnapshot.docs.isEmpty) return [];
      
      final followingUids = followingSnapshot.docs
          .map((doc) => doc.data()['followee_uid'] as String)
          .toList();
          
      // Firestore 'whereIn' limits to 10 elements.
      // If a user follows more than 10 people, this needs batching,
      // but for Phase 0 we limit it to the first 10 for simplicity.
      final limitedUids = followingUids.take(10).toList();
      
      final postsSnapshot = await query
          .where('author_uid', whereIn: limitedUids)
          .orderBy('created_at', descending: true)
          .limit(20)
          .get();
          
      return postsSnapshot.docs
          .map((doc) => FeedPost.fromFirestore(doc.data(), doc.id))
          .toList();
    }

    // Global feed
    final snapshot = await query
        .orderBy('created_at', descending: true)
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => FeedPost.fromFirestore(doc.data(), doc.id))
        .toList();
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
