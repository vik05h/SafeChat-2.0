import 'package:flutter/material.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.edit_square), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$index'),
            ),
            title: Text('Friend $index', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Active 2h ago'),
            trailing: const Icon(Icons.camera_alt_outlined),
            onTap: () {
              // Navigate to actual chat
            },
          );
        },
      ),
    );
  }
}
