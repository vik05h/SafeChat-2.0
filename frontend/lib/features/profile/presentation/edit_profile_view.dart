import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../home/data/post_repository.dart';
import '../../../shared/widgets/firebase_image.dart';
import '../../../shared/widgets/image_crop_sheet.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  File? _selectedImage;
  File? _selectedBgImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authStateProvider).profile;
    _displayNameController = TextEditingController(text: profile?.displayName ?? '');
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (pickedFile == null || !mounted) return;
    // Bake a square crop so the avatar is framed identically everywhere it shows.
    final cropped = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImageCropSheet(
          file: File(pickedFile.path),
          aspectRatio: 1.0,
          circle: true,
          targetWidth: 512,
        ),
      ),
    );
    if (cropped != null) setState(() => _selectedImage = cropped);
  }

  Future<void> _pickBgImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1080);
    if (pickedFile == null || !mounted) return;
    // Bake a 2:1 banner crop to match the profile cover's display aspect.
    final cropped = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImageCropSheet(
          file: File(pickedFile.path),
          aspectRatio: 2.0,
          circle: false,
          targetWidth: 1280,
        ),
      ),
    );
    if (cropped != null) setState(() => _selectedBgImage = cropped);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final profile = ref.read(authStateProvider).profile;
    final String? updatedUsername = _usernameController.text.trim() != profile?.username ? _usernameController.text.trim() : null;
    final String? updatedDisplayName = _displayNameController.text.trim() != profile?.displayName ? _displayNameController.text.trim() : null;
    final String? updatedBio = _bioController.text.trim() != profile?.bio ? _bioController.text.trim() : null;

    if (updatedUsername == null && updatedDisplayName == null && updatedBio == null && _selectedImage == null && _selectedBgImage == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      setState(() => _isUploading = true);
      String? photoUrl;
      String? backgroundUrl;
      
      final apiService = ref.read(postApiServiceProvider);

      if (_selectedImage != null) {
        final file = _selectedImage!;
        final lower = file.path.toLowerCase();
        final contentType = lower.endsWith('.png') ? 'image/png' : (lower.endsWith('.webp') ? 'image/webp' : 'image/jpeg');

        final signResponse = await apiService.signUpload(
          contentType: contentType,
          sizeBytes: file.lengthSync(),
          purpose: 'avatar',
        );

        final uploadUrl = signResponse['data']['upload_url'] as String;
        final objectPath = signResponse['data']['object_path'] as String;

        await apiService.uploadDirectlyToStorage(
          uploadUrl: uploadUrl,
          file: file,
          contentType: contentType,
        );

        final uri = Uri.parse(uploadUrl);
        final bucketName = uri.pathSegments.first;
        photoUrl = 'https://storage.googleapis.com/$bucketName/$objectPath';
      }

      if (_selectedBgImage != null) {
        final file = _selectedBgImage!;
        final lower = file.path.toLowerCase();
        final contentType = lower.endsWith('.png') ? 'image/png' : (lower.endsWith('.webp') ? 'image/webp' : 'image/jpeg');

        final signResponse = await apiService.signUpload(
          contentType: contentType,
          sizeBytes: file.lengthSync(),
          purpose: 'background',
        );

        final uploadUrl = signResponse['data']['upload_url'] as String;
        final objectPath = signResponse['data']['object_path'] as String;

        await apiService.uploadDirectlyToStorage(
          uploadUrl: uploadUrl,
          file: file,
          contentType: contentType,
        );

        final uri = Uri.parse(uploadUrl);
        final bucketName = uri.pathSegments.first;
        backgroundUrl = 'https://storage.googleapis.com/$bucketName/$objectPath';
      }

      await ref.read(authControllerProvider.notifier).updateProfile(
        displayName: updatedDisplayName,
        username: updatedUsername,
        bio: updatedBio,
        photoUrl: photoUrl,
        backgroundUrl: backgroundUrl,
      );
      
      if (mounted) {
        final error = ref.read(authStateProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // _isUploading covers the whole save (image upload + profile update);
    // the provider's isLoading only covers the final update call.
    final isBusy = _isUploading || ref.watch(authStateProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: isBusy ? null : _saveProfile,
            child: isBusy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      // Background Image Picker
                      GestureDetector(
                        onTap: _pickBgImage,
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            image: _selectedBgImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedBgImage!),
                                    fit: BoxFit.cover,
                                  )
                                : (ref.read(authStateProvider).profile?.backgroundUrl != null
                                    ? DecorationImage(
                                        image: FirebaseImageProviderWrapper.getProvider(ref, ref.read(authStateProvider).profile!.backgroundUrl!) ?? const NetworkImage(''),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                          ),
                          child: _selectedBgImage == null && ref.read(authStateProvider).profile?.backgroundUrl == null
                              ? const Center(child: Icon(Icons.add_photo_alternate, size: 40))
                              : const Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.black54,
                                      child: Icon(Icons.edit, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Profile Photo Picker
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!) as ImageProvider
                                : (ref.read(authStateProvider).profile?.photoUrl != null
                                    ? FirebaseImageProviderWrapper.getProvider(ref, ref.read(authStateProvider).profile!.photoUrl!)
                                    : null),
                            child: _selectedImage == null && ref.read(authStateProvider).profile?.photoUrl == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'What should we call you?',
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Display name is required' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'unique_name',
                    prefixText: '@',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Username is required';
                    if (!RegExp(r'^[a-z0-9_]{3,30}$').hasMatch(v.trim())) {
                      return '3-30 chars, lowercase, numbers, underscores only';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Note: You can only change your username once every 30 days.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Tell us about yourself...',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
