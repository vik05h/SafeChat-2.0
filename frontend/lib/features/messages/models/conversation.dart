import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required List<String> participants,
    @JsonKey(name: 'participant_names') required Map<String, String> participantNames,
    @JsonKey(name: 'participant_avatars') required Map<String, String> participantAvatars,
    @JsonKey(name: 'last_message') required String lastMessage,
    @JsonKey(name: 'last_message_time') required DateTime lastMessageTime,
    @JsonKey(name: 'unread_counts') required Map<String, int> unreadCounts,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
}
