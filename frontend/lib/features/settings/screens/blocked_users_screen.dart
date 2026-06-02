import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';
import '../services/settings_service.dart';
import '../../profile/models/user_profile.dart';

final blockedUsersProvider = FutureProvider<List<UserProfile>>((ref) async {
  return ref.read(settingsServiceProvider).getBlockedUsers();
});

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(blockedUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Restricted & Blocked Users')),
      body: asyncData.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No blocked users.', style: TextStyle(color: AppColors.textSecondary)));
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
                trailing: TextButton(
                  onPressed: () async {
                    try {
                      await ref.read(settingsServiceProvider).unblockUser(user.uid);
                      ref.invalidate(blockedUsersProvider);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User unblocked')));
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: const Text('Unblock', style: TextStyle(color: AppColors.primaryOrange)),
                ),
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
