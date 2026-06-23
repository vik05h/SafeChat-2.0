import 'dart:convert';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'public_profile_view.dart';

// Relationship of a node to the current user. Drives ring placement + colour.
enum _Rel { self, mutual, following, follower }

Color _relColor(_Rel rel, BuildContext context) {
  switch (rel) {
    case _Rel.self:
      return Theme.of(context).colorScheme.primary;
    case _Rel.mutual:
      return Colors.amber;
    case _Rel.following:
      return Colors.green;
    case _Rel.follower:
      return Colors.blue;
  }
}

// Ring index by relationship. Self is the centre (0).
int _relRing(_Rel rel) {
  switch (rel) {
    case _Rel.self:
      return 0;
    case _Rel.mutual:
      return 1;
    case _Rel.following:
      return 2;
    case _Rel.follower:
      return 3;
  }
}

class _GraphNode {
  final String uid;
  final String name;
  final String username;
  final String photoUrl;
  final _Rel rel;
  String? parentUid; // spanning-tree parent ("introduced via")
  Offset pos = Offset.zero; // filled in at layout time

  _GraphNode({
    required this.uid,
    required this.name,
    required this.username,
    required this.photoUrl,
    required this.rel,
    this.parentUid,
  });

  Map<String, dynamic> toCache() => {
    'uid': uid,
    'name': name,
    'username': username,
    'photo': photoUrl,
    'rel': rel.index,
    'parent': parentUid,
  };

  factory _GraphNode.fromCache(Map<String, dynamic> m) => _GraphNode(
    uid: m['uid'] as String,
    name: m['name'] as String? ?? 'User',
    username: m['username'] as String? ?? '',
    photoUrl: m['photo'] as String? ?? '',
    rel: _Rel.values[m['rel'] as int? ?? 0],
    parentUid: m['parent'] as String?,
  );
}

class _GraphData {
  final List<_GraphNode> nodes;
  const _GraphData(this.nodes);
}

class NetworkGraphView extends StatefulWidget {
  const NetworkGraphView({super.key});

  @override
  State<NetworkGraphView> createState() => _NetworkGraphViewState();
}

class _NetworkGraphViewState extends State<NetworkGraphView> {
  // Cap total fetched nodes so the radial render + Firestore reads stay bounded.
  // Prioritised mutual > following > follower when over the cap.
  static const int _maxNodes = 90;
  // ≤ this many nodes → draw spanning-tree edges; above it, rely on ring colour.
  static const int _edgeThreshold = 50;
  static const Duration _cacheTtl = Duration(minutes: 15);
  // Firestore whereIn caps at 10 comparison values — chunk larger sets.
  static const int _whereInChunk = 10;

  String? _currentUid;
  bool _isLoading = true;
  String? _error;

  _GraphData _network = const _GraphData([]);
  _GraphData _friends = const _GraphData([]);

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _cacheKey(String uid) => 'network_graph_$uid';

  Future<void> _load({bool forceRefresh = false}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _error = 'Not signed in.';
      });
      return;
    }
    _currentUid = uid;

    if (!forceRefresh && _loadFromCache(uid)) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final nodes = await _fetchAndBuild(uid);
      _applyGraphs(uid, nodes);
      _writeCache(uid, nodes);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  bool _loadFromCache(String uid) {
    try {
      final raw = Hive.box('settings').get(_cacheKey(uid)) as String?;
      if (raw == null) return false;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final ts = DateTime.fromMillisecondsSinceEpoch(decoded['ts'] as int);
      if (DateTime.now().difference(ts) > _cacheTtl) return false;

      final nodes = (decoded['nodes'] as List)
          .map((e) => _GraphNode.fromCache(e as Map<String, dynamic>))
          .toList();
      _applyGraphs(uid, nodes);
      return true;
    } catch (_) {
      return false; // Corrupt/old cache → refetch.
    }
  }

  void _writeCache(String uid, List<_GraphNode> nodes) {
    try {
      Hive.box('settings').put(
        _cacheKey(uid),
        jsonEncode({
          'ts': DateTime.now().millisecondsSinceEpoch,
          'nodes': nodes.map((n) => n.toCache()).toList(),
        }),
      );
    } catch (_) {
      // Caching is best-effort; ignore write failures.
    }
  }

  // Splits the network + friends graphs out of the flat, parented node list.
  void _applyGraphs(String uid, List<_GraphNode> nodes) {
    _network = _GraphData(nodes);

    // Friends = self + mutuals, each parented directly to self (gold star).
    final self = nodes.firstWhere(
      (n) => n.uid == uid,
      orElse: () => _GraphNode(
        uid: uid,
        name: 'You',
        username: '',
        photoUrl: '',
        rel: _Rel.self,
      ),
    );
    final friendNodes = <_GraphNode>[
      _GraphNode(
        uid: self.uid,
        name: self.name,
        username: self.username,
        photoUrl: self.photoUrl,
        rel: _Rel.self,
      ),
      for (final n in nodes.where((n) => n.rel == _Rel.mutual))
        _GraphNode(
          uid: n.uid,
          name: n.name,
          username: n.username,
          photoUrl: n.photoUrl,
          rel: _Rel.mutual,
          parentUid: uid,
        ),
    ];
    _friends = _GraphData(friendNodes);
  }

  Future<List<_GraphNode>> _fetchAndBuild(String uid) async {
    final fs = FirebaseFirestore.instance;

    // 1+2. Who I follow, and who follows me.
    final results = await Future.wait([
      fs.collection('follows').where('follower_uid', isEqualTo: uid).get(),
      fs.collection('follows').where('followee_uid', isEqualTo: uid).get(),
    ]);
    final followingUids = results[0].docs
        .map((d) => d.data()['followee_uid'] as String)
        .toSet();
    final followerUids = results[1].docs
        .map((d) => d.data()['follower_uid'] as String)
        .toSet();
    final mutualUids = followingUids.intersection(followerUids);

    _Rel relOf(String id) {
      if (id == uid) return _Rel.self;
      final f = followingUids.contains(id), b = followerUids.contains(id);
      if (f && b) return _Rel.mutual;
      if (f) return _Rel.following;
      return _Rel.follower;
    }

    // 3. Prioritise mutual > following-only > follower-only within the cap.
    final followingOnly = followingUids.difference(mutualUids);
    final followerOnly = followerUids.difference(mutualUids);
    final ordered = <String>[
      ...mutualUids,
      ...followingOnly,
      ...followerOnly,
    ].take(_maxNodes - 1).toList();
    final allUids = <String>[uid, ...ordered];
    final allSet = allUids.toSet();

    // 4. Fetch user docs (chunked whereIn, parallel).
    final userSnaps = await Future.wait([
      for (final chunk in _chunk(allUids, _whereInChunk))
        fs
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get(),
    ]);
    final nodeByUid = <String, _GraphNode>{};
    for (final snap in userSnaps) {
      for (final doc in snap.docs) {
        final d = doc.data();
        nodeByUid[doc.id] = _GraphNode(
          uid: doc.id,
          name: d['display_name'] as String? ?? 'User',
          username: d['username'] as String? ?? '',
          photoUrl: d['photo_url'] as String? ?? '',
          rel: relOf(doc.id),
        );
      }
    }
    if (nodeByUid.isEmpty) return [];

    // 5. Inter-node follow edges (chunked). Keep only edges fully inside our set.
    final edgeSnaps = await Future.wait([
      for (final chunk in _chunk(allUids, _whereInChunk))
        fs.collection('follows').where('follower_uid', whereIn: chunk).get(),
    ]);
    final undirected = <String, Set<String>>{};
    void link(String a, String b) {
      undirected.putIfAbsent(a, () => {}).add(b);
      undirected.putIfAbsent(b, () => {}).add(a);
    }

    for (final snap in edgeSnaps) {
      for (final doc in snap.docs) {
        final a = doc.data()['follower_uid'] as String?;
        final b = doc.data()['followee_uid'] as String?;
        if (a != null &&
            b != null &&
            allSet.contains(a) &&
            allSet.contains(b)) {
          link(a, b);
        }
      }
    }
    // Every fetched node is a direct follower/followee of self → ensure self link.
    for (final id in nodeByUid.keys) {
      if (id != uid) link(uid, id);
    }

    // 6. DFS spanning tree from self → assigns one parent per node, turning
    // triangles into chains (A follows B & C, B follows C ⇒ A→B→C).
    _buildSpanningTree(uid, nodeByUid, undirected, relOf);

    return nodeByUid.values.toList();
  }

  void _buildSpanningTree(
    String rootUid,
    Map<String, _GraphNode> nodeByUid,
    Map<String, Set<String>> undirected,
    _Rel Function(String) relOf,
  ) {
    final visited = <String>{rootUid};

    // Visit neighbours mutual → following → follower, then by uid, so closer
    // relationships attach nearer the root and the layout stays deterministic.
    int relRank(String id) => _relRing(relOf(id));
    List<String> sortedNeighbours(String u) {
      final ns =
          (undirected[u] ?? const <String>{})
              .where(nodeByUid.containsKey)
              .toList()
            ..sort((a, b) {
              final r = relRank(a).compareTo(relRank(b));
              return r != 0 ? r : a.compareTo(b);
            });
      return ns;
    }

    // Recursive DFS: recurse fully into each neighbour before moving on, so a
    // node reachable via an intermediate (B claims C) is preferred over the
    // direct root→C edge — turning triangles into chains. Depth ≤ node count
    // (capped at _maxNodes), so the call stack is bounded and safe.
    void dfs(String u) {
      for (final v in sortedNeighbours(u)) {
        if (visited.add(v)) {
          nodeByUid[v]!.parentUid = u;
          dfs(v);
        }
      }
    }

    dfs(rootUid);
    // Any node not reached (shouldn't happen) attaches to root.
    for (final entry in nodeByUid.entries) {
      if (entry.key != rootUid && entry.value.parentUid == null) {
        entry.value.parentUid = rootUid;
      }
    }
  }

  List<List<T>> _chunk<T>(List<T> list, int size) {
    final out = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      out.add(list.sublist(i, math.min(i + size, list.length)));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Network'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _load(forceRefresh: true);
                    },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Network'),
              Tab(text: 'Friends'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _ErrorState(
                message: _error!,
                onRetry: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _load(forceRefresh: true);
                },
              )
            : Column(
                children: [
                  const _Legend(),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _GraphCanvas(
                          key: const ValueKey('network'),
                          data: _network,
                          selfUid: _currentUid,
                          showEdges: _network.nodes.length <= _edgeThreshold,
                          emptyMessage: 'No network connections yet.',
                        ),
                        _GraphCanvas(
                          key: const ValueKey('friends'),
                          data: _friends,
                          selfUid: _currentUid,
                          showEdges: _friends.nodes.length <= _edgeThreshold,
                          emptyMessage: 'No mutual friends yet.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Radial, pan/zoom canvas. Positions nodes on relationship rings whose radius
// grows with node count, so circles can never overlap regardless of how many.
class _GraphCanvas extends StatefulWidget {
  final _GraphData data;
  final String? selfUid;
  final bool showEdges;
  final String emptyMessage;

  const _GraphCanvas({
    super.key,
    required this.data,
    required this.selfUid,
    required this.showEdges,
    required this.emptyMessage,
  });

  @override
  State<_GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<_GraphCanvas> {
  static const double _baseRadius = 140;
  static const double _ringGap = 130;
  static const double _nodeSpacing =
      104; // min centre-to-centre, prevents overlap
  static const double _margin = 110;
  static const double _nodeBox = 84; // node widget footprint (for Positioned)

  final TransformationController _controller = TransformationController();
  bool _didCenter = false;
  double _canvasSize = 600;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _layout() {
    final nodes = widget.data.nodes;
    if (nodes.isEmpty) return;

    // Group by ring; compute each ring's radius from its node count.
    final byRing = <int, List<_GraphNode>>{};
    for (final n in nodes) {
      byRing.putIfAbsent(_relRing(n.rel), () => []).add(n);
    }
    for (final list in byRing.values) {
      list.sort((a, b) => a.uid.compareTo(b.uid)); // deterministic angle order
    }

    final radii = <int, double>{};
    double prev = 0;
    for (final ring in [1, 2, 3]) {
      final count = byRing[ring]?.length ?? 0;
      if (count == 0) continue;
      final needed = _nodeSpacing * count / (2 * math.pi);
      final base = math.max(_baseRadius * ring, prev + _ringGap);
      radii[ring] = math.max(base, needed);
      prev = radii[ring]!;
    }

    final radiusMax = radii.values.isEmpty
        ? _baseRadius
        : radii.values.reduce(math.max);
    _canvasSize = 2 * (radiusMax + _margin);
    final center = Offset(_canvasSize / 2, _canvasSize / 2);

    for (final n in nodes) {
      if (n.rel == _Rel.self) {
        n.pos = center;
        continue;
      }
      final ring = _relRing(n.rel);
      final ringNodes = byRing[ring]!;
      final i = ringNodes.indexOf(n);
      final k = ringNodes.length;
      // Per-ring angular offset so rings don't align into radial spokes.
      final offset = ring * 0.6;
      final angle = (2 * math.pi * i / k) + offset;
      final r = radii[ring]!;
      n.pos = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
    }
  }

  void _centerOnce(BoxConstraints constraints) {
    if (_didCenter) return;
    _didCenter = true;
    final viewport = constraints.biggest;
    final scale = (viewport.shortestSide / _canvasSize)
        .clamp(0.3, 1.0)
        .toDouble();
    final tx = viewport.width / 2 - (_canvasSize / 2) * scale;
    final ty = viewport.height / 2 - (_canvasSize / 2) * scale;
    // Scale + translate matrix built directly (avoids deprecated translate/scale).
    _controller.value = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(2, 2, scale)
      ..setEntry(0, 3, tx)
      ..setEntry(1, 3, ty);
  }

  @override
  Widget build(BuildContext context) {
    final nodes = widget.data.nodes;
    if (nodes.length <= 1) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hub_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              widget.emptyMessage,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    _layout();
    final posByUid = {for (final n in nodes) n.uid: n.pos};

    final edges = <_Edge>[];
    if (widget.showEdges) {
      for (final n in nodes) {
        final p = n.parentUid;
        if (p != null && posByUid.containsKey(p)) {
          edges.add(_Edge(posByUid[p]!, n.pos, _relColor(n.rel, context)));
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _centerOnce(constraints);
        });
        return InteractiveViewer(
          transformationController: _controller,
          constrained: false,
          minScale: 0.3,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(400),
          child: SizedBox(
            width: _canvasSize,
            height: _canvasSize,
            child: Stack(
              children: [
                if (edges.isNotEmpty)
                  Positioned.fill(
                    child: CustomPaint(painter: _EdgePainter(edges)),
                  ),
                for (final n in nodes)
                  Positioned(
                    left: n.pos.dx - _nodeBox / 2,
                    top: n.pos.dy - _nodeBox / 2,
                    width: _nodeBox,
                    child: _NodeWidget(
                      node: n,
                      isSelf: n.uid == widget.selfUid,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Edge {
  final Offset from;
  final Offset to;
  final Color color;
  const _Edge(this.from, this.to, this.color);
}

class _EdgePainter extends CustomPainter {
  final List<_Edge> edges;
  const _EdgePainter(this.edges);

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in edges) {
      final paint = Paint()
        ..color = e.color.withValues(alpha: 0.55)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(e.from, e.to, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) => old.edges != edges;
}

class _NodeWidget extends StatelessWidget {
  final _GraphNode node;
  final bool isSelf;

  const _NodeWidget({required this.node, required this.isSelf});

  void _openProfile(BuildContext context) {
    if (isSelf) return; // tapping yourself does nothing
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PublicProfileView(uid: node.uid, username: node.username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = isSelf ? 30.0 : 24.0;
    final color = _relColor(isSelf ? _Rel.self : node.rel, context);

    return GestureDetector(
      onTap: () => _openProfile(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: isSelf ? 3 : 2.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: isSelf ? 14 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: ClipOval(
                child: node.photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: node.photoUrl,
                        width: radius * 2,
                        height: radius * 2,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) =>
                            Icon(Icons.person, size: radius),
                      )
                    : Icon(Icons.person, size: radius),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 84,
            child: Text(
              node.name,
              style: TextStyle(
                fontWeight: isSelf ? FontWeight.bold : FontWeight.w500,
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
