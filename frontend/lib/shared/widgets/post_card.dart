import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post.dart';
import '../../features/moderation/widgets/safety_badge.dart';
import '../../features/moderation/models/moderation_result.dart';
import '../../features/reports/widgets/report_bottom_sheet.dart';
import '../../features/reports/models/report.dart';
import '../../features/settings/services/settings_service.dart';
import '../../core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onReport;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: post.authorPhotoUrl.isNotEmpty 
                      ? CachedNetworkImageProvider(post.authorPhotoUrl)
                      : null,
                  backgroundColor: AppColors.border,
                  child: post.authorPhotoUrl.isEmpty 
                      ? const Icon(Icons.person, color: AppColors.textSecondary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.authorDisplayName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          SafetyBadge(
                            status: post.status.toUpperCase() == 'WARNING' 
                                ? ModerationStatus.warning 
                                : post.status.toUpperCase() == 'BLOCKED'
                                    ? ModerationStatus.blocked
                                    : ModerationStatus.safe,
                          ),
                        ],
                      ),
                      Text(
                        '@${post.authorUsername} • ${timeago.format(post.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                  onSelected: (value) async {
                    if (value == 'report') {
                      ReportBottomSheet.show(
                        context,
                        targetType: ReportTargetType.post,
                        targetId: post.id,
                        contentPreview: post.caption,
                      );
                    } else if (value == 'report_user') {
                      ReportBottomSheet.show(
                        context,
                        targetType: ReportTargetType.user,
                        targetId: post.authorUid,
                        contentPreview: 'Profile of ${post.authorDisplayName}',
                      );
                    } else if (value == 'block_user') {
                      try {
                        await ref.read(settingsServiceProvider).blockUser(post.authorUid);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked.')));
                        }
                      } catch (e) {
                         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to block user: $e')));
                      }
                    } else if (value == 'mute_user') {
                      try {
                        await ref.read(settingsServiceProvider).muteUser(post.authorUid);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User muted.')));
                        }
                      } catch (e) {
                         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to mute user: $e')));
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Report Post'),
                    ),
                    const PopupMenuItem(
                      value: 'report_user',
                      child: Text('Report User'),
                    ),
                    const PopupMenuItem(
                      value: 'mute_user',
                      child: Text('Mute User'),
                    ),
                    const PopupMenuItem(
                      value: 'block_user',
                      child: Text('Block User', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Caption
            Text(
              post.caption,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            // Media
            if (post.mediaUrls.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: post.mediaUrls.first,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: AppColors.border,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    color: AppColors.border,
                    child: const Icon(Icons.error, color: AppColors.error),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? AppColors.primaryOrange : AppColors.textSecondary,
                  label: post.likeCount.toString(),
                  onTap: onLike,
                ),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: post.commentCount.toString(),
                  onTap: onComment,
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
