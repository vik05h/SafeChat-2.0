// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
      id: json['id'] as String,
      authorUid: json['author_uid'] as String,
      authorUsername: json['author_username'] as String,
      authorDisplayName: json['author_display_name'] as String,
      authorPhotoUrl: json['author_photo_url'] as String,
      caption: json['caption'] as String,
      mediaUrls: (json['media_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mediaType: json['media_type'] as String,
      status: json['status'] as String,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      isLiked: json['is_liked'] as bool? ?? false,
    );

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_uid': instance.authorUid,
      'author_username': instance.authorUsername,
      'author_display_name': instance.authorDisplayName,
      'author_photo_url': instance.authorPhotoUrl,
      'caption': instance.caption,
      'media_urls': instance.mediaUrls,
      'media_type': instance.mediaType,
      'status': instance.status,
      'like_count': instance.likeCount,
      'comment_count': instance.commentCount,
      'created_at': instance.createdAt.toIso8601String(),
      'is_liked': instance.isLiked,
    };
