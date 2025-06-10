import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/message.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import '../widgets/message_bubble.dart';
import '../models/user.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Group group;
  List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  late SocketService socketService;
  bool _socketConnected = false;
  bool _joinedGroup = false;

  @override
  void initState() {
    super.initState();
    socketService = SocketService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    group = ModalRoute.of(context)!.settings.arguments as Group;
    print('Connecting socket with token: ${User.currentUser?.authToken}');
    socketService.connect();

    socketService.onConnect(() {
      if (!mounted) return;
      setState(() {
        _socketConnected = true;
      });
      print('Socket connected, joining group: ${group.id}');
      socketService.joinChat(group.id);
    });

    // Wait for join-chat ack, or fallback to a delay if not received
    bool acked = false;
    socketService.onJoinChatAck(() {
      acked = true;
      if (!mounted) return;
      setState(() {
        _joinedGroup = true;
      });
      print('Join-chat acknowledged for group: ${group.id}');
    });

    // Fallback: if no ack in 1 second, allow sending anyway
    Future.delayed(const Duration(seconds: 1), () {
      if (!acked && mounted) {
        setState(() {
          _joinedGroup = true;
        });
        print('No join-chat ack received, enabling send after delay.');
      }
    });

    socketService.onNewMessage((msg) {
      if (msg.groupId == group.id && mounted) {
        setState(() => messages.add(msg));
      }
    });
  }

  @override
  void dispose() {
    socketService.leaveChat(group.id);
    socketService.disconnect();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final tempMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: group.id,
      content: text,
      senderName: User.currentUser?.firstName ?? 'You',
      fileUrl: null,
      createdAt: DateTime.now().toIso8601String(),
    );
    setState(() {
      messages.add(tempMessage);
    });
    _controller.clear();
    final api = ApiService();
    print('Attempting to send message to group: ${group.id}');
    print('Token used for API: ${User.currentUser?.authToken}');
    final sent = await api.sendMessage(group.id, text);
    print('Send message result: $sent');
    if (!mounted) return;
    // Optionally, update UI based on send result
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.group, color: Colors.white),
            const SizedBox(width: 8),
            Text(group.name),
          ],
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.blueGrey[50],
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) =>
                    MessageBubble(message: messages[index]),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: (_socketConnected && _joinedGroup)
                        ? Colors.blueAccent
                        : Colors.grey,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: (_socketConnected && _joinedGroup)
                          ? _sendMessage
                          : null,
                    ),
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
