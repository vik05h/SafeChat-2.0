import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/post.dart';

final feedServiceProvider = Provider<FeedService>((ref) {
  return FeedService(ref.watch(dioProvider));
});

class FeedService {
  final Dio _dio;

  FeedService(this._dio);

  Future<List<Post>> getFeed({String? cursor, int limit = 20}) async {
    try {
      final queryParams = {'limit': limit};
      if (cursor != null) queryParams['cursor'] = cursor;

      final response = await _dio.get('/posts/feed', queryParameters: queryParams);
      
      final List<dynamic> data = response.data['data']['posts'] ?? [];
      return data.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load feed: $e');
    }
  }

  Future<void> likePost(String postId) async {
    await _dio.post('/posts/$postId/like');
  }

  Future<void> unlikePost(String postId) async {
    await _dio.delete('/posts/$postId/like');
  }
}
