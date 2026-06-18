import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import 'comment_model.dart';
import 'feed_post_model.dart';
import 'post_api_service.dart';

final postApiServiceProvider = Provider<PostApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return PostApiService(dio);
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final apiService = ref.watch(postApiServiceProvider);
  return PostRepository(apiService: apiService);
});

/// The outcome of creating a post.
enum PostSubmitResult {
  /// Post passed moderation and is live in the feed.
  approved,

  /// Post was flagged and is waiting for a human moderator.
  pendingReview,
}

class PostRepository {
  final PostApiService _apiService;

  PostRepository({required this._apiService});

  /// Upload media files + create a post in the backend.
  /// Returns [PostSubmitResult] so the UI can show the right message.
  Future<PostSubmitResult> createPostWithMedia({
    required String caption,
    required List<File> mediaFiles,
  }) async {
    final mediaUrls = <String>[];

    // 1. Upload each file to Firebase Storage via a signed URL from the backend.
    for (final file in mediaFiles) {
      final contentType = _getContentType(file.path);

      final signResponse = await _apiService.signUpload(
        contentType: contentType,
        sizeBytes: file.lengthSync(),
        purpose: 'post',
      );

      final uploadUrl = signResponse['data']['upload_url'] as String;
      final objectPath = signResponse['data']['object_path'] as String;

      await _apiService.uploadDirectlyToStorage(
        uploadUrl: uploadUrl,
        file: file,
        contentType: contentType,
      );

      // Derive the public GCS URL from the signed URL's host + bucket segment.
      final uri = Uri.parse(uploadUrl);
      final bucketName = uri.pathSegments.first;
      final publicUrl = 'https://storage.googleapis.com/$bucketName/$objectPath';
      mediaUrls.add(publicUrl);
    }

    // 2. Send post to backend for moderation + persistence.
    final result = await _apiService.createPost(
      caption: caption,
      mediaUrls: mediaUrls,
      mediaType: mediaUrls.isNotEmpty ? 'image' : 'text',
    );

    // 201 = approved (live in feed), 202 = pending human review.
    return result.statusCode == 202
        ? PostSubmitResult.pendingReview
        : PostSubmitResult.approved;
  }

  /// Fetch the public feed (approved posts). Type can be 'global' or 'following'.
  Future<List<FeedPost>> getFeed({int limit = 20, String type = 'following'}) async {
    final maps = await _apiService.getFeed(limit: limit, type: type);
    return maps.map(FeedPost.fromJson).toList();
  }

  /// Records a view for a post on the backend.
  Future<void> viewPost(String postId) async {
    await _apiService.viewPost(postId);
  }

  Future<void> likePost(String postId) async {
    await _apiService.likePost(postId);
  }

  Future<void> unlikePost(String postId) async {
    await _apiService.unlikePost(postId);
  }

  Future<List<Comment>> getComments(String postId, {int limit = 20}) async {
    final maps = await _apiService.getComments(postId, limit: limit);
    return maps.map(Comment.fromJson).toList();
  }

  Future<Comment> createComment(String postId, String text, {String? parentCommentId}) async {
    final map = await _apiService.createComment(postId, text, parentCommentId: parentCommentId);
    return Comment.fromJson(map);
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _apiService.deleteComment(postId, commentId);
  }

  String _getContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    return 'image/jpeg';
  }
}
