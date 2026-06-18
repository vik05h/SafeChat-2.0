// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  uid: json['uid'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String,
  phoneNumber: json['phone_number'] as String?,
  dob: json['dob'] as String,
  bio: json['bio'] as String?,
  photoUrl: json['photo_url'] as String?,
  backgroundUrl: json['background_url'] as String?,
  avatarTransform: json['avatar_transform'] == null
      ? null
      : ImageTransform.fromJson(
          json['avatar_transform'] as Map<String, dynamic>,
        ),
  coverTransform: json['cover_transform'] == null
      ? null
      : ImageTransform.fromJson(
          json['cover_transform'] as Map<String, dynamic>,
        ),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'username': instance.username,
      'display_name': instance.displayName,
      'phone_number': instance.phoneNumber,
      'dob': instance.dob,
      'bio': instance.bio,
      'photo_url': instance.photoUrl,
      'background_url': instance.backgroundUrl,
      'avatar_transform': instance.avatarTransform,
      'cover_transform': instance.coverTransform,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

OnboardRequest _$OnboardRequestFromJson(Map<String, dynamic> json) =>
    OnboardRequest(
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      dob: json['dob'] as String,
      bio: json['bio'] as String?,
    );

Map<String, dynamic> _$OnboardRequestToJson(OnboardRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'display_name': instance.displayName,
      'phone_number': instance.phoneNumber,
      'dob': instance.dob,
      'bio': instance.bio,
    };

UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequest(
  displayName: json['display_name'] as String?,
  username: json['username'] as String?,
  bio: json['bio'] as String?,
  photoUrl: json['photo_url'] as String?,
  backgroundUrl: json['background_url'] as String?,
  avatarTransform: json['avatar_transform'] == null
      ? null
      : ImageTransform.fromJson(
          json['avatar_transform'] as Map<String, dynamic>,
        ),
  coverTransform: json['cover_transform'] == null
      ? null
      : ImageTransform.fromJson(
          json['cover_transform'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  UpdateProfileRequest instance,
) => <String, dynamic>{
  'display_name': ?instance.displayName,
  'username': ?instance.username,
  'bio': ?instance.bio,
  'photo_url': ?instance.photoUrl,
  'background_url': ?instance.backgroundUrl,
  'avatar_transform': ?instance.avatarTransform,
  'cover_transform': ?instance.coverTransform,
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

ImageTransform _$ImageTransformFromJson(Map<String, dynamic> json) =>
    ImageTransform(
      scale: (json['scale'] as num).toDouble(),
      offsetX: (json['offset_x'] as num).toDouble(),
      offsetY: (json['offset_y'] as num).toDouble(),
    );

Map<String, dynamic> _$ImageTransformToJson(ImageTransform instance) =>
    <String, dynamic>{
      'scale': instance.scale,
      'offset_x': instance.offsetX,
      'offset_y': instance.offsetY,
    };
