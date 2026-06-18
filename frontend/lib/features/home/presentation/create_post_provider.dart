import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';
import 'feed_provider.dart';

/// The result of submitting a post — passed back to the UI.
enum SubmitOutcome { approved, pendingReview }

class CreatePostState {
  final List<File> selectedMedia;
  final String caption;
  final bool isSimpleMode;
  final AsyncValue<void> submissionState;

  CreatePostState({
    this.selectedMedia = const [],
    this.caption = '',
    this.isSimpleMode = false,
    this.submissionState = const AsyncData(null),
  });

  CreatePostState copyWith({
    List<File>? selectedMedia,
    String? caption,
    bool? isSimpleMode,
    AsyncValue<void>? submissionState,
  }) {
    return CreatePostState(
      selectedMedia: selectedMedia ?? this.selectedMedia,
      caption: caption ?? this.caption,
      isSimpleMode: isSimpleMode ?? this.isSimpleMode,
      submissionState: submissionState ?? this.submissionState,
    );
  }
}

class CreatePostNotifier extends Notifier<CreatePostState> {
  @override
  CreatePostState build() => CreatePostState();

  void setMode(bool isSimple) => state = state.copyWith(isSimpleMode: isSimple);

  void setCaption(String text) => state = state.copyWith(caption: text);

  void addMedia(List<File> files) {
    final newList = List<File>.from(state.selectedMedia)..addAll(files);
    state = state.copyWith(selectedMedia: newList.take(5).toList());
  }

  void removeMedia(int index) {
    final newList = List<File>.from(state.selectedMedia)..removeAt(index);
    state = state.copyWith(selectedMedia: newList);
  }

  /// Returns null on failure, or a [SubmitOutcome] on success.
  Future<SubmitOutcome?> submitPost() async {
    state = state.copyWith(submissionState: const AsyncLoading());
    try {
      final repo = ref.read(postRepositoryProvider);
      final result = await repo.createPostWithMedia(
        caption: state.caption,
        mediaFiles: state.selectedMedia,
      );

      state = state.copyWith(submissionState: const AsyncData(null));

      // Refresh the feed so the new post appears immediately.
      ref.invalidate(feedPostsProvider('global'));
      ref.invalidate(feedPostsProvider('following'));

      return result == PostSubmitResult.pendingReview
          ? SubmitOutcome.pendingReview
          : SubmitOutcome.approved;
    } catch (e, st) {
      print('SUBMIT POST ERROR: $e');
      print('STACKTRACE: $st');
      state = state.copyWith(submissionState: AsyncError(e, st));
      return null; // failure
    }
  }

  void reset() => state = CreatePostState();
}

final createPostProvider =
    NotifierProvider<CreatePostNotifier, CreatePostState>(() {
  return CreatePostNotifier();
});
