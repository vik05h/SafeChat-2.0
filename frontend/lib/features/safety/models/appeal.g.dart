// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appeal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppealImpl _$$AppealImplFromJson(Map<String, dynamic> json) => _$AppealImpl(
      id: json['id'] as String,
      moderationLogId: json['moderation_log_id'] as String,
      contentPreview: json['content_preview'] as String,
      reasonProvided: json['reason_provided'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      adminNotes: json['admin_notes'] as String?,
    );

Map<String, dynamic> _$$AppealImplToJson(_$AppealImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'moderation_log_id': instance.moderationLogId,
      'content_preview': instance.contentPreview,
      'reason_provided': instance.reasonProvided,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'admin_notes': instance.adminNotes,
    };
