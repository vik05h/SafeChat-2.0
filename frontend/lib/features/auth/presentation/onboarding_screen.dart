import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'auth_provider.dart';
import '../../../theme/app_colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _bioController = TextEditingController();
  String _completePhoneNumber = '';

  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void initState() {
    super.initState();
    // Pre-fill from Google Auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).user;
      if (user != null) {
        if (user.displayName != null) {
          _displayNameController.text = user.displayName!;
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubicEmphasized,
      );
    } else {
      _submit();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubicEmphasized,
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form.')),
      );
      return;
    }

    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref
          .read(authControllerProvider.notifier)
          .onboard(
            username: _usernameController.text.trim().toLowerCase(),
            displayName: _displayNameController.text.trim(),
            phoneNumber: _completePhoneNumber.isEmpty
                ? null
                : _completePhoneNumber,
            dob: _dobController.text.trim(),
            bio: _bioController.text.trim(),
          );

      final authState = ref.read(authStateProvider);
      if (mounted) Navigator.of(context).pop(); // dismiss loading

      if (authState.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(authState.error!)));
        }
      } else {
        if (mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // dismiss loading
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // Phone Verification logic is moved to Settings/Profile

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProgressBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  children: [
                    _buildStep1(isDark).animate().fade().slideX(
                      begin: 0.1,
                      curve: Curves.easeOutBack,
                    ),
                    _buildStep2(isDark).animate().fade().slideX(
                      begin: 0.1,
                      curve: Curves.easeOutBack,
                    ),
                    _buildStep3(isDark).animate().fade().slideX(
                      begin: 0.1,
                      curve: Curves.easeOutBack,
                    ),
                  ],
                ),
              ),
              _buildNavigationButtons(isDark, authState.isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: List.generate(_totalPages, (index) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 8,
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? AppColors.m3SeedColor
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    final user = ref.read(authStateProvider).user;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's get to know you!",
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 200.ms).moveY(begin: -20),
          const SizedBox(height: 40),
          Center(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _displayNameController,
              builder: (context, value, child) {
                final text = value.text.trim();
                final initial = text.isNotEmpty ? text[0].toUpperCase() : '?';
                return CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Text(
                          initial,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        )
                      : null,
                );
              },
            ).animate().scale(delay: 400.ms, curve: Curves.bounceOut),
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              hintText: 'What should we call you?',
            ),
            validator: (v) => v!.isEmpty ? 'Display name is required' : null,
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Secure your account",
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'unique_name',
              prefixText: '@',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Username is required';
              if (!RegExp(r'^[a-z0-9_]{3,30}$').hasMatch(v)) {
                return '3-30 chars, lowercase, numbers, underscores only';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          IntlPhoneField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number (Optional)',
              hintText: '1234567890',
            ),
            initialCountryCode: 'IN', // Default to India based on your example
            onChanged: (phone) {
              _completePhoneNumber = phone.completeNumber;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Final touches ✨",
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(
                  const Duration(days: 365 * 13),
                ), // Default to 13 years old
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(
                        context,
                      ).colorScheme.copyWith(primary: AppColors.m3SeedColor),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                _dobController.text =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
              }
            },
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              hintText: 'Select your birth date',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'DOB is required';
              if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)) {
                return 'Please select a valid date';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _bioController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Bio (Optional)',
              hintText: 'Tell us about yourself...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isDark, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: isLoading ? null : _previousPage,
              child: const Text('Back'),
            )
          else
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      try {
                        await firebase.FirebaseAuth.instance.currentUser
                            ?.delete();
                        if (mounted) context.go('/signup');
                      } on firebase.FirebaseAuthException catch (e) {
                        if (e.code == 'requires-recent-login') {
                          // If it fails due to old login, just sign them out instead so they can log back in or use a different account
                          await ref
                              .read(authControllerProvider.notifier)
                              .signOut();
                          if (mounted) context.go('/signup');
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to cancel onboarding: ${e.message}',
                                ),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to cancel: $e')),
                          );
                        }
                      }
                    },
              child: const Text('Cancel & Restart'),
            ),

          FilledButton(
            onPressed: isLoading ? null : _nextPage,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_currentPage == _totalPages - 1 ? 'Finish' : 'Next'),
          ),
        ],
      ),
    );
  }
}
