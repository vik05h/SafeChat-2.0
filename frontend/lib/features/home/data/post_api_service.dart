import 'dart:io';
import 'package:dio/dio.dart';

class PostApiService {
  final Dio _dio;

  PostApiService(this._dio);

  Future<Map<String, dynamic>> signUpload({
    required String contentType,
    required int sizeBytes,
    required String purpose,
  }) async {
    final response = await _dio.post(
      '/api/v1/uploads/sign',
      data: {
        'content_type': contentType,
        'size_bytes': sizeBytes,
        'purpose': purpose,
      },
    );
    return response.data;
  }

  Future<void> uploadDirectlyToStorage({
    required String uploadUrl,
    required File file,
    required String contentType,
  }) async {
    // Fresh Dio — no Firebase Bearer token on GCS signed URL requests.
    final storageDio = Dio();
    await storageDio.put(
      uploadUrl,
      data: file.openRead(),
      options: Options(
        headers: {
          Headers.contentLengthHeader: file.lengthSync(),
          Headers.contentTypeHeader: contentType,
        },
      ),
    );
  }

  /// Returns the full response map including [statusCode] so callers can
  /// distinguish 201 (approved) from 202 (pending_review).
  Future<({int statusCode, Map<String, dynamic> data})> createPost({
    required String caption,
    required List<String> mediaUrls,
    required String mediaType,
    bool submitForReview = false,
  }) async {
    final response = await _dio.post(
      '/api/v1/posts',
      data: {
        'text': caption,
        'media_urls': mediaUrls,
        'media_type': mediaType,
        'submit_for_review': submitForReview,
      },
      // Accept 201 (approved), 202 (pending_review), and 422 (flagged) without
      // throwing — the repository inspects the status code.
      options: Options(
        validateStatus: (s) => s != null && ((s >= 200 && s < 300) || s == 422),
      ),
    );
    return (
      statusCode: response.statusCode ?? 200,
      data: response.data as Map<String, dynamic>,
    );
  }

  Future<List<Map<String, dynamic>>> getFeed({
    int limit = 20,
    String type = 'following',
  }) async {
    final response = await _dio.get(
      '/api/v1/posts/feed',
      queryParameters: {'limit': limit, 'type': type},
    );
    final data = response.data as Map<String, dynamic>;
    final posts = (data['data']?['posts'] as List<dynamic>?) ?? [];
    return posts.cast<Map<String, dynamic>>();
  }

  /// Fetch posts authored by a specific user.
  Future<List<Map<String, dynamic>>> getUserPosts(
    String uid, {
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/v1/users/$uid/posts',
      queryParameters: {'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final posts = (data['data'] as List<dynamic>?) ?? [];
    return posts.cast<Map<String, dynamic>>();
  }

  Future<void> viewPost(String postId) async {
    await _dio.post('/api/v1/posts/$postId/view');
  }

  Future<void> likePost(String postId) async {
    await _dio.post('/api/v1/posts/$postId/like');
  }

  Future<void> unlikePost(String postId) async {
    await _dio.delete('/api/v1/posts/$postId/like');
  }

  Future<void> deletePost(String postId) async {
    await _dio.delete('/api/v1/posts/$postId');
  }

  Future<List<Map<String, dynamic>>> getComments(
    String postId, {
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/v1/posts/$postId/comments',
      queryParameters: {'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final comments = (data['data']?['comments'] as List<dynamic>?) ?? [];
    return comments.cast<Map<String, dynamic>>();
  }

  /// Returns the full response (status + body) so the repository can tell
  /// 201/202 (created) from 422 (flagged).
  Future<({int statusCode, Map<String, dynamic> data})> createComment(
    String postId,
    String text, {
    String? parentCommentId,
    bool submitForReview = false,
  }) async {
    final response = await _dio.post(
      '/api/v1/posts/$postId/comments',
      data: {
        'text': text,
        'parent_comment_id': ?parentCommentId,
        'submit_for_review': submitForReview,
      },
      options: Options(
        validateStatus: (s) => s != null && ((s >= 200 && s < 300) || s == 422),
      ),
    );
    return (
      statusCode: response.statusCode ?? 200,
      data: response.data as Map<String, dynamic>,
    );
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _dio.delete('/api/v1/posts/$postId/comments/$commentId');
  }

  Future<void> likeComment(String postId, String commentId) async {
    await _dio.post('/api/v1/posts/$postId/comments/$commentId/like');
  }

  Future<void> unlikeComment(String postId, String commentId) async {
    await _dio.delete('/api/v1/posts/$postId/comments/$commentId/like');
  }
}
