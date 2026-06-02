import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../../posts/services/post_service.dart';
import '../../../shared/models/post.dart';

// Family provider to manage individual user profiles by ID
final profileProvider = StateNotifierProvider.family<ProfileNotifier, AsyncValue<UserProfile>, String>((ref, userId) {
  return ProfileNotifier(ref.watch(profileServiceProvider), userId)..loadProfile();
});

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileService _profileService;
  final String _userId;

  ProfileNotifier(this._profileService, this._userId) : super(const AsyncValue.loading());

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = _userId == 'me' 
          ? await _profileService.getCurrentUserProfile()
          : await _profileService.getProfile(_userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFollow() async {
    final user = state.value;
    if (user == null || _userId == 'me') return;

    final isFollowing = user.isFollowing;

    // Optimistic Update
    state = AsyncValue.data(user.copyWith(
      isFollowing: !isFollowing,
      followerCount: isFollowing ? user.followerCount - 1 : user.followerCount + 1,
    ));

    // Network Request
    try {
      if (isFollowing) {
        await _profileService.unfollowUser(_userId);
      } else {
        await _profileService.followUser(_userId);
      }
    } catch (e) {
      // Revert optimistic update on error
      state = AsyncValue.data(user.copyWith(isFollowing: user.isFollowing));
    }
  }
}

final profilePostsProvider = FutureProvider.family<List<Post>, String>((ref, userId) async {
  return ref.read(postServiceProvider).getPostsByUserId(userId);
});
