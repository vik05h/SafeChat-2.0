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
}
