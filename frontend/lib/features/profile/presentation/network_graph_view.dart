import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class NetworkGraphView extends StatefulWidget {
  const NetworkGraphView({super.key});

  @override
  State<NetworkGraphView> createState() => _NetworkGraphViewState();
}

class _NetworkGraphViewState extends State<NetworkGraphView> {
  final Graph _networkGraph = Graph()..isTree = false;
  final Graph _friendsGraph = Graph()..isTree = false;

  late final FruchtermanReingoldAlgorithm _networkAlgo;
  late final FruchtermanReingoldAlgorithm _friendsAlgo;

  final Map<String, Node> _nodes = {};
  final Map<String, Map<String, dynamic>> _userData = {};
  String? _currentUid;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // repulsionRate 0.8→5.0: 6× more separation so nodes don't pile up.
    // iterations 1000→300: sufficient for convergence without blocking the UI.
    final config = FruchtermanReingoldConfiguration()
      ..repulsionRate = 5.0
      ..iterations = 300;
    _networkAlgo = FruchtermanReingoldAlgorithm(config);
    _friendsAlgo = FruchtermanReingoldAlgorithm(config);

    _fetchGraphData();
  }

  Future<void> _fetchGraphData() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;
    _currentUid = currentUid;

    try {
      // Parallel Firestore queries instead of sequential.
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('follows')
            .where('follower_uid', isEqualTo: currentUid)
            .get(),
        FirebaseFirestore.instance
            .collection('follows')
            .where('followee_uid', isEqualTo: currentUid)
            .get(),
      ]);

      final followingUids = results[0].docs
          .map((d) => d.data()['followee_uid'] as String)
          .toSet();
      final followerUids = results[1].docs
          .map((d) => d.data()['follower_uid'] as String)
          .toSet();
      final mutualFriends = followingUids.intersection(followerUids);

      // Always include current user; fill the remaining 9 slots with others.
      final otherUids = {...followingUids, ...followerUids}..remove(currentUid);
      final uidBatch = [currentUid, ...otherUids.take(9)];

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: uidBatch)
          .get();

      for (final doc in usersSnapshot.docs) {
        _userData[doc.id] = doc.data();
        _nodes[doc.id] = Node.Id(doc.id);
      }

      // Network graph: all fetched users; blue edges = follower, green = following.
      for (final id in _userData.keys) {
        _networkGraph.addNode(_nodes[id]!);
      }
      for (final uid in followerUids) {
        if (_nodes.containsKey(uid) && _nodes.containsKey(currentUid)) {
          _networkGraph.addEdge(
            _nodes[uid]!, _nodes[currentUid]!,
            paint: Paint()..color = Colors.blue..strokeWidth = 2,
          );
        }
      }
      for (final uid in followingUids) {
        if (_nodes.containsKey(uid) && _nodes.containsKey(currentUid)) {
          _networkGraph.addEdge(
            _nodes[currentUid]!, _nodes[uid]!,
            paint: Paint()..color = Colors.green..strokeWidth = 2,
          );
        }
      }

      // Friends graph: mutual follows only (gold).
      if (_nodes.containsKey(currentUid)) {
        _friendsGraph.addNode(_nodes[currentUid]!);
      }
      for (final uid in mutualFriends) {
        if (_nodes.containsKey(uid) && _nodes.containsKey(currentUid)) {
          _friendsGraph.addNode(_nodes[uid]!);
          _friendsGraph.addEdge(
            _nodes[currentUid]!, _nodes[uid]!,
            paint: Paint()..color = Colors.amber..strokeWidth = 3,
          );
        }
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Network'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Network'), Tab(text: 'Friends')],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off_rounded, size: 48, color: Theme.of(context).colorScheme.error),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              setState(() { _isLoading = true; _error = null; });
                              _fetchGraphData();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      const _Legend(),
                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildCanvas(_networkGraph, _networkAlgo, 'No network connections yet.'),
                            _buildCanvas(_friendsGraph, _friendsAlgo, 'No mutual friends yet.'),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCanvas(Graph g, Algorithm algo, String emptyMessage) {
    if (g.nodes.length <= 1) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hub_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(300),
      minScale: 0.2,
      maxScale: 4.0,
      child: GraphView(
        graph: g,
        algorithm: algo,
        paint: Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
        builder: (Node node) {
          final nodeId = node.key?.value as String?;
          return _NodeWidget(
            data: _userData[nodeId] ?? {},
            isSelf: nodeId == _currentUid,
          );
        },
      ),
    );
  }
}

// Extracted as a separate StatelessWidget so the graph layout engine cannot
// trigger unnecessary rebuilds of the image/text subtree.
class _NodeWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isSelf;

  const _NodeWidget({required this.data, required this.isSelf});

  @override
  Widget build(BuildContext context) {
    final photoUrl = data['photo_url'] as String?;
    final displayName = data['display_name'] as String? ?? 'User';
    final avatarRadius = isSelf ? 28.0 : 22.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isSelf
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: isSelf
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: isSelf ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: ClipOval(
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: avatarRadius * 2,
                      height: avatarRadius * 2,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Icon(Icons.person, size: avatarRadius),
                    )
                  : Icon(Icons.person, size: avatarRadius),
            ),
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              displayName,
              style: TextStyle(
                fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _LegendItem(color: Colors.green, label: 'Following'),
          SizedBox(width: 20),
          _LegendItem(color: Colors.blue, label: 'Follower'),
          SizedBox(width: 20),
          _LegendItem(color: Colors.amber, label: 'Mutual'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
