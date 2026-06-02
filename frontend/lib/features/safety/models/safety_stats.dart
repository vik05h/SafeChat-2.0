import 'package:freezed_annotation/freezed_annotation.dart';

part 'safety_stats.freezed.dart';
part 'safety_stats.g.dart';

@freezed
class SafetyStats with _$SafetyStats {
  const factory SafetyStats({
    @JsonKey(name: 'safety_score') required int safetyScore,
    @JsonKey(name: 'reputation_score') required int reputationScore,
    @JsonKey(name: 'trust_level') required String trustLevel,
    @JsonKey(name: 'reports_submitted') @Default(0) int reportsSubmitted,
    @JsonKey(name: 'reports_resolved') @Default(0) int reportsResolved,
    @JsonKey(name: 'warnings_received') @Default(0) int warningsReceived,
    @JsonKey(name: 'appeals_won') @Default(0) int appealsWon,
    @JsonKey(name: 'appeals_lost') @Default(0) int appealsLost,
    @JsonKey(name: 'safety_trend') @Default([]) List<SafetyTrendPoint> safetyTrend,
  }) = _SafetyStats;

  factory SafetyStats.fromJson(Map<String, dynamic> json) => _$SafetyStatsFromJson(json);
}

@freezed
class SafetyTrendPoint with _$SafetyTrendPoint {
  const factory SafetyTrendPoint({
    required DateTime date,
    required int score,
  }) = _SafetyTrendPoint;

  factory SafetyTrendPoint.fromJson(Map<String, dynamic> json) => _$SafetyTrendPointFromJson(json);
}
