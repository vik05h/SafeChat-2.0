import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../shared/widgets/post_card.dart';

class ProfileScreen extends ConsumerWidget {
  final String userId; // 'me' for current user

  const ProfileScreen({super.key, this.userId = 'me'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (userId == 'me')
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.pushNamed('settings');
              },
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeader(context, profile, ref),
                      const SizedBox(height: 24),
                      _buildTrustMetrics(context, profile),
                      const SizedBox(height: 24),
                      _buildStandingSummary(context, profile),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Divider(),
              ),
              ref.watch(profilePostsProvider(userId)).when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('No posts yet', style: TextStyle(color: AppColors.textSecondary))),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => PostCard(post: posts[index]),
                      childCount: posts.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error loading posts: $err')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading profile: $err')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile profile, WidgetRef ref) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: profile.photoUrl.isNotEmpty
                  ? CachedNetworkImageProvider(profile.photoUrl)
                  : null,
              backgroundColor: AppColors.border,
              child: profile.photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 40, color: AppColors.textSecondary)
                  : null,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('Posts', '0'), // To be implemented later
                  InkWell(
                    onTap: () {
                      context.pushNamed('follow_list', extra: {'userId': userId, 'type': 'followers'});
                    },
                    child: _buildStatColumn('Followers', profile.followerCount.toString()),
                  ),
                  InkWell(
                    onTap: () {
                      context.pushNamed('follow_list', extra: {'userId': userId, 'type': 'following'});
                    },
                    child: _buildStatColumn('Following', profile.followingCount.toString()),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '@${profile.username}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (profile.bio.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  profile.bio,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: userId == 'me'
              ? OutlinedButton(
                  onPressed: () {
                    // Navigate to Edit Profile
                  },
                  child: const Text('Edit Profile'),
                )
              : ElevatedButton(
                  onPressed: () => ref.read(profileProvider(userId).notifier).toggleFollow(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: profile.isFollowing ? AppColors.surface : AppColors.primaryOrange,
                    foregroundColor: profile.isFollowing ? AppColors.textPrimary : Colors.white,
                  ),
                  child: Text(profile.isFollowing ? 'Following' : 'Follow'),
                ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildTrustMetrics(BuildContext context, UserProfile profile) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Reputation',
            profile.reputationScore.toString(),
            Icons.star_rounded,
            _getTrustColor(profile.trustLevel),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Safety Score',
            '${profile.safetyScore}%',
            Icons.shield_rounded,
            profile.safetyScore >= 80 ? AppColors.success : (profile.safetyScore >= 50 ? AppColors.warning : AppColors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Color _getTrustColor(TrustLevel level) {
    switch (level) {
      case TrustLevel.trusted:
        return const Color(0xFF00E5FF); // Cyan
      case TrustLevel.gold:
        return const Color(0xFFFFD700); // Gold
      case TrustLevel.silver:
        return const Color(0xFFC0C0C0); // Silver
      case TrustLevel.bronze:
      default:
        return const Color(0xFFCD7F32); // Bronze
    }
  }

  Widget _buildStandingSummary(BuildContext context, UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Community Standing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                profile.safetyScore >= 80 ? Icons.check_circle : Icons.warning_amber_rounded,
                color: profile.safetyScore >= 80 ? AppColors.success : AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  profile.standingSummary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
