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
  // We use two separate graphs
  final Graph networkGraph = Graph()..isTree = false;
  final Graph friendsGraph = Graph()..isTree = false;
  
  // Algorithms
  late FruchtermanReingoldAlgorithm networkAlgo;
  late FruchtermanReingoldAlgorithm friendsAlgo;

  Map<String, Node> userNodes = {};
  Map<String, Map<String, dynamic>> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // High repulsion force to avoid overlapping
    final config = FruchtermanReingoldConfiguration()
      ..repulsionRate = 0.8
      ..iterations = 1000;
      
    networkAlgo = FruchtermanReingoldAlgorithm(config);
    friendsAlgo = FruchtermanReingoldAlgorithm(config);

    _fetchGraphData();
  }

  Future<void> _fetchGraphData() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    try {
      final followingSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .where('follower_uid', isEqualTo: currentUid)
          .get();
          
      final followerSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .where('followee_uid', isEqualTo: currentUid)
          .get();

      final followingUids = followingSnapshot.docs.map((doc) => doc.data()['followee_uid'] as String).toSet();
      final followerUids = followerSnapshot.docs.map((doc) => doc.data()['follower_uid'] as String).toSet();
      
      final mutualFriends = followingUids.intersection(followerUids);
      final allUidsToFetch = {currentUid, ...followingUids, ...followerUids};

      // Fetch user data
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: allUidsToFetch.take(10).toList()) // limit to 10 for simplicity in this phase
          .get();

      for (var doc in usersSnapshot.docs) {
        userData[doc.id] = doc.data();
        userNodes[doc.id] = Node.Id(doc.id);
      }

      // Populate Network Graph (Followers & Following)
      for (var docId in userData.keys) {
        networkGraph.addNode(userNodes[docId]!);
      }
      
      // Followers (Blue line from them to current user)
      for (var uid in followerUids) {
        if (userNodes.containsKey(uid) && userNodes.containsKey(currentUid)) {
          networkGraph.addEdge(userNodes[uid]!, userNodes[currentUid]!, paint: Paint()..color = Colors.blue..strokeWidth = 2);
        }
      }
      // Following (Green line from current user to them)
      for (var uid in followingUids) {
        if (userNodes.containsKey(uid) && userNodes.containsKey(currentUid)) {
          networkGraph.addEdge(userNodes[currentUid]!, userNodes[uid]!, paint: Paint()..color = Colors.green..strokeWidth = 2);
        }
      }

      // Populate Friends Graph (Mutuals only)
      friendsGraph.addNode(userNodes[currentUid]!);
      for (var uid in mutualFriends) {
        if (userNodes.containsKey(uid) && userNodes.containsKey(currentUid)) {
          friendsGraph.addNode(userNodes[uid]!);
          // Gold line for mutual friends
          friendsGraph.addEdge(userNodes[currentUid]!, userNodes[uid]!, paint: Paint()..color = Colors.amber..strokeWidth = 3);
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Network Graph'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Network'),
              Tab(text: 'Friends'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                physics: const NeverScrollableScrollPhysics(), // prevent interfering with graph pan
                children: [
                  _buildGraphCanvas(networkGraph, networkAlgo, 'Not enough network connections found.'),
                  _buildGraphCanvas(friendsGraph, friendsAlgo, 'No mutual friends found.'),
                ],
              ),
      ),
    );
  }

  Widget _buildGraphCanvas(Graph g, Algorithm algo, String emptyMessage) {
    if (g.nodes.length <= 1) {
      return Center(child: Text(emptyMessage));
    }
    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(500),
      minScale: 0.1,
      maxScale: 5.6,
      child: GraphView(
        graph: g,
        algorithm: algo,
        paint: Paint()
          ..color = Colors.grey
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
        builder: (Node node) {
          var nodeId = node.key?.value as String?;
          var data = userData[nodeId] ?? {};
          return _buildNodeWidget(data);
        },
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
            backgroundImage: data['photo_url'] != null ? NetworkImage(data['photo_url']) : null,
            child: data['photo_url'] == null ? const Icon(Icons.person) : null,
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
