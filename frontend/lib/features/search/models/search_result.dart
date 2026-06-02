import 'package:freezed_annotation/freezed_annotation.dart';
import '../../profile/models/user_profile.dart';
import '../../../shared/models/post.dart';

part 'search_result.freezed.dart';
part 'search_result.g.dart';

@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult.user(UserProfile user) = SearchResultUser;
  const factory SearchResult.post(Post post) = SearchResultPost;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'user') {
      return SearchResult.user(UserProfile.fromJson(json['data']));
    } else {
      return SearchResult.post(Post.fromJson(json['data']));
    }
  }
}
