import 'package:freezed_annotation/freezed_annotation.dart';
import '../../moderation/models/moderation_result.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'sender_id') required String senderId,
    required String text,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'moderation_status') @Default('SAFE') String moderationStatusStr,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}

// Extension to easily get the ModerationStatus enum
extension MessageModeration on Message {
  ModerationStatus get moderationStatus {
    final status = moderationStatusStr.toUpperCase();
    if (status == 'BLOCKED') return ModerationStatus.blocked;
    if (status == 'WARNING') return ModerationStatus.warning;
    return ModerationStatus.safe;
  }
}
