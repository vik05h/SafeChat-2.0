// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportImpl _$$ReportImplFromJson(Map<String, dynamic> json) => _$ReportImpl(
      id: json['id'] as String,
      targetId: json['target_id'] as String,
      targetType: json['target_type'] as String,
      reason: json['reason'] as String,
      additionalInfo: json['additional_info'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ReportImplToJson(_$ReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'target_id': instance.targetId,
      'target_type': instance.targetType,
      'reason': instance.reason,
      'additional_info': instance.additionalInfo,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };
