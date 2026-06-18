import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

final followRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return FollowRepository(dio: dio);
});

class FollowRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Dio dio;

  FollowRepository({required this.dio});

  Future<void> followUser(String targetUid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null || currentUid == targetUid) return;

    try {
      await dio.post('/api/v1/users/$targetUid/follow');
    } catch (e) {
      // Ignore or handle
    }
  }

  Future<void> unfollowUser(String targetUid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    try {
      await dio.delete('/api/v1/users/$targetUid/follow');
    } catch (e) {
      // Ignore or handle
    }
  }

  Stream<bool> isFollowing(String targetUid) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return Stream.value(false);

    final followId = '${currentUid}_$targetUid';
    return _firestore.collection('follows').doc(followId).snapshots().map((doc) => doc.exists);
  }

  Stream<int> getFollowersCount(String uid) {
    return _firestore
        .collection('follows')
        .where('followee_uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getFollowingCount(String uid) {
    return _firestore
        .collection('follows')
        .where('follower_uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<List<String>> getFriends(String uid) {
    // A friend is someone who follows you AND you follow them.
    // For simplicity without cloud functions, we can fetch all followers and followings,
    // then find the intersection.
    return _firestore.collection('follows').snapshots().map((snapshot) {
      final followers = <String>{};
      final following = <String>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['followee_uid'] == uid) {
          followers.add(data['follower_uid'] as String);
        }
        if (data['follower_uid'] == uid) {
          following.add(data['followee_uid'] as String);
        }
      }

      return following.intersection(followers).toList();
    });
  }
}
