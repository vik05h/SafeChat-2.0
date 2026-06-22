import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

class ContentStatusView extends ConsumerStatefulWidget {
  const ContentStatusView({super.key});

  @override
  ConsumerState<ContentStatusView> createState() => _ContentStatusViewState();
}

class _ContentStatusViewState extends ConsumerState<ContentStatusView> {
  final _reasonController = TextEditingController();

  Future<void> _submitAppeal(String contentId, String contentType) async {
    final dio = ref.read(dioProvider);
    try {
      await dio.post(
        '/moderation/appeals/$contentId',
        data: {
          'reason': _reasonController.text.trim(),
          'content_type': contentType,
        },
      );
      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appeal submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit appeal: $e')));
      }
    }
  }

  void _showAppealDialog(String contentId, String contentType) {
    _reasonController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request Human Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'If you believe your content was incorrectly flagged by our automated moderation system, you can request a human review. It may take up to 12-24 hours.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for appeal',
                  hintText: 'Please explain why this content is safe...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => _submitAppeal(contentId, contentType),
              child: const Text('Submit Appeal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    // We'll stream posts created by the user that are NOT approved.
    final query = FirebaseFirestore.instance
        .collection('posts')
        .where('author_uid', isEqualTo: uid)
        .where('status', whereIn: ['blocked', 'pending_review'])
        .orderBy('created_at', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Content Status')),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Firestore composite index might be needed if orderBy is used with whereIn.
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'All your content looks great! 🎉\nNo flagged content.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] as String? ?? 'unknown';
              final text = data['text'] ?? data['caption'] ?? 'No text';

              final isBlocked = status == 'blocked';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isBlocked ? Icons.block : Icons.pending_actions,
                            color: isBlocked ? Colors.red : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isBlocked ? 'BLOCKED' : 'UNDER REVIEW',
                            style: TextStyle(
                              color: isBlocked ? Colors.red : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        text,
                        style: const TextStyle(fontSize: 16),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      if (isBlocked)
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () => _showAppealDialog(doc.id, 'post'),
                            icon: const Icon(Icons.gavel),
                            label: const Text('Request Review'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
