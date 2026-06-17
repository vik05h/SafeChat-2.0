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
    final response = await _dio.post('/api/v1/uploads/sign', data: {
      'content_type': contentType,
      'size_bytes': sizeBytes,
      'purpose': purpose,
    });
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
  }) async {
    final response = await _dio.post(
      '/api/v1/posts',
      data: {
        'text': caption,
        'media_urls': mediaUrls,
        'media_type': mediaType,
      },
      // Accept 201 and 202 without throwing.
      options: Options(validateStatus: (s) => s != null && s >= 200 && s < 300),
    );
    return (statusCode: response.statusCode ?? 200, data: response.data as Map<String, dynamic>);
  }

  /// Fetch the public feed. Returns a list of post maps.
  Future<List<Map<String, dynamic>>> getFeed({int limit = 20}) async {
    final response = await _dio.get(
      '/api/v1/posts/feed',
      queryParameters: {'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final posts = (data['data']?['posts'] as List<dynamic>?) ?? [];
    return posts.cast<Map<String, dynamic>>();
  }
}
