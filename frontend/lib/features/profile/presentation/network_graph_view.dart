import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NetworkGraphView extends StatefulWidget {
  const NetworkGraphView({super.key});

  @override
  State<NetworkGraphView> createState() => _NetworkGraphViewState();
}

class _NetworkGraphViewState extends State<NetworkGraphView> {
  final Graph graph = Graph()..isTree = false;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  Map<String, Node> userNodes = {};
  Map<String, Map<String, dynamic>> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Default config
    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);

    _fetchGraphData();
  }

  Future<void> _fetchGraphData() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    try {
      // For the network graph, we fetch:
      // 1. The current user's friends
      // 2. The friends of those friends (up to 2 degrees)
      
      final Set<String> allUidsToFetch = {currentUid};
      final Set<String> firstDegreeFriends = await _getFriendsOf(currentUid);
      allUidsToFetch.addAll(firstDegreeFriends);

      final List<Map<String, String>> edges = [];
      
      for (final friendId in firstDegreeFriends) {
        edges.add({'from': currentUid, 'to': friendId});
        final secondDegree = await _getFriendsOf(friendId);
        allUidsToFetch.addAll(secondDegree);
        for (final fof in secondDegree) {
          // Add edge but prevent duplicates in undirected graph
          if (!edges.any((e) => (e['from'] == fof && e['to'] == friendId))) {
             edges.add({'from': friendId, 'to': fof});
          }
        }
      }

      // Fetch user data
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: allUidsToFetch.take(10).toList())
          .get();

      for (var doc in usersSnapshot.docs) {
        userData[doc.id] = doc.data();
        userNodes[doc.id] = Node.Id(doc.id);
      }

      // Add nodes and edges to graph
      for (var docId in userData.keys) {
        graph.addNode(userNodes[docId]!);
      }

      for (var edge in edges) {
        if (userNodes.containsKey(edge['from']) && userNodes.containsKey(edge['to'])) {
          graph.addEdge(userNodes[edge['from']]!, userNodes[edge['to']]!, paint: Paint()..color = Colors.blue.withValues(alpha: 0.5)..strokeWidth = 2);
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading graph: $e')));
        setState(() => isLoading = false);
      }
    }
  }

  Future<Set<String>> _getFriendsOf(String uid) async {
    final followingSnapshot = await FirebaseFirestore.instance
        .collection('follows')
        .where('follower_uid', isEqualTo: uid)
        .get();
        
    final followerSnapshot = await FirebaseFirestore.instance
        .collection('follows')
        .where('followee_uid', isEqualTo: uid)
        .get();

    final followingUids = followingSnapshot.docs.map((doc) => doc.data()['followee_uid'] as String).toSet();
    final followerUids = followerSnapshot.docs.map((doc) => doc.data()['follower_uid'] as String).toSet();

    return followingUids.intersection(followerUids);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Network Graph'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.1,
              maxScale: 5.6,
              child: GraphView(
                graph: graph,
                algorithm: FruchtermanReingoldAlgorithm(FruchtermanReingoldConfiguration()), // Force directed graph layout is better for networks
                paint: Paint()
                  ..color = Colors.blue
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  var nodeId = node.key?.value as String?;
                  var data = userData[nodeId] ?? {};
                  return _buildNodeWidget(data);
                },
              ),
            ),
    );
  }

  Widget _buildNodeWidget(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: data['author_photo_url'] != null ? NetworkImage(data['author_photo_url']) : null,
            child: data['author_photo_url'] == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(height: 4),
          Text(
            data['display_name'] ?? 'User',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
