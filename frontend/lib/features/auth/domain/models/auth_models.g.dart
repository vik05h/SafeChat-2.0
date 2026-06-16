// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  uid: json['uid'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String,
  bio: json['bio'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'display_name': instance.displayName,
      'bio': instance.bio,
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

OnboardRequest _$OnboardRequestFromJson(Map<String, dynamic> json) =>
    OnboardRequest(
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      bio: json['bio'] as String?,
    );

Map<String, dynamic> _$OnboardRequestToJson(OnboardRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'display_name': instance.displayName,
      'bio': instance.bio,
    };

AuthMeResponse _$AuthMeResponseFromJson(Map<String, dynamic> json) =>
    AuthMeResponse(
      user: json['user'] as Map<String, dynamic>,
      profile: json['profile'] == null
          ? null
          : UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      needsOnboarding: json['needs_onboarding'] as bool,
    );

Map<String, dynamic> _$AuthMeResponseToJson(AuthMeResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'profile': instance.profile,
      'needs_onboarding': instance.needsOnboarding,
    };
