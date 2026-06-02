import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    @JsonKey(name: 'author_uid') required String authorUid,
    @JsonKey(name: 'author_username') required String authorUsername,
    @JsonKey(name: 'author_display_name') required String authorDisplayName,
    @JsonKey(name: 'author_photo_url') required String authorPhotoUrl,
    required String caption,
    @JsonKey(name: 'media_urls') @Default([]) List<String> mediaUrls,
    @JsonKey(name: 'media_type') required String mediaType,
    required String status,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
