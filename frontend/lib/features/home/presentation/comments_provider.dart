import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comment_model.dart';
import '../data/post_repository.dart';

final commentsProvider = AsyncNotifierProvider.family<CommentsNotifier, List<Comment>, String>(
  (arg) => CommentsNotifier(arg),
);

class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  final String arg;
  CommentsNotifier(this.arg);

  @override
  FutureOr<List<Comment>> build() async {
    return ref.read(postRepositoryProvider).getComments(arg);
  }

  Future<void> createComment(String text, {String? parentCommentId}) async {
    final oldState = state;
    final repo = ref.read(postRepositoryProvider);

    try {
      final newComment = await repo.createComment(arg, text, parentCommentId: parentCommentId);
      
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newComment]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      if (oldState.hasValue) {
        state = oldState;
      }
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId) async {
    final repo = ref.read(postRepositoryProvider);
    try {
      await repo.deleteComment(arg, commentId);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((c) => c.id != commentId).toList(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likeComment(String commentId) async {
    if (!state.hasValue) return;
    
    // Optimistic update
    final comments = state.value!;
    final index = comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;
    
    final oldComment = comments[index];
    if (oldComment.isLiked) return;
    
    final newComments = List<Comment>.from(comments);
    newComments[index] = oldComment.copyWith(
      isLiked: true,
      likeCount: oldComment.likeCount + 1,
    );
    state = AsyncValue.data(newComments);
    
    try {
      await ref.read(postRepositoryProvider).likeComment(arg, commentId);
    } catch (e) {
      // Revert
      newComments[index] = oldComment;
      state = AsyncValue.data(newComments);
      rethrow;
    }
  }

  Future<void> unlikeComment(String commentId) async {
    if (!state.hasValue) return;
    
    // Optimistic update
    final comments = state.value!;
    final index = comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;
    
    final oldComment = comments[index];
    if (!oldComment.isLiked) return;
    
    final newComments = List<Comment>.from(comments);
    newComments[index] = oldComment.copyWith(
      isLiked: false,
      likeCount: (oldComment.likeCount - 1).clamp(0, 999999),
    );
    state = AsyncValue.data(newComments);
    
    try {
      await ref.read(postRepositoryProvider).unlikeComment(arg, commentId);
    } catch (e) {
      // Revert
      newComments[index] = oldComment;
      state = AsyncValue.data(newComments);
      rethrow;
    }
  }
}
