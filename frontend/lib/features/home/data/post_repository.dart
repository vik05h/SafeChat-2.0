import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import 'post_api_service.dart';

final postApiServiceProvider = Provider<PostApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return PostApiService(dio);
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final apiService = ref.watch(postApiServiceProvider);
  return PostRepository(apiService: apiService);
});

class PostRepository {
  final PostApiService _apiService;

  PostRepository({required PostApiService apiService}) : _apiService = apiService;

  /// Uploads media and creates a post in the backend.
  /// This takes care of the whole flow: Sign URL -> Upload -> Create Post.
  Future<void> createPostWithMedia({
    required String caption,
    required List<File> mediaFiles,
  }) async {
    final mediaUrls = <String>[];
    
    // 1. Upload each file directly to Firebase Storage via Signed URLs
    for (var file in mediaFiles) {
      final contentType = _getContentType(file.path);
      
      // Step A: Get Signed URL from our Python Backend
      final signResponse = await _apiService.signUpload(
        contentType: contentType,
        sizeBytes: file.lengthSync(), // Fast API ignores extra fields
        purpose: 'post',
      );
      
      final uploadUrl = signResponse['data']['upload_url'];
      final objectPath = signResponse['data']['object_path'];
      
      // Step B: Direct upload to Firebase Storage
      await _apiService.uploadDirectlyToStorage(
        uploadUrl: uploadUrl,
        file: file,
        contentType: contentType,
      );
      
      // Construct the public URL (replace 'safechat-prod.appspot.com' with your actual bucket if different)
      // Usually it's https://firebasestorage.googleapis.com/v0/b/<bucket>/o/<path>?alt=media
      // But according to backend storage.py, the format is:
      // https://storage.googleapis.com/{bucket}/{object_path}
      
      // We don't know the exact bucket name in the flutter app unless we parse it from the uploadUrl.
      // Let's parse it from uploadUrl: https://storage.googleapis.com/safechat-prod.appspot.com/uploads/...
      final uri = Uri.parse(uploadUrl);
      final bucketName = uri.pathSegments.first; // usually the bucket name is the first segment in GCS
      final publicUrl = 'https://storage.googleapis.com/$bucketName/$objectPath';
      
      mediaUrls.add(publicUrl);
    }
    
    // 2. Submit the post data to our Python backend for moderation and creation
    // The mediaType is assumed 'image' for this prototype
    await _apiService.createPost(
      caption: caption,
      mediaUrls: mediaUrls,
      mediaType: mediaUrls.isNotEmpty ? 'image' : 'text',
    );
  }
  
  String _getContentType(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.png')) return 'image/png';
    if (lowerPath.endsWith('.webp')) return 'image/webp';
    if (lowerPath.endsWith('.mp4')) return 'video/mp4';
    return 'image/jpeg'; // default
  }
}
