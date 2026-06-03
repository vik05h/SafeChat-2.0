// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Post _$PostFromJson(Map<String, dynamic> json) {
  return _Post.fromJson(json);
}

/// @nodoc
mixin _$Post {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_uid')
  String get authorUid => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_username')
  String get authorUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_display_name')
  String get authorDisplayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_photo_url')
  String get authorPhotoUrl => throw _privateConstructorUsedError;
  String get caption => throw _privateConstructorUsedError;
  @JsonKey(name: 'media_urls')
  List<String> get mediaUrls => throw _privateConstructorUsedError;
  @JsonKey(name: 'media_type')
  String get mediaType => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'like_count')
  int get likeCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'comment_count')
  int get commentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_liked')
  bool get isLiked => throw _privateConstructorUsedError;

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostCopyWith<Post> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCopyWith<$Res> {
  factory $PostCopyWith(Post value, $Res Function(Post) then) =
      _$PostCopyWithImpl<$Res, Post>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'author_uid') String authorUid,
      @JsonKey(name: 'author_username') String authorUsername,
      @JsonKey(name: 'author_display_name') String authorDisplayName,
      @JsonKey(name: 'author_photo_url') String authorPhotoUrl,
      String caption,
      @JsonKey(name: 'media_urls') List<String> mediaUrls,
      @JsonKey(name: 'media_type') String mediaType,
      String status,
      @JsonKey(name: 'like_count') int likeCount,
      @JsonKey(name: 'comment_count') int commentCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'is_liked') bool isLiked});
}

/// @nodoc
class _$PostCopyWithImpl<$Res, $Val extends Post>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorUid = null,
    Object? authorUsername = null,
    Object? authorDisplayName = null,
    Object? authorPhotoUrl = null,
    Object? caption = null,
    Object? mediaUrls = null,
    Object? mediaType = null,
    Object? status = null,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? createdAt = null,
    Object? isLiked = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorUid: null == authorUid
          ? _value.authorUid
          : authorUid // ignore: cast_nullable_to_non_nullable
              as String,
      authorUsername: null == authorUsername
          ? _value.authorUsername
          : authorUsername // ignore: cast_nullable_to_non_nullable
              as String,
      authorDisplayName: null == authorDisplayName
          ? _value.authorDisplayName
          : authorDisplayName // ignore: cast_nullable_to_non_nullable
              as String,
      authorPhotoUrl: null == authorPhotoUrl
          ? _value.authorPhotoUrl
          : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      caption: null == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String,
      mediaUrls: null == mediaUrls
          ? _value.mediaUrls
          : mediaUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostImplCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$$PostImplCopyWith(
          _$PostImpl value, $Res Function(_$PostImpl) then) =
      __$$PostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'author_uid') String authorUid,
      @JsonKey(name: 'author_username') String authorUsername,
      @JsonKey(name: 'author_display_name') String authorDisplayName,
      @JsonKey(name: 'author_photo_url') String authorPhotoUrl,
      String caption,
      @JsonKey(name: 'media_urls') List<String> mediaUrls,
      @JsonKey(name: 'media_type') String mediaType,
      String status,
      @JsonKey(name: 'like_count') int likeCount,
      @JsonKey(name: 'comment_count') int commentCount,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'is_liked') bool isLiked});
}

/// @nodoc
class __$$PostImplCopyWithImpl<$Res>
    extends _$PostCopyWithImpl<$Res, _$PostImpl>
    implements _$$PostImplCopyWith<$Res> {
  __$$PostImplCopyWithImpl(_$PostImpl _value, $Res Function(_$PostImpl) _then)
      : super(_value, _then);

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorUid = null,
    Object? authorUsername = null,
    Object? authorDisplayName = null,
    Object? authorPhotoUrl = null,
    Object? caption = null,
    Object? mediaUrls = null,
    Object? mediaType = null,
    Object? status = null,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? createdAt = null,
    Object? isLiked = null,
  }) {
    return _then(_$PostImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorUid: null == authorUid
          ? _value.authorUid
          : authorUid // ignore: cast_nullable_to_non_nullable
              as String,
      authorUsername: null == authorUsername
          ? _value.authorUsername
          : authorUsername // ignore: cast_nullable_to_non_nullable
              as String,
      authorDisplayName: null == authorDisplayName
          ? _value.authorDisplayName
          : authorDisplayName // ignore: cast_nullable_to_non_nullable
              as String,
      authorPhotoUrl: null == authorPhotoUrl
          ? _value.authorPhotoUrl
          : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      caption: null == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String,
      mediaUrls: null == mediaUrls
          ? _value._mediaUrls
          : mediaUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mediaType: null == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostImpl implements _Post {
  const _$PostImpl(
      {required this.id,
      @JsonKey(name: 'author_uid') required this.authorUid,
      @JsonKey(name: 'author_username') required this.authorUsername,
      @JsonKey(name: 'author_display_name') required this.authorDisplayName,
      @JsonKey(name: 'author_photo_url') required this.authorPhotoUrl,
      required this.caption,
      @JsonKey(name: 'media_urls') final List<String> mediaUrls = const [],
      @JsonKey(name: 'media_type') required this.mediaType,
      required this.status,
      @JsonKey(name: 'like_count') this.likeCount = 0,
      @JsonKey(name: 'comment_count') this.commentCount = 0,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'is_liked') this.isLiked = false})
      : _mediaUrls = mediaUrls;

  factory _$PostImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'author_uid')
  final String authorUid;
  @override
  @JsonKey(name: 'author_username')
  final String authorUsername;
  @override
  @JsonKey(name: 'author_display_name')
  final String authorDisplayName;
  @override
  @JsonKey(name: 'author_photo_url')
  final String authorPhotoUrl;
  @override
  final String caption;
  final List<String> _mediaUrls;
  @override
  @JsonKey(name: 'media_urls')
  List<String> get mediaUrls {
    if (_mediaUrls is EqualUnmodifiableListView) return _mediaUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediaUrls);
  }

  @override
  @JsonKey(name: 'media_type')
  final String mediaType;
  @override
  final String status;
  @override
  @JsonKey(name: 'like_count')
  final int likeCount;
  @override
  @JsonKey(name: 'comment_count')
  final int commentCount;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'is_liked')
  final bool isLiked;

  @override
  String toString() {
    return 'Post(id: $id, authorUid: $authorUid, authorUsername: $authorUsername, authorDisplayName: $authorDisplayName, authorPhotoUrl: $authorPhotoUrl, caption: $caption, mediaUrls: $mediaUrls, mediaType: $mediaType, status: $status, likeCount: $likeCount, commentCount: $commentCount, createdAt: $createdAt, isLiked: $isLiked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorUid, authorUid) ||
                other.authorUid == authorUid) &&
            (identical(other.authorUsername, authorUsername) ||
                other.authorUsername == authorUsername) &&
            (identical(other.authorDisplayName, authorDisplayName) ||
                other.authorDisplayName == authorDisplayName) &&
            (identical(other.authorPhotoUrl, authorPhotoUrl) ||
                other.authorPhotoUrl == authorPhotoUrl) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            const DeepCollectionEquality()
                .equals(other._mediaUrls, _mediaUrls) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      authorUid,
      authorUsername,
      authorDisplayName,
      authorPhotoUrl,
      caption,
      const DeepCollectionEquality().hash(_mediaUrls),
      mediaType,
      status,
      likeCount,
      commentCount,
      createdAt,
      isLiked);

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      __$$PostImplCopyWithImpl<_$PostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostImplToJson(
      this,
    );
  }
}

abstract class _Post implements Post {
  const factory _Post(
      {required final String id,
      @JsonKey(name: 'author_uid') required final String authorUid,
      @JsonKey(name: 'author_username') required final String authorUsername,
      @JsonKey(name: 'author_display_name')
      required final String authorDisplayName,
      @JsonKey(name: 'author_photo_url') required final String authorPhotoUrl,
      required final String caption,
      @JsonKey(name: 'media_urls') final List<String> mediaUrls,
      @JsonKey(name: 'media_type') required final String mediaType,
      required final String status,
      @JsonKey(name: 'like_count') final int likeCount,
      @JsonKey(name: 'comment_count') final int commentCount,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'is_liked') final bool isLiked}) = _$PostImpl;

  factory _Post.fromJson(Map<String, dynamic> json) = _$PostImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'author_uid')
  String get authorUid;
  @override
  @JsonKey(name: 'author_username')
  String get authorUsername;
  @override
  @JsonKey(name: 'author_display_name')
  String get authorDisplayName;
  @override
  @JsonKey(name: 'author_photo_url')
  String get authorPhotoUrl;
  @override
  String get caption;
  @override
  @JsonKey(name: 'media_urls')
  List<String> get mediaUrls;
  @override
  @JsonKey(name: 'media_type')
  String get mediaType;
  @override
  String get status;
  @override
  @JsonKey(name: 'like_count')
  int get likeCount;
  @override
  @JsonKey(name: 'comment_count')
  int get commentCount;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'is_liked')
  bool get isLiked;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
