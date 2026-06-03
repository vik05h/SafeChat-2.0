// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      photoUrl: json['photo_url'] as String,
      bio: json['bio'] as String,
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      reputationScore: (json['reputation_score'] as num?)?.toInt() ?? 100,
      safetyScore: (json['safety_score'] as num?)?.toInt() ?? 100,
      isFollowing: json['is_following'] as bool? ?? false,
      trustLevelStr: json['trust_level'] as String? ?? 'bronze',
      standingSummary:
          json['standing_summary'] as String? ?? 'In good standing',
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'display_name': instance.displayName,
      'photo_url': instance.photoUrl,
      'bio': instance.bio,
      'follower_count': instance.followerCount,
      'following_count': instance.followingCount,
      'reputation_score': instance.reputationScore,
      'safety_score': instance.safetyScore,
      'is_following': instance.isFollowing,
      'trust_level': instance.trustLevelStr,
      'standing_summary': instance.standingSummary,
    };
