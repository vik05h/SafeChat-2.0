import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../../moderation/services/moderation_service.dart';
import '../../moderation/models/moderation_result.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
    ref.watch(moderationServiceProvider),
  );
});

class ChatService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ModerationService _moderationService;
  
  Timer? _typingDebounce;

  ChatService(this._firestore, this._auth, this._moderationService);

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<List<Conversation>> watchConversations() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .orderBy('last_message_time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Map timestamps correctly for Freezed/fromJson
        if (data['last_message_time'] is Timestamp) {
          data['last_message_time'] = (data['last_message_time'] as Timestamp).toDate().toIso8601String();
        }
        return Conversation.fromJson(data);
      }).toList();
    });
  }

  Stream<List<Message>> watchMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        return Message.fromJson(data);
      }).toList();
    });
  }

  Future<ModerationResult> sendMessage(String conversationId, String text, {bool isWarningBypass = false}) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    try {
      // 1. Moderate content BEFORE writing to Firestore
      final result = await _moderationService.analyzeContent(text);
      
      // If blocked, immediately throw to prevent sending
      if (result.status == ModerationStatus.blocked) {
        // We log it to Firestore for reputation scoring as per requirements
        await _logModerationEvent(uid, text, result);
        return result; 
      }

      // If warning and not bypassing, return to UI to show modal
      if (result.status == ModerationStatus.warning && !isWarningBypass) {
        return result;
      }

      // 2. Safe or Warning (bypassed), proceed to write to Firestore
      final messageRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc();

      final batch = _firestore.batch();

      batch.set(messageRef, {
        'sender_id': uid,
        'text': text,
        'created_at': FieldValue.serverTimestamp(),
        'is_read': false,
        'moderation_status': result.status == ModerationStatus.warning ? 'WARNING' : 'SAFE',
      });

      // Update conversation last message
      final convRef = _firestore.collection('conversations').doc(conversationId);
      batch.update(convRef, {
        'last_message': text,
        'last_message_time': FieldValue.serverTimestamp(),
      });
      // Note: Ideally unread_counts would also be incremented here

      await batch.commit();
      
      FirebaseAnalytics.instance.logEvent(name: 'message_sent');

      if (result.status == ModerationStatus.warning) {
        await _logModerationEvent(uid, text, result);
      }

      return result;
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'Failed to send message');
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> _logModerationEvent(String uid, String content, ModerationResult result) async {
    await _firestore.collection('moderation_logs').add({
      'uid': uid,
      'content': content,
      'status': result.status.name,
      'reason': result.reason,
      'category': result.category,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(String conversationId, String messageId) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update({'is_read': true});
  }

  // Typing Indicator Logic
  // Using 1000ms debounce as per requirements
  void updateTypingStatus(String conversationId, bool isTyping) {
    final uid = currentUserId;
    if (uid == null) return;

    if (_typingDebounce?.isActive ?? false) {
      if (!isTyping) {
        _typingDebounce?.cancel();
        _writeTypingStatus(conversationId, uid, false);
      }
      return;
    }

    if (isTyping) {
      _writeTypingStatus(conversationId, uid, true);
      _typingDebounce = Timer(const Duration(milliseconds: 1000), () {
        // Debounce allows next keystroke to write if 1 second has passed
      });
    }
  }

  Future<void> _writeTypingStatus(String conversationId, String uid, bool isTyping) async {
    final docRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('typing_status')
        .doc(uid);

    if (isTyping) {
      await docRef.set({
        'is_typing': true,
        // Using serverTimestamp to allow cloud function or client to auto-expire after 5 seconds
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.delete();
    }
  }

  Stream<bool> watchTypingStatus(String conversationId, String otherUserId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('typing_status')
        .doc(otherUserId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return false;
      final data = doc.data()!;
      if (data['is_typing'] != true) return false;
      
      // Client-side auto-expire after 5 seconds if cloud function is slow
      if (data['timestamp'] != null) {
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        if (DateTime.now().difference(timestamp).inSeconds > 5) {
          return false;
        }
      }
      return true;
    });
  }
}
