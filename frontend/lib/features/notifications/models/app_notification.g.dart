// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$AppNotificationImpl(
      id: json['id'] as String,
      typeStr: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      referenceId: json['reference_id'] as String?,
      targetRoute: json['target_route'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$AppNotificationImplToJson(
        _$AppNotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.typeStr,
      'title': instance.title,
      'body': instance.body,
      'reference_id': instance.referenceId,
      'target_route': instance.targetRoute,
      'is_read': instance.isRead,
      'created_at': instance.createdAt.toIso8601String(),
    };
