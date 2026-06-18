import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/data/feed_post_model.dart';

final userPostsProvider = StreamProvider.family<List<FeedPost>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('posts')
      .where('author_uid', isEqualTo: uid)
      .where('status', isEqualTo: 'approved')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => FeedPost.fromFirestore(doc.data(), doc.id))
          .toList());
});
