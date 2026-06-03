// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      participantNames:
          Map<String, String>.from(json['participant_names'] as Map),
      participantAvatars:
          Map<String, String>.from(json['participant_avatars'] as Map),
      lastMessage: json['last_message'] as String,
      lastMessageTime: DateTime.parse(json['last_message_time'] as String),
      unreadCounts: Map<String, int>.from(json['unread_counts'] as Map),
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'participants': instance.participants,
      'participant_names': instance.participantNames,
      'participant_avatars': instance.participantAvatars,
      'last_message': instance.lastMessage,
      'last_message_time': instance.lastMessageTime.toIso8601String(),
      'unread_counts': instance.unreadCounts,
    };
