import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

final conversationsProvider = StreamProvider.autoDispose<List<Conversation>>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.watchConversations();
});

final messagesProvider = StreamProvider.autoDispose.family<List<Message>, String>((ref, conversationId) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.watchMessages(conversationId);
});

final typingStatusProvider = StreamProvider.autoDispose.family<bool, Map<String, String>>((ref, args) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.watchTypingStatus(args['conversationId']!, args['userId']!);
});
