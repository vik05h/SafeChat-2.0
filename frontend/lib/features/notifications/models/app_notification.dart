import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  message,
  moderationAlert,
  reportUpdate,
  appealUpdate,
  safetyScoreUpdate,
  trustLevelUpdate,
  unknown
}

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    @JsonKey(name: 'type') required String typeStr,
    required String title,
    required String body,
    @JsonKey(name: 'reference_id') String? referenceId,
    @JsonKey(name: 'target_route') String? targetRoute,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
}

extension AppNotificationHelper on AppNotification {
  NotificationType get type {
    return NotificationType.values.firstWhere(
      (e) => e.name.toLowerCase() == typeStr.toLowerCase(),
      orElse: () => NotificationType.unknown,
    );
  }
}
