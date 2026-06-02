import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/search_result.dart';
import '../../profile/models/user_profile.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref.watch(dioProvider));
});

class SearchService {
  final Dio _dio;

  SearchService(this._dio);

  Future<List<SearchResultUser>> searchUsers(String query) async {
    try {
      final response = await _dio.get('/users/search', queryParameters: {'q': query});
      final List data = response.data['data']?['results'] ?? [];
      return data.map((json) => SearchResultUser(UserProfile.fromJson(json))).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  Future<List<SearchResultPost>> searchPosts(String query) async {
    try {
      final response = await _dio.get('/search/posts', queryParameters: {'q': query});
      final List data = response.data['data'] ?? [];
      return data.map((json) => SearchResult.fromJson({'type': 'post', 'data': json}) as SearchResultPost).toList();
    } catch (e) {
      throw Exception('Failed to search posts: $e');
    }
  }

  Future<List<UserProfile>> getSuggestedUsers() async {
    try {
      // Assuming a dedicated endpoint for suggestions, or fallback to an empty list
      final response = await _dio.get('/users/suggested');
      final List data = response.data['data'] ?? [];
      return data.map((json) => UserProfile.fromJson(json)).toList();
    } catch (e) {
      // Non-critical failure, return empty instead of breaking UI
      return [];
    }
  }
}
