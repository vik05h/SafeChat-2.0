// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SafetyStatsImpl _$$SafetyStatsImplFromJson(Map<String, dynamic> json) =>
    _$SafetyStatsImpl(
      safetyScore: (json['safety_score'] as num).toInt(),
      reputationScore: (json['reputation_score'] as num).toInt(),
      trustLevel: json['trust_level'] as String,
      reportsSubmitted: (json['reports_submitted'] as num?)?.toInt() ?? 0,
      reportsResolved: (json['reports_resolved'] as num?)?.toInt() ?? 0,
      warningsReceived: (json['warnings_received'] as num?)?.toInt() ?? 0,
      appealsWon: (json['appeals_won'] as num?)?.toInt() ?? 0,
      appealsLost: (json['appeals_lost'] as num?)?.toInt() ?? 0,
      safetyTrend: (json['safety_trend'] as List<dynamic>?)
              ?.map((e) => SafetyTrendPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SafetyStatsImplToJson(_$SafetyStatsImpl instance) =>
    <String, dynamic>{
      'safety_score': instance.safetyScore,
      'reputation_score': instance.reputationScore,
      'trust_level': instance.trustLevel,
      'reports_submitted': instance.reportsSubmitted,
      'reports_resolved': instance.reportsResolved,
      'warnings_received': instance.warningsReceived,
      'appeals_won': instance.appealsWon,
      'appeals_lost': instance.appealsLost,
      'safety_trend': instance.safetyTrend,
    };

_$SafetyTrendPointImpl _$$SafetyTrendPointImplFromJson(
        Map<String, dynamic> json) =>
    _$SafetyTrendPointImpl(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toInt(),
    );

Map<String, dynamic> _$$SafetyTrendPointImplToJson(
        _$SafetyTrendPointImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'score': instance.score,
    };
