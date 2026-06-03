import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Guidelines')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shield_rounded, size: 64, color: AppColors.primaryOrange),
            const SizedBox(height: 16),
            Text('SafeChat Community Guidelines', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            _buildRule(1, 'Be Respectful', 'Treat others with respect. Do not engage in harassment, bullying, or hate speech.'),
            _buildRule(2, 'No Illegal Content', 'Do not post content that promotes or facilitates illegal activities.'),
            _buildRule(3, 'No Spam', 'Do not spam the community with unsolicited advertisements or repetitive content.'),
            _buildRule(4, 'Protect Privacy', 'Do not share personal or confidential information without consent.'),
            const SizedBox(height: 32),
            const Text(
              'Violations of these guidelines may result in content removal, account restriction, or permanent bans. Safety is our top priority.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRule(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.2),
            child: Text(number.toString(), style: const TextStyle(fontSize: 12, color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
