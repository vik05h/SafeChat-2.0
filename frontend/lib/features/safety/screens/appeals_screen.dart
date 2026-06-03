import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../app/theme/app_colors.dart';
import '../providers/safety_provider.dart';
import '../models/appeal.dart';

class AppealsScreen extends ConsumerWidget {
  const AppealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appealsAsync = ref.watch(appealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appeals Dashboard'),
      ),
      body: appealsAsync.when(
        data: (appeals) {
          if (appeals.isEmpty) {
            return const Center(child: Text('No active or past appeals.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: appeals.length,
            itemBuilder: (context, index) {
              final appeal = appeals[index];
              return _buildAppealCard(context, appeal);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error loading appeals: $err')),
      ),
    );
  }

  Widget _buildAppealCard(BuildContext context, Appeal appeal) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (appeal.appealStatus) {
      case AppealStatus.approved:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Approved';
        break;
      case AppealStatus.rejected:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
      case AppealStatus.underReview:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_top;
        statusText = 'Under Review';
        break;
      case AppealStatus.submitted:
        statusColor = Colors.blue;
        statusIcon = Icons.send;
        statusText = 'Submitted';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  timeago.format(appeal.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(height: 24),
            const Text('Flagged Content Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.elevatedSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                appeal.contentPreview,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Your Reason:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(appeal.reasonProvided),
            if (appeal.adminNotes != null && appeal.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Admin Response:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(appeal.adminNotes!, style: const TextStyle(color: AppColors.primaryOrange)),
            ],
          ],
        ),
      ),
    );
  }
}
