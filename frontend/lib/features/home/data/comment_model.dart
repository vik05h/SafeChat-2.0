class Comment {
  final String id;
  final String postId;
  final String authorUid;
  final String authorDisplayName;
  final String authorUsername;
  final String authorPhotoUrl;
  final String text;
  final String? parentCommentId;
  final int likeCount;
  final DateTime? createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorUid,
    required this.authorDisplayName,
    required this.authorUsername,
    required this.authorPhotoUrl,
    required this.text,
    this.parentCommentId,
    this.likeCount = 0,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String? ?? '',
      postId: json['post_id'] as String? ?? '',
      authorUid: json['author_uid'] as String? ?? '',
      authorDisplayName: json['author_display_name'] as String? ?? 'Anonymous',
      authorUsername: json['author_username'] as String? ?? 'unknown',
      authorPhotoUrl: json['author_photo_url'] as String? ?? '',
      text: json['text'] as String? ?? '',
      parentCommentId: json['parent_comment_id'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
