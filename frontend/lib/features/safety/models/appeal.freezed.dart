// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appeal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Appeal _$AppealFromJson(Map<String, dynamic> json) {
  return _Appeal.fromJson(json);
}

/// @nodoc
mixin _$Appeal {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'moderation_log_id')
  String get moderationLogId => throw _privateConstructorUsedError;
  @JsonKey(name: 'content_preview')
  String get contentPreview => throw _privateConstructorUsedError;
  @JsonKey(name: 'reason_provided')
  String get reasonProvided => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'admin_notes')
  String? get adminNotes => throw _privateConstructorUsedError;

  /// Serializes this Appeal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Appeal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppealCopyWith<Appeal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppealCopyWith<$Res> {
  factory $AppealCopyWith(Appeal value, $Res Function(Appeal) then) =
      _$AppealCopyWithImpl<$Res, Appeal>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'moderation_log_id') String moderationLogId,
      @JsonKey(name: 'content_preview') String contentPreview,
      @JsonKey(name: 'reason_provided') String reasonProvided,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'admin_notes') String? adminNotes});
}

/// @nodoc
class _$AppealCopyWithImpl<$Res, $Val extends Appeal>
    implements $AppealCopyWith<$Res> {
  _$AppealCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Appeal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? moderationLogId = null,
    Object? contentPreview = null,
    Object? reasonProvided = null,
    Object? status = null,
    Object? createdAt = null,
    Object? resolvedAt = freezed,
    Object? adminNotes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      moderationLogId: null == moderationLogId
          ? _value.moderationLogId
          : moderationLogId // ignore: cast_nullable_to_non_nullable
              as String,
      contentPreview: null == contentPreview
          ? _value.contentPreview
          : contentPreview // ignore: cast_nullable_to_non_nullable
              as String,
      reasonProvided: null == reasonProvided
          ? _value.reasonProvided
          : reasonProvided // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppealImplCopyWith<$Res> implements $AppealCopyWith<$Res> {
  factory _$$AppealImplCopyWith(
          _$AppealImpl value, $Res Function(_$AppealImpl) then) =
      __$$AppealImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'moderation_log_id') String moderationLogId,
      @JsonKey(name: 'content_preview') String contentPreview,
      @JsonKey(name: 'reason_provided') String reasonProvided,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'admin_notes') String? adminNotes});
}

/// @nodoc
class __$$AppealImplCopyWithImpl<$Res>
    extends _$AppealCopyWithImpl<$Res, _$AppealImpl>
    implements _$$AppealImplCopyWith<$Res> {
  __$$AppealImplCopyWithImpl(
      _$AppealImpl _value, $Res Function(_$AppealImpl) _then)
      : super(_value, _then);

  /// Create a copy of Appeal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? moderationLogId = null,
    Object? contentPreview = null,
    Object? reasonProvided = null,
    Object? status = null,
    Object? createdAt = null,
    Object? resolvedAt = freezed,
    Object? adminNotes = freezed,
  }) {
    return _then(_$AppealImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      moderationLogId: null == moderationLogId
          ? _value.moderationLogId
          : moderationLogId // ignore: cast_nullable_to_non_nullable
              as String,
      contentPreview: null == contentPreview
          ? _value.contentPreview
          : contentPreview // ignore: cast_nullable_to_non_nullable
              as String,
      reasonProvided: null == reasonProvided
          ? _value.reasonProvided
          : reasonProvided // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppealImpl implements _Appeal {
  const _$AppealImpl(
      {required this.id,
      @JsonKey(name: 'moderation_log_id') required this.moderationLogId,
      @JsonKey(name: 'content_preview') required this.contentPreview,
      @JsonKey(name: 'reason_provided') required this.reasonProvided,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'resolved_at') this.resolvedAt,
      @JsonKey(name: 'admin_notes') this.adminNotes});

  factory _$AppealImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppealImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'moderation_log_id')
  final String moderationLogId;
  @override
  @JsonKey(name: 'content_preview')
  final String contentPreview;
  @override
  @JsonKey(name: 'reason_provided')
  final String reasonProvided;
  @override
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;
  @override
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;

  @override
  String toString() {
    return 'Appeal(id: $id, moderationLogId: $moderationLogId, contentPreview: $contentPreview, reasonProvided: $reasonProvided, status: $status, createdAt: $createdAt, resolvedAt: $resolvedAt, adminNotes: $adminNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppealImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.moderationLogId, moderationLogId) ||
                other.moderationLogId == moderationLogId) &&
            (identical(other.contentPreview, contentPreview) ||
                other.contentPreview == contentPreview) &&
            (identical(other.reasonProvided, reasonProvided) ||
                other.reasonProvided == reasonProvided) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      moderationLogId,
      contentPreview,
      reasonProvided,
      status,
      createdAt,
      resolvedAt,
      adminNotes);

  /// Create a copy of Appeal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppealImplCopyWith<_$AppealImpl> get copyWith =>
      __$$AppealImplCopyWithImpl<_$AppealImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppealImplToJson(
      this,
    );
  }
}

abstract class _Appeal implements Appeal {
  const factory _Appeal(
      {required final String id,
      @JsonKey(name: 'moderation_log_id') required final String moderationLogId,
      @JsonKey(name: 'content_preview') required final String contentPreview,
      @JsonKey(name: 'reason_provided') required final String reasonProvided,
      required final String status,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'resolved_at') final DateTime? resolvedAt,
      @JsonKey(name: 'admin_notes') final String? adminNotes}) = _$AppealImpl;

  factory _Appeal.fromJson(Map<String, dynamic> json) = _$AppealImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'moderation_log_id')
  String get moderationLogId;
  @override
  @JsonKey(name: 'content_preview')
  String get contentPreview;
  @override
  @JsonKey(name: 'reason_provided')
  String get reasonProvided;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;
  @override
  @JsonKey(name: 'admin_notes')
  String? get adminNotes;

  /// Create a copy of Appeal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppealImplCopyWith<_$AppealImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
