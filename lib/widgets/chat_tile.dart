import 'package:flutter/material.dart';
import '../models/group.dart';

class ChatTile extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;
  const ChatTile({super.key, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: group.imageUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(group.imageUrl!))
          : const CircleAvatar(child: Icon(Icons.group)),
      title: Text(group.name),
      subtitle: Text(group.lastMessage ?? ''),
      trailing: Text(group.lastMessageTime?.substring(0, 10) ?? ''),
      onTap: onTap,
    );
  }
}
