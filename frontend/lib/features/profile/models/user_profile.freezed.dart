// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  String get photoUrl => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  @JsonKey(name: 'follower_count')
  int get followerCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'following_count')
  int get followingCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'reputation_score')
  int get reputationScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'safety_score')
  int get safetyScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_following')
  bool get isFollowing => throw _privateConstructorUsedError;
  @JsonKey(name: 'trust_level')
  String get trustLevelStr => throw _privateConstructorUsedError;
  @JsonKey(name: 'standing_summary')
  String get standingSummary => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String id,
      String username,
      @JsonKey(name: 'display_name') String displayName,
      @JsonKey(name: 'photo_url') String photoUrl,
      String bio,
      @JsonKey(name: 'follower_count') int followerCount,
      @JsonKey(name: 'following_count') int followingCount,
      @JsonKey(name: 'reputation_score') int reputationScore,
      @JsonKey(name: 'safety_score') int safetyScore,
      @JsonKey(name: 'is_following') bool isFollowing,
      @JsonKey(name: 'trust_level') String trustLevelStr,
      @JsonKey(name: 'standing_summary') String standingSummary});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = null,
    Object? photoUrl = null,
    Object? bio = null,
    Object? followerCount = null,
    Object? followingCount = null,
    Object? reputationScore = null,
    Object? safetyScore = null,
    Object? isFollowing = null,
    Object? trustLevelStr = null,
    Object? standingSummary = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: null == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      followerCount: null == followerCount
          ? _value.followerCount
          : followerCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      reputationScore: null == reputationScore
          ? _value.reputationScore
          : reputationScore // ignore: cast_nullable_to_non_nullable
              as int,
      safetyScore: null == safetyScore
          ? _value.safetyScore
          : safetyScore // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      trustLevelStr: null == trustLevelStr
          ? _value.trustLevelStr
          : trustLevelStr // ignore: cast_nullable_to_non_nullable
              as String,
      standingSummary: null == standingSummary
          ? _value.standingSummary
          : standingSummary // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String username,
      @JsonKey(name: 'display_name') String displayName,
      @JsonKey(name: 'photo_url') String photoUrl,
      String bio,
      @JsonKey(name: 'follower_count') int followerCount,
      @JsonKey(name: 'following_count') int followingCount,
      @JsonKey(name: 'reputation_score') int reputationScore,
      @JsonKey(name: 'safety_score') int safetyScore,
      @JsonKey(name: 'is_following') bool isFollowing,
      @JsonKey(name: 'trust_level') String trustLevelStr,
      @JsonKey(name: 'standing_summary') String standingSummary});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = null,
    Object? photoUrl = null,
    Object? bio = null,
    Object? followerCount = null,
    Object? followingCount = null,
    Object? reputationScore = null,
    Object? safetyScore = null,
    Object? isFollowing = null,
    Object? trustLevelStr = null,
    Object? standingSummary = null,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: null == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      followerCount: null == followerCount
          ? _value.followerCount
          : followerCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      reputationScore: null == reputationScore
          ? _value.reputationScore
          : reputationScore // ignore: cast_nullable_to_non_nullable
              as int,
      safetyScore: null == safetyScore
          ? _value.safetyScore
          : safetyScore // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      trustLevelStr: null == trustLevelStr
          ? _value.trustLevelStr
          : trustLevelStr // ignore: cast_nullable_to_non_nullable
              as String,
      standingSummary: null == standingSummary
          ? _value.standingSummary
          : standingSummary // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.id,
      required this.username,
      @JsonKey(name: 'display_name') required this.displayName,
      @JsonKey(name: 'photo_url') required this.photoUrl,
      required this.bio,
      @JsonKey(name: 'follower_count') this.followerCount = 0,
      @JsonKey(name: 'following_count') this.followingCount = 0,
      @JsonKey(name: 'reputation_score') this.reputationScore = 100,
      @JsonKey(name: 'safety_score') this.safetyScore = 100,
      @JsonKey(name: 'is_following') this.isFollowing = false,
      @JsonKey(name: 'trust_level') this.trustLevelStr = 'bronze',
      @JsonKey(name: 'standing_summary')
      this.standingSummary = 'In good standing'});

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  @JsonKey(name: 'display_name')
  final String displayName;
  @override
  @JsonKey(name: 'photo_url')
  final String photoUrl;
  @override
  final String bio;
  @override
  @JsonKey(name: 'follower_count')
  final int followerCount;
  @override
  @JsonKey(name: 'following_count')
  final int followingCount;
  @override
  @JsonKey(name: 'reputation_score')
  final int reputationScore;
  @override
  @JsonKey(name: 'safety_score')
  final int safetyScore;
  @override
  @JsonKey(name: 'is_following')
  final bool isFollowing;
  @override
  @JsonKey(name: 'trust_level')
  final String trustLevelStr;
  @override
  @JsonKey(name: 'standing_summary')
  final String standingSummary;

  @override
  String toString() {
    return 'UserProfile(id: $id, username: $username, displayName: $displayName, photoUrl: $photoUrl, bio: $bio, followerCount: $followerCount, followingCount: $followingCount, reputationScore: $reputationScore, safetyScore: $safetyScore, isFollowing: $isFollowing, trustLevelStr: $trustLevelStr, standingSummary: $standingSummary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.followerCount, followerCount) ||
                other.followerCount == followerCount) &&
            (identical(other.followingCount, followingCount) ||
                other.followingCount == followingCount) &&
            (identical(other.reputationScore, reputationScore) ||
                other.reputationScore == reputationScore) &&
            (identical(other.safetyScore, safetyScore) ||
                other.safetyScore == safetyScore) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.trustLevelStr, trustLevelStr) ||
                other.trustLevelStr == trustLevelStr) &&
            (identical(other.standingSummary, standingSummary) ||
                other.standingSummary == standingSummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      username,
      displayName,
      photoUrl,
      bio,
      followerCount,
      followingCount,
      reputationScore,
      safetyScore,
      isFollowing,
      trustLevelStr,
      standingSummary);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
          {required final String id,
          required final String username,
          @JsonKey(name: 'display_name') required final String displayName,
          @JsonKey(name: 'photo_url') required final String photoUrl,
          required final String bio,
          @JsonKey(name: 'follower_count') final int followerCount,
          @JsonKey(name: 'following_count') final int followingCount,
          @JsonKey(name: 'reputation_score') final int reputationScore,
          @JsonKey(name: 'safety_score') final int safetyScore,
          @JsonKey(name: 'is_following') final bool isFollowing,
          @JsonKey(name: 'trust_level') final String trustLevelStr,
          @JsonKey(name: 'standing_summary') final String standingSummary}) =
      _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  @JsonKey(name: 'display_name')
  String get displayName;
  @override
  @JsonKey(name: 'photo_url')
  String get photoUrl;
  @override
  String get bio;
  @override
  @JsonKey(name: 'follower_count')
  int get followerCount;
  @override
  @JsonKey(name: 'following_count')
  int get followingCount;
  @override
  @JsonKey(name: 'reputation_score')
  int get reputationScore;
  @override
  @JsonKey(name: 'safety_score')
  int get safetyScore;
  @override
  @JsonKey(name: 'is_following')
  bool get isFollowing;
  @override
  @JsonKey(name: 'trust_level')
  String get trustLevelStr;
  @override
  @JsonKey(name: 'standing_summary')
  String get standingSummary;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
