import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/group.dart';
import '../widgets/chat_tile.dart';
import '../models/user.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Group> groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  void _fetchGroups() async {
    final api = ApiService();
    final result = await api.getGroupList();
    setState(() {
      groups = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (User.currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  User.currentUser!.firstName.isNotEmpty
                      ? User.currentUser!.firstName
                      : "User",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        color: Colors.blueGrey[50],
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                itemCount: groups.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ChatTile(
                    group: groups[index],
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: groups[index],
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
