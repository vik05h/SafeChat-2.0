import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../../moderation/models/moderation_result.dart';
import '../../reports/widgets/report_bottom_sheet.dart';
import '../../reports/models/report.dart';
import '../../settings/services/settings_service.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUserName;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    ref.read(chatServiceProvider).updateTypingStatus(widget.conversationId, text.isNotEmpty);
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    
    try {
      final chatService = ref.read(chatServiceProvider);
      // Immediately stop typing indicator when sending
      chatService.updateTypingStatus(widget.conversationId, false);
      
      final result = await chatService.sendMessage(widget.conversationId, text);
      
      setState(() => _isSending = false);

      if (result.status == ModerationStatus.safe) {
        _textController.clear();
      } else if (result.status == ModerationStatus.warning) {
        _showWarningModal(result, text);
      } else if (result.status == ModerationStatus.blocked) {
        _textController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Message blocked: ${result.category}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showWarningModal(ModerationResult result, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Content Warning', style: TextStyle(color: AppColors.warning)),
        content: Text('Your message was flagged for ${result.category}. Send anyway?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Edit'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () async {
              context.pop();
              setState(() => _isSending = true);
              try {
                await ref.read(chatServiceProvider).sendMessage(widget.conversationId, text, isWarningBypass: true);
                _textController.clear();
              } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                 );
              }
              setState(() => _isSending = false);
            },
            child: const Text('Send Anyway'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final currentUserId = ref.watch(chatServiceProvider).currentUserId;
    // We would determine otherUserId properly, mocked for now
    final otherUserId = 'OTHER_USER_ID'; 
    final isTypingAsync = ref.watch(typingStatusProvider({'conversationId': widget.conversationId, 'userId': otherUserId}));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName),
            const Text('Online', style: TextStyle(fontSize: 12, color: AppColors.success)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'report') {
                ReportBottomSheet.show(
                  context,
                  targetType: ReportTargetType.user,
                  targetId: otherUserId,
                  contentPreview: 'Conversation with ${widget.otherUserName}',
                );
              } else if (value == 'mute') {
                try {
                  await ref.read(settingsServiceProvider).muteUser(otherUserId);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User muted.')));
                } catch (e) {}
              } else if (value == 'block') {
                try {
                  await ref.read(settingsServiceProvider).blockUser(otherUserId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked.')));
                    context.pop();
                  }
                } catch (e) {}
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'report', child: Text('Report User')),
              const PopupMenuItem(value: 'mute', child: Text('Mute User')),
              const PopupMenuItem(value: 'block', child: Text('Block User', style: TextStyle(color: AppColors.error))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    
                    // Mark as read if not me
                    if (!isMe && !message.isRead) {
                      ref.read(chatServiceProvider).markAsRead(widget.conversationId, message.id);
                    }

                    return MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
          if (isTypingAsync.value ?? false)
            const Align(
              alignment: Alignment.centerLeft,
              child: TypingIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onChanged: _onTextChanged,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primaryOrange),
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
