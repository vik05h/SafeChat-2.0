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
    // Note: We use a fresh Dio instance here because the uploadUrl is a full URL to Google Cloud Storage
    // and we DON'T want to attach our Firebase Bearer token to this request (Storage handles its own signed auth)
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

  Future<Map<String, dynamic>> createPost({
    required String caption,
    required List<String> mediaUrls,
    required String mediaType,
  }) async {
    final response = await _dio.post('/api/v1/posts', data: {
      'text': caption,
      'media_urls': mediaUrls,
      'media_type': mediaType,
    });
    return response.data;
  }
}
