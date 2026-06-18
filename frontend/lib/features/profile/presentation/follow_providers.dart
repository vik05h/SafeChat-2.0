import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/follow_repository.dart';

final followersCountProvider = StreamProvider.family<int, String>((ref, uid) {
  final repo = ref.watch(followRepositoryProvider);
  return repo.getFollowersCount(uid);
});

final followingCountProvider = StreamProvider.family<int, String>((ref, uid) {
  final repo = ref.watch(followRepositoryProvider);
  return repo.getFollowingCount(uid);
});

final friendsProvider = StreamProvider.family<List<String>, String>((ref, uid) {
  final repo = ref.watch(followRepositoryProvider);
  return repo.getFriends(uid);
});

final isFollowingProvider = StreamProvider.family<bool, String>((ref, uid) {
  final repo = ref.watch(followRepositoryProvider);
  return repo.isFollowing(uid);
});
