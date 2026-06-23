import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../moderation/data/moderation_models.dart';
import '../../moderation/presentation/moderation_highlight.dart';

/// The current user's content that went through (or is awaiting) human
/// verification — backed by GET /api/v1/moderation/appeals.
final myAppealsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/api/v1/moderation/appeals');
  final data = response.data;
  final items = data is Map ? (data['data']?['items'] as List?) : null;
  return (items ?? const []).whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
});

class ContentStatusView extends ConsumerWidget {
  const ContentStatusView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appealsAsync = ref.watch(myAppealsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Content Status / Appeals')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myAppealsProvider);
          await ref.read(myAppealsProvider.future);
        },
        child: appealsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text("Couldn't load your content status.\n$e", textAlign: TextAlign.center),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'All your content looks great! 🎉\nNothing is awaiting review.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, i) => _AppealCard(item: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _AppealCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _AppealCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final status = item['status'] as String? ?? 'pending_review';
    final text = item['text'] as String? ?? '';
    final reason = item['reason'] as String?;
    final contentType = item['content_type'] as String? ?? 'content';
    final matches = ((item['matches'] as List?) ?? const [])
        .whereType<Map>()
        .map((m) => ModerationMatch.fromJson(m.cast<String, dynamic>()))
        .toList();

    final scheme = Theme.of(context).colorScheme;
    final IconData icon;
    final Color color;
    final String label;
    switch (status) {
      case 'approved':
        icon = Icons.check_circle;
        color = Colors.green;
        label = 'APPROVED';
      case 'rejected':
        icon = Icons.block;
        color = scheme.error;
        label = 'REJECTED';
      default:
        icon = Icons.pending_actions;
        color = Colors.orange;
        label = 'UNDER REVIEW';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: Text(contentType),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ModerationHighlightedText(text: text, matches: matches),
            if (status == 'rejected' && reason != null && reason.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Reason: $reason', style: TextStyle(color: scheme.onErrorContainer)),
              ),
            ],
            if (status == 'pending_review') ...[
              const SizedBox(height: 8),
              Text(
                "A moderator is reviewing this. You'll be notified once it's decided.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
