import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../../../../app/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

final followListProvider = FutureProvider.family<List<UserProfile>, Map<String, String>>((ref, params) async {
  final service = ref.read(profileServiceProvider);
  final userId = params['userId']!;
  if (params['type'] == 'followers') {
    return service.getFollowers(userId);
  } else {
    return service.getFollowing(userId);
  }
});

class FollowListScreen extends ConsumerWidget {
  final String userId;
  final String type; // 'followers' or 'following'

  const FollowListScreen({super.key, required this.userId, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = type == 'followers' ? 'Followers' : 'Following';
    final asyncData = ref.watch(followListProvider({'userId': userId, 'type': type}));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: asyncData.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(child: Text('No $title yet.', style: const TextStyle(color: AppColors.textSecondary)));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoUrl.isNotEmpty ? CachedNetworkImageProvider(user.photoUrl) : null,
                  backgroundColor: AppColors.border,
                  child: user.photoUrl.isEmpty ? const Icon(Icons.person, color: AppColors.textSecondary) : null,
                ),
                title: Text(user.displayName),
                subtitle: Text('@${user.username}'),
                onTap: () {
                  // Navigate to user profile
                  context.pushNamed('profile', pathParameters: {'id': user.uid});
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }
}
