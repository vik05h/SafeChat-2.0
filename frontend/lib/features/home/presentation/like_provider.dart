import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLikedProvider = StreamProvider.family<bool, String>((ref, postId) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('likes')
      .doc(uid)
      .snapshots()
      .map((snap) => snap.exists);
});
