import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';

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
  CreatePostState build() {
    return CreatePostState();
  }

  void setMode(bool isSimple) {
    state = state.copyWith(isSimpleMode: isSimple);
  }

  void setCaption(String text) {
    state = state.copyWith(caption: text);
  }

  void addMedia(List<File> files) {
    final newList = List<File>.from(state.selectedMedia)..addAll(files);
    // Limit to 5
    state = state.copyWith(selectedMedia: newList.take(5).toList());
  }

  void removeMedia(int index) {
    final newList = List<File>.from(state.selectedMedia)..removeAt(index);
    state = state.copyWith(selectedMedia: newList);
  }

  Future<bool> submitPost() async {
    state = state.copyWith(submissionState: const AsyncLoading());
    try {
      final repo = ref.read(postRepositoryProvider);
      
      await repo.createPostWithMedia(
        caption: state.caption,
        mediaFiles: state.selectedMedia,
      );
      
      state = state.copyWith(submissionState: const AsyncData(null));
      return true; // Success
    } catch (e, st) {
      print('SUBMIT POST ERROR: $e');
      print('STACKTRACE: $st');
      state = state.copyWith(submissionState: AsyncError(e, st));
      return false; // Failed
    }
  }

  void reset() {
    state = CreatePostState();
  }
}

final createPostProvider = NotifierProvider<CreatePostNotifier, CreatePostState>(() {
  return CreatePostNotifier();
});
