import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/post.dart';
import 'dart:io';

final postServiceProvider = Provider<PostService>((ref) {
  return PostService(ref.watch(dioProvider));
});

class PostService {
  final Dio _dio;

  PostService(this._dio);

  Future<Post> createPost({
    required String caption,
    File? imageFile,
    bool submitForReview = false,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'caption': caption,
        'submit_for_review': submitForReview,
      });

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imageFile.path),
        ));
      }

      final response = await _dio.post('/posts', data: formData);
      return Post.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Future<List<Post>> getPostsByUserId(String userId, {int limit = 20}) async {
    try {
      final response = await _dio.get('/users/$userId/posts', queryParameters: {'limit': limit});
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user posts: $e');
    }
  }
}
