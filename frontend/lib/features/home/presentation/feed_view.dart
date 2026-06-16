import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeChat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return _buildStoryRing(index == 0);
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildPostCard(context, index);
              },
              childCount: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryRing(bool isAdd) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isAdd 
                ? null 
                : const LinearGradient(colors: [Colors.purple, Colors.orange]),
              color: isAdd ? Colors.grey.withOpacity(0.2) : null,
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${isAdd ? 10 : 20}'),
              child: isAdd ? const Icon(Icons.add, color: Colors.blue) : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(isAdd ? 'Your Story' : 'User_name', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=$index'),
          ),
          title: Text('mock_user_$index', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('New York, NY'),
          trailing: const Icon(Icons.more_vert),
        ),
        // Image
        Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            image: DecorationImage(
              image: NetworkImage('https://picsum.photos/seed/$index/600/600'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Actions
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.favorite_border, size: 28),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline, size: 28),
              const SizedBox(width: 16),
              const Icon(Icons.send_outlined, size: 28),
              const Spacer(),
              const Icon(Icons.bookmark_border, size: 28),
            ],
          ),
        ),
        // Likes & Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1,024 likes', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  children: [
                    TextSpan(text: 'mock_user_$index ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: 'Just testing out the new feed layout! Let me know what you think. #flutter #dev'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text('View all 42 comments', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
