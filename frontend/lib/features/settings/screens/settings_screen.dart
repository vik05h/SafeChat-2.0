import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../services/settings_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isPrivateAccount = false;
  bool _isLoading = false;

  void _togglePrivacy(bool value) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(settingsServiceProvider).updatePrivacySettings(isPrivate: value);
      setState(() => _isPrivateAccount = value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update privacy: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Delete Account', style: TextStyle(color: AppColors.error)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This action cannot be undone. Please enter your password to confirm.'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isDeleting
                  ? null
                  : () async {
                      if (passwordController.text.isEmpty) return;
                      setStateDialog(() => isDeleting = true);

                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null && user.email != null) {
                          // Re-authenticate
                          AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: passwordController.text);
                          await user.reauthenticateWithCredential(credential);

                          // Delete from backend
                          await ref.read(settingsServiceProvider).deleteAccount();

                          // Delete from Firebase
                          await user.delete();

                          if (context.mounted) {
                            Navigator.pop(context); // close dialog
                            context.goNamed('login');
                          }
                        }
                      } catch (e) {
                        setStateDialog(() => isDeleting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account: $e'), backgroundColor: AppColors.error));
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: isDeleting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Delete Permanently'),
            ),
          ],
        ),
      ),
    );
  }

  void _logoutEverywhere() async {
    try {
      await ref.read(settingsServiceProvider).logoutEverywhere();
      await FirebaseAuth.instance.signOut();
      if (mounted) context.goNamed('login');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Privacy', style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Private Account'),
            subtitle: const Text('Only approved followers can see your posts'),
            value: _isPrivateAccount,
            onChanged: _isLoading ? null : _togglePrivacy,
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Restricted & Blocked Users'),
            onTap: () {
              context.pushNamed('blocked_users');
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Account Management', style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout Everywhere'),
            subtitle: const Text('Ends all active sessions on all devices'),
            onTap: _logoutEverywhere,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text('Delete Account', style: TextStyle(color: AppColors.error)),
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }
}
