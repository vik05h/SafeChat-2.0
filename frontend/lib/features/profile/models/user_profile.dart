import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum TrustLevel { bronze, silver, gold, trusted }

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'photo_url') required String photoUrl,
    required String bio,
    @JsonKey(name: 'follower_count') @Default(0) int followerCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
    @JsonKey(name: 'reputation_score') @Default(100) int reputationScore,
    @JsonKey(name: 'safety_score') @Default(100) int safetyScore,
    @JsonKey(name: 'is_following') @Default(false) bool isFollowing,
    @JsonKey(name: 'trust_level') @Default('bronze') String trustLevelStr,
    @JsonKey(name: 'standing_summary') @Default('In good standing') String standingSummary,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

extension UserProfileTrust on UserProfile {
  TrustLevel get trustLevel {
    switch (trustLevelStr.toLowerCase()) {
      case 'trusted':
        return TrustLevel.trusted;
      case 'gold':
        return TrustLevel.gold;
      case 'silver':
        return TrustLevel.silver;
      case 'bronze':
      default:
        return TrustLevel.bronze;
    }
  }
}
