import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../../app/theme/app_colors.dart';
import '../models/report.dart';
import '../providers/report_provider.dart';

class ReportBottomSheet extends ConsumerStatefulWidget {
  final ReportTargetType targetType;
  final String targetId;
  final String contentPreview;

  const ReportBottomSheet({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.contentPreview,
  });

  static void show(BuildContext context, {
    required ReportTargetType targetType,
    required String targetId,
    required String contentPreview,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ReportBottomSheet(
          targetType: targetType,
          targetId: targetId,
          contentPreview: contentPreview,
        ),
      ),
    );
  }

  @override
  ConsumerState<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends ConsumerState<ReportBottomSheet> {
  ReportReason? _selectedReason;
  final _additionalInfoController = TextEditingController();

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_selectedReason == null) return;

    ref.read(reportProvider.notifier).submitReport(
      targetType: widget.targetType,
      targetId: widget.targetId,
      reason: _selectedReason!,
      additionalInfo: _additionalInfoController.text.trim(),
    ).then((_) {
      FirebaseAnalytics.instance.logEvent(name: 'report_submitted');
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. Our safety team will review it shortly.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e'), backgroundColor: AppColors.error),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);
    final isLoading = reportState is AsyncLoading;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Report ${widget.targetType.name}', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Content Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              widget.contentPreview,
              style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Reason for reporting:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReportReason.values.map((reason) {
              final isSelected = _selectedReason == reason;
              return ChoiceChip(
                label: Text(reason.displayName),
                selected: isSelected,
                selectedColor: AppColors.primaryOrange.withOpacity(0.2),
                backgroundColor: AppColors.surface,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedReason = reason);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _additionalInfoController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Additional information (optional)...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedReason != null && !isLoading) ? _submitReport : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
