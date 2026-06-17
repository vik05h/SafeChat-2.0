import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';

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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final profile = ref.read(authStateProvider).profile;
    final String? updatedUsername = _usernameController.text.trim() != profile?.username ? _usernameController.text.trim() : null;
    final String? updatedDisplayName = _displayNameController.text.trim() != profile?.displayName ? _displayNameController.text.trim() : null;
    final String? updatedBio = _bioController.text.trim() != profile?.bio ? _bioController.text.trim() : null;

    if (updatedUsername == null && updatedDisplayName == null && updatedBio == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
        displayName: updatedDisplayName,
        username: updatedUsername,
        bio: updatedBio,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _saveProfile,
            child: isLoading
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
