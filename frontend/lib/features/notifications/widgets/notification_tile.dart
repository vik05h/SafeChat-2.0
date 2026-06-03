import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../../../app/theme/app_colors.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(notification.type);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? Colors.transparent : AppColors.primaryOrange.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconData.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData.icon, color: iconData.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  _NotificationIconData _getIconData(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return _NotificationIconData(Icons.favorite, AppColors.error);
      case NotificationType.comment:
        return _NotificationIconData(Icons.chat_bubble, Colors.blue);
      case NotificationType.follow:
        return _NotificationIconData(Icons.person_add, AppColors.success);
      case NotificationType.mention:
        return _NotificationIconData(Icons.alternate_email, AppColors.primaryOrange);
      case NotificationType.message:
        return _NotificationIconData(Icons.mail, Colors.indigo);
      case NotificationType.moderationAlert:
        return _NotificationIconData(Icons.gpp_bad_rounded, AppColors.error);
      case NotificationType.reportUpdate:
      case NotificationType.appealUpdate:
        return _NotificationIconData(Icons.gavel_rounded, AppColors.warning);
      case NotificationType.safetyScoreUpdate:
      case NotificationType.trustLevelUpdate:
        return _NotificationIconData(Icons.shield_rounded, AppColors.success);
      case NotificationType.unknown:
        return _NotificationIconData(Icons.notifications, AppColors.textSecondary);
    }
  }
}

class _NotificationIconData {
  final IconData icon;
  final Color color;
  _NotificationIconData(this.icon, this.color);
}
