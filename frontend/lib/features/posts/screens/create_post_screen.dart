import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:io';

import '../../../app/theme/app_colors.dart';
import '../../moderation/services/moderation_service.dart';
import '../../moderation/models/moderation_result.dart';
import '../services/post_service.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _textController = TextEditingController();
  File? _selectedImage;
  bool _isAnalyzing = false;
  ModerationResult? _moderationResult;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _publishPost() async {
    if (_textController.text.trim().isEmpty && _selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _moderationResult = null;
    });

    try {
      final moderationService = ref.read(moderationServiceProvider);
      // Run the text through the moderation API
      final result = await moderationService.analyzeContent(_textController.text);
      
      setState(() {
        _moderationResult = result;
        _isAnalyzing = false;
      });

      if (result.status == ModerationStatus.safe) {
        await ref.read(postServiceProvider).createPost(
          caption: _textController.text,
          imageFile: _selectedImage,
        );
        FirebaseAnalytics.instance.logEvent(name: 'post_created');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published successfully!', style: TextStyle(color: AppColors.background)), backgroundColor: AppColors.success),
        );
        context.pop();
      } else if (result.status == ModerationStatus.warning) {
        // Show Warning Modal
        _showWarningModal(result);
      } else if (result.status == ModerationStatus.blocked) {
        // Prevent Submission
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post blocked: ${result.category ?? "Violates community guidelines"}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e, st) {
      setState(() { _isAnalyzing = false; });
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Failed to publish post');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error publishing post: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showWarningModal(ModerationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Content Warning'),
          ],
        ),
        content: Text(
          'Your post has been flagged for ${result.category ?? "sensitive content"}. '
          'Please consider revising it to align with our community guidelines.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Edit Post'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop();
              try {
                setState(() => _isAnalyzing = true);
                await ref.read(postServiceProvider).createPost(
                  caption: _textController.text,
                  imageFile: _selectedImage,
                  submitForReview: true,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post submitted for review.'), backgroundColor: AppColors.warning),
                );
                context.pop(); // pop the CreatePostScreen
              } catch (e, st) {
                setState(() => _isAnalyzing = false);
                FirebaseCrashlytics.instance.recordError(e, st, reason: 'Failed to submit post for review');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error submitting post: $e'), backgroundColor: AppColors.error),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Submit For Review'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: _isAnalyzing ? null : _publishPost,
            child: _isAnalyzing 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.border,
                  child: Icon(Icons.person, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: 5,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                      hintText: 'What\'s on your mind?',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedImage != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _selectedImage = null),
                      style: IconButton.styleFrom(backgroundColor: Colors.black54),
                    ),
                  )
                ],
              ),
            const Spacer(),
            if (_moderationResult?.status == ModerationStatus.blocked)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gpp_bad_rounded, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Content Blocked: ${_moderationResult!.reason}',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image_outlined, color: AppColors.primaryOrange),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.primaryOrange),
                    onPressed: () {
                      // TODO: Implement emoji picker
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
