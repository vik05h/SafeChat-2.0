import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../moderation/data/moderation_models.dart';
import '../../moderation/presentation/flagged_content_dialog.dart';

class ChatDetailView extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUid;
  final String otherUserName;

  const ChatDetailView({
    super.key,
    required this.chatId,
    required this.otherUid,
    required this.otherUserName,
  });

  @override
  ConsumerState<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends ConsumerState<ChatDetailView> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final dio = ref.read(dioProvider);

    Future<Response<dynamic>> post({required bool submitForReview}) {
      // All writes go through the backend so moderation runs.
      return dio.post(
        '/api/v1/chats/${widget.chatId}/messages',
        data: {'text': text, 'submit_for_review': submitForReview},
        options: Options(
          validateStatus: (s) =>
              s != null && ((s >= 200 && s < 300) || s == 422),
        ),
      );
    }

    try {
      final response = await post(submitForReview: false);
      if (response.statusCode != 422) {
        _messageController.clear(); // delivered — the stream will show it
        return;
      }

      final flagged = flaggedFromEnvelope(response.data);
      if (!mounted || flagged == null) return;
      final result = await showFlaggedContentDialog(
        context,
        text: text,
        matches: flagged.matches,
        contentNoun: 'message',
      );
      if (result == null || !result.submitForReview) return;

      await post(submitForReview: true);
      _messageController.clear();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            '📋 Message sent for review. Track it in Profile → Appeals.',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['sender_uid'] == uid;
                    final text = data['text'] as String? ?? '';
                    final status = data['status'] as String? ?? 'approved';

                    // The recipient only ever sees delivered (approved) messages.
                    // The sender additionally sees their own pending/rejected ones.
                    if (!isMe && status != 'approved') {
                      return const SizedBox.shrink();
                    }

                    return _MessageBubble(
                      text: text,
                      isMe: isMe,
                      status: status,
                      rejectionReason: data['rejection_reason'] as String?,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String status;
  final String? rejectionReason;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.status,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPending = status == 'pending_review';
    final isRejected = status == 'rejected';

    final Color bubbleColor;
    if (isRejected) {
      bubbleColor = scheme.errorContainer;
    } else if (isPending) {
      bubbleColor = scheme.surfaceContainerHighest;
    } else if (isMe) {
      bubbleColor = scheme.primaryContainer;
    } else {
      bubbleColor = scheme.surfaceContainerHighest;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
            bottomLeft: !isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            if (isPending)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pending_actions,
                      size: 12,
                      color: scheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Under review',
                      style: TextStyle(fontSize: 10, color: scheme.outline),
                    ),
                  ],
                ),
              ),
            if (isRejected) ...[
              const SizedBox(height: 4),
              Text(
                'Blocked${rejectionReason != null && rejectionReason!.isNotEmpty ? ': $rejectionReason' : ''}',
                style: TextStyle(fontSize: 10, color: scheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
