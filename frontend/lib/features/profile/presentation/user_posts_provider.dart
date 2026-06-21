import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/data/feed_post_model.dart';
import '../../home/data/post_repository.dart';

final userPostsProvider = FutureProvider.family<List<FeedPost>, String>((
  ref,
  uid,
) async {
  if (uid.isEmpty) return [];

  final repo = ref.watch(postRepositoryProvider);
  return await repo.getUserPosts(uid);
});
