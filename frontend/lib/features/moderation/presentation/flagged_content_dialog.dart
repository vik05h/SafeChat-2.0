import 'package:flutter/material.dart';

import '../data/moderation_models.dart';
import 'moderation_highlight.dart';

/// The user's choice from the flagged-content popup.
class FlaggedDialogResult {
  /// True when the user chose to submit the content for human verification.
  final bool submitForReview;

  const FlaggedDialogResult({required this.submitForReview});
}

/// Show the "this can't be uploaded" popup: the flagged words are highlighted,
/// and the user can either go back and edit, or submit for human verification
/// (the safety valve for false positives).
///
/// Returns:
///   * `FlaggedDialogResult(submitForReview: true)` — send for human review,
///   * `FlaggedDialogResult(submitForReview: false)` — go back and edit,
///   * `null` — dismissed (treated as "edit").
Future<FlaggedDialogResult?> showFlaggedContentDialog(
  BuildContext context, {
  required String text,
  required List<ModerationMatch> matches,
  String contentNoun = 'post',
}) {
  return showDialog<FlaggedDialogResult>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return AlertDialog(
        icon: Icon(Icons.report_gmailerrorred, color: scheme.error, size: 36),
        title: const Text("This can't be uploaded"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                matches.isEmpty
                    ? 'Our safety filter flagged your $contentNoun as potentially harmful:'
                    : 'Our safety filter flagged some words in your $contentNoun:',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ModerationHighlightedText(text: text, matches: matches),
              ),
              const SizedBox(height: 16),
              Text(
                'If you think this is a mistake, send it for human review. A '
                'moderator will check it and publish it if it’s fine. You can '
                'track the status in Profile → Appeals.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              ctx,
              const FlaggedDialogResult(submitForReview: false),
            ),
            child: const Text('Edit'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(
              ctx,
              const FlaggedDialogResult(submitForReview: true),
            ),
            icon: const Icon(Icons.gavel),
            label: const Text('Submit for review'),
          ),
        ],
      );
    },
  );
}
