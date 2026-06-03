// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'safety_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SafetyStats _$SafetyStatsFromJson(Map<String, dynamic> json) {
  return _SafetyStats.fromJson(json);
}

/// @nodoc
mixin _$SafetyStats {
  @JsonKey(name: 'safety_score')
  int get safetyScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'reputation_score')
  int get reputationScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'trust_level')
  String get trustLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'reports_submitted')
  int get reportsSubmitted => throw _privateConstructorUsedError;
  @JsonKey(name: 'reports_resolved')
  int get reportsResolved => throw _privateConstructorUsedError;
  @JsonKey(name: 'warnings_received')
  int get warningsReceived => throw _privateConstructorUsedError;
  @JsonKey(name: 'appeals_won')
  int get appealsWon => throw _privateConstructorUsedError;
  @JsonKey(name: 'appeals_lost')
  int get appealsLost => throw _privateConstructorUsedError;
  @JsonKey(name: 'safety_trend')
  List<SafetyTrendPoint> get safetyTrend => throw _privateConstructorUsedError;

  /// Serializes this SafetyStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SafetyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SafetyStatsCopyWith<SafetyStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafetyStatsCopyWith<$Res> {
  factory $SafetyStatsCopyWith(
          SafetyStats value, $Res Function(SafetyStats) then) =
      _$SafetyStatsCopyWithImpl<$Res, SafetyStats>;
  @useResult
  $Res call(
      {@JsonKey(name: 'safety_score') int safetyScore,
      @JsonKey(name: 'reputation_score') int reputationScore,
      @JsonKey(name: 'trust_level') String trustLevel,
      @JsonKey(name: 'reports_submitted') int reportsSubmitted,
      @JsonKey(name: 'reports_resolved') int reportsResolved,
      @JsonKey(name: 'warnings_received') int warningsReceived,
      @JsonKey(name: 'appeals_won') int appealsWon,
      @JsonKey(name: 'appeals_lost') int appealsLost,
      @JsonKey(name: 'safety_trend') List<SafetyTrendPoint> safetyTrend});
}

/// @nodoc
class _$SafetyStatsCopyWithImpl<$Res, $Val extends SafetyStats>
    implements $SafetyStatsCopyWith<$Res> {
  _$SafetyStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SafetyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? safetyScore = null,
    Object? reputationScore = null,
    Object? trustLevel = null,
    Object? reportsSubmitted = null,
    Object? reportsResolved = null,
    Object? warningsReceived = null,
    Object? appealsWon = null,
    Object? appealsLost = null,
    Object? safetyTrend = null,
  }) {
    return _then(_value.copyWith(
      safetyScore: null == safetyScore
          ? _value.safetyScore
          : safetyScore // ignore: cast_nullable_to_non_nullable
              as int,
      reputationScore: null == reputationScore
          ? _value.reputationScore
          : reputationScore // ignore: cast_nullable_to_non_nullable
              as int,
      trustLevel: null == trustLevel
          ? _value.trustLevel
          : trustLevel // ignore: cast_nullable_to_non_nullable
              as String,
      reportsSubmitted: null == reportsSubmitted
          ? _value.reportsSubmitted
          : reportsSubmitted // ignore: cast_nullable_to_non_nullable
              as int,
      reportsResolved: null == reportsResolved
          ? _value.reportsResolved
          : reportsResolved // ignore: cast_nullable_to_non_nullable
              as int,
      warningsReceived: null == warningsReceived
          ? _value.warningsReceived
          : warningsReceived // ignore: cast_nullable_to_non_nullable
              as int,
      appealsWon: null == appealsWon
          ? _value.appealsWon
          : appealsWon // ignore: cast_nullable_to_non_nullable
              as int,
      appealsLost: null == appealsLost
          ? _value.appealsLost
          : appealsLost // ignore: cast_nullable_to_non_nullable
              as int,
      safetyTrend: null == safetyTrend
          ? _value.safetyTrend
          : safetyTrend // ignore: cast_nullable_to_non_nullable
              as List<SafetyTrendPoint>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SafetyStatsImplCopyWith<$Res>
    implements $SafetyStatsCopyWith<$Res> {
  factory _$$SafetyStatsImplCopyWith(
          _$SafetyStatsImpl value, $Res Function(_$SafetyStatsImpl) then) =
      __$$SafetyStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'safety_score') int safetyScore,
      @JsonKey(name: 'reputation_score') int reputationScore,
      @JsonKey(name: 'trust_level') String trustLevel,
      @JsonKey(name: 'reports_submitted') int reportsSubmitted,
      @JsonKey(name: 'reports_resolved') int reportsResolved,
      @JsonKey(name: 'warnings_received') int warningsReceived,
      @JsonKey(name: 'appeals_won') int appealsWon,
      @JsonKey(name: 'appeals_lost') int appealsLost,
      @JsonKey(name: 'safety_trend') List<SafetyTrendPoint> safetyTrend});
}

/// @nodoc
class __$$SafetyStatsImplCopyWithImpl<$Res>
    extends _$SafetyStatsCopyWithImpl<$Res, _$SafetyStatsImpl>
    implements _$$SafetyStatsImplCopyWith<$Res> {
  __$$SafetyStatsImplCopyWithImpl(
      _$SafetyStatsImpl _value, $Res Function(_$SafetyStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SafetyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? safetyScore = null,
    Object? reputationScore = null,
    Object? trustLevel = null,
    Object? reportsSubmitted = null,
    Object? reportsResolved = null,
    Object? warningsReceived = null,
    Object? appealsWon = null,
    Object? appealsLost = null,
    Object? safetyTrend = null,
  }) {
    return _then(_$SafetyStatsImpl(
      safetyScore: null == safetyScore
          ? _value.safetyScore
          : safetyScore // ignore: cast_nullable_to_non_nullable
              as int,
      reputationScore: null == reputationScore
          ? _value.reputationScore
          : reputationScore // ignore: cast_nullable_to_non_nullable
              as int,
      trustLevel: null == trustLevel
          ? _value.trustLevel
          : trustLevel // ignore: cast_nullable_to_non_nullable
              as String,
      reportsSubmitted: null == reportsSubmitted
          ? _value.reportsSubmitted
          : reportsSubmitted // ignore: cast_nullable_to_non_nullable
              as int,
      reportsResolved: null == reportsResolved
          ? _value.reportsResolved
          : reportsResolved // ignore: cast_nullable_to_non_nullable
              as int,
      warningsReceived: null == warningsReceived
          ? _value.warningsReceived
          : warningsReceived // ignore: cast_nullable_to_non_nullable
              as int,
      appealsWon: null == appealsWon
          ? _value.appealsWon
          : appealsWon // ignore: cast_nullable_to_non_nullable
              as int,
      appealsLost: null == appealsLost
          ? _value.appealsLost
          : appealsLost // ignore: cast_nullable_to_non_nullable
              as int,
      safetyTrend: null == safetyTrend
          ? _value._safetyTrend
          : safetyTrend // ignore: cast_nullable_to_non_nullable
              as List<SafetyTrendPoint>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SafetyStatsImpl implements _SafetyStats {
  const _$SafetyStatsImpl(
      {@JsonKey(name: 'safety_score') required this.safetyScore,
      @JsonKey(name: 'reputation_score') required this.reputationScore,
      @JsonKey(name: 'trust_level') required this.trustLevel,
      @JsonKey(name: 'reports_submitted') this.reportsSubmitted = 0,
      @JsonKey(name: 'reports_resolved') this.reportsResolved = 0,
      @JsonKey(name: 'warnings_received') this.warningsReceived = 0,
      @JsonKey(name: 'appeals_won') this.appealsWon = 0,
      @JsonKey(name: 'appeals_lost') this.appealsLost = 0,
      @JsonKey(name: 'safety_trend')
      final List<SafetyTrendPoint> safetyTrend = const []})
      : _safetyTrend = safetyTrend;

  factory _$SafetyStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafetyStatsImplFromJson(json);

  @override
  @JsonKey(name: 'safety_score')
  final int safetyScore;
  @override
  @JsonKey(name: 'reputation_score')
  final int reputationScore;
  @override
  @JsonKey(name: 'trust_level')
  final String trustLevel;
  @override
  @JsonKey(name: 'reports_submitted')
  final int reportsSubmitted;
  @override
  @JsonKey(name: 'reports_resolved')
  final int reportsResolved;
  @override
  @JsonKey(name: 'warnings_received')
  final int warningsReceived;
  @override
  @JsonKey(name: 'appeals_won')
  final int appealsWon;
  @override
  @JsonKey(name: 'appeals_lost')
  final int appealsLost;
  final List<SafetyTrendPoint> _safetyTrend;
  @override
  @JsonKey(name: 'safety_trend')
  List<SafetyTrendPoint> get safetyTrend {
    if (_safetyTrend is EqualUnmodifiableListView) return _safetyTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_safetyTrend);
  }

  @override
  String toString() {
    return 'SafetyStats(safetyScore: $safetyScore, reputationScore: $reputationScore, trustLevel: $trustLevel, reportsSubmitted: $reportsSubmitted, reportsResolved: $reportsResolved, warningsReceived: $warningsReceived, appealsWon: $appealsWon, appealsLost: $appealsLost, safetyTrend: $safetyTrend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafetyStatsImpl &&
            (identical(other.safetyScore, safetyScore) ||
                other.safetyScore == safetyScore) &&
            (identical(other.reputationScore, reputationScore) ||
                other.reputationScore == reputationScore) &&
            (identical(other.trustLevel, trustLevel) ||
                other.trustLevel == trustLevel) &&
            (identical(other.reportsSubmitted, reportsSubmitted) ||
                other.reportsSubmitted == reportsSubmitted) &&
            (identical(other.reportsResolved, reportsResolved) ||
                other.reportsResolved == reportsResolved) &&
            (identical(other.warningsReceived, warningsReceived) ||
                other.warningsReceived == warningsReceived) &&
            (identical(other.appealsWon, appealsWon) ||
                other.appealsWon == appealsWon) &&
            (identical(other.appealsLost, appealsLost) ||
                other.appealsLost == appealsLost) &&
            const DeepCollectionEquality()
                .equals(other._safetyTrend, _safetyTrend));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      safetyScore,
      reputationScore,
      trustLevel,
      reportsSubmitted,
      reportsResolved,
      warningsReceived,
      appealsWon,
      appealsLost,
      const DeepCollectionEquality().hash(_safetyTrend));

  /// Create a copy of SafetyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SafetyStatsImplCopyWith<_$SafetyStatsImpl> get copyWith =>
      __$$SafetyStatsImplCopyWithImpl<_$SafetyStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafetyStatsImplToJson(
      this,
    );
  }
}

abstract class _SafetyStats implements SafetyStats {
  const factory _SafetyStats(
      {@JsonKey(name: 'safety_score') required final int safetyScore,
      @JsonKey(name: 'reputation_score') required final int reputationScore,
      @JsonKey(name: 'trust_level') required final String trustLevel,
      @JsonKey(name: 'reports_submitted') final int reportsSubmitted,
      @JsonKey(name: 'reports_resolved') final int reportsResolved,
      @JsonKey(name: 'warnings_received') final int warningsReceived,
      @JsonKey(name: 'appeals_won') final int appealsWon,
      @JsonKey(name: 'appeals_lost') final int appealsLost,
      @JsonKey(name: 'safety_trend')
      final List<SafetyTrendPoint> safetyTrend}) = _$SafetyStatsImpl;

  factory _SafetyStats.fromJson(Map<String, dynamic> json) =
      _$SafetyStatsImpl.fromJson;

  @override
  @JsonKey(name: 'safety_score')
  int get safetyScore;
  @override
  @JsonKey(name: 'reputation_score')
  int get reputationScore;
  @override
  @JsonKey(name: 'trust_level')
  String get trustLevel;
  @override
  @JsonKey(name: 'reports_submitted')
  int get reportsSubmitted;
  @override
  @JsonKey(name: 'reports_resolved')
  int get reportsResolved;
  @override
  @JsonKey(name: 'warnings_received')
  int get warningsReceived;
  @override
  @JsonKey(name: 'appeals_won')
  int get appealsWon;
  @override
  @JsonKey(name: 'appeals_lost')
  int get appealsLost;
  @override
  @JsonKey(name: 'safety_trend')
  List<SafetyTrendPoint> get safetyTrend;

  /// Create a copy of SafetyStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SafetyStatsImplCopyWith<_$SafetyStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SafetyTrendPoint _$SafetyTrendPointFromJson(Map<String, dynamic> json) {
  return _SafetyTrendPoint.fromJson(json);
}

/// @nodoc
mixin _$SafetyTrendPoint {
  DateTime get date => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;

  /// Serializes this SafetyTrendPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SafetyTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SafetyTrendPointCopyWith<SafetyTrendPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafetyTrendPointCopyWith<$Res> {
  factory $SafetyTrendPointCopyWith(
          SafetyTrendPoint value, $Res Function(SafetyTrendPoint) then) =
      _$SafetyTrendPointCopyWithImpl<$Res, SafetyTrendPoint>;
  @useResult
  $Res call({DateTime date, int score});
}

/// @nodoc
class _$SafetyTrendPointCopyWithImpl<$Res, $Val extends SafetyTrendPoint>
    implements $SafetyTrendPointCopyWith<$Res> {
  _$SafetyTrendPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SafetyTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? score = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SafetyTrendPointImplCopyWith<$Res>
    implements $SafetyTrendPointCopyWith<$Res> {
  factory _$$SafetyTrendPointImplCopyWith(_$SafetyTrendPointImpl value,
          $Res Function(_$SafetyTrendPointImpl) then) =
      __$$SafetyTrendPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int score});
}

/// @nodoc
class __$$SafetyTrendPointImplCopyWithImpl<$Res>
    extends _$SafetyTrendPointCopyWithImpl<$Res, _$SafetyTrendPointImpl>
    implements _$$SafetyTrendPointImplCopyWith<$Res> {
  __$$SafetyTrendPointImplCopyWithImpl(_$SafetyTrendPointImpl _value,
      $Res Function(_$SafetyTrendPointImpl) _then)
      : super(_value, _then);

  /// Create a copy of SafetyTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? score = null,
  }) {
    return _then(_$SafetyTrendPointImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SafetyTrendPointImpl implements _SafetyTrendPoint {
  const _$SafetyTrendPointImpl({required this.date, required this.score});

  factory _$SafetyTrendPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafetyTrendPointImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int score;

  @override
  String toString() {
    return 'SafetyTrendPoint(date: $date, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafetyTrendPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, score);

  /// Create a copy of SafetyTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SafetyTrendPointImplCopyWith<_$SafetyTrendPointImpl> get copyWith =>
      __$$SafetyTrendPointImplCopyWithImpl<_$SafetyTrendPointImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafetyTrendPointImplToJson(
      this,
    );
  }
}

abstract class _SafetyTrendPoint implements SafetyTrendPoint {
  const factory _SafetyTrendPoint(
      {required final DateTime date,
      required final int score}) = _$SafetyTrendPointImpl;

  factory _SafetyTrendPoint.fromJson(Map<String, dynamic> json) =
      _$SafetyTrendPointImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get score;

  /// Create a copy of SafetyTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SafetyTrendPointImplCopyWith<_$SafetyTrendPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
