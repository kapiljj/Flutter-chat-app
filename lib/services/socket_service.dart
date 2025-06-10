import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/user.dart';
import '../models/message.dart';

class SocketService {
  IO.Socket? socket;
  void connect() {
    print('Connecting socket with token: ${User.currentUser?.authToken}');
    socket = IO.io("http://13.127.170.51:8080", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
      "extraHeaders": {
        "Authorization": "Bearer ${User.currentUser?.authToken}",
      },
    });
    socket?.on('connect', (_) => print('Socket connected'));
    socket?.on('disconnect', (_) => print('Socket disconnected'));
    socket?.connect();
  }

  void joinChat(String groupId) {
    print('Emitting join-chat for group: $groupId');
    socket?.emit("join-chat", {"_id": groupId});
  }

  void leaveChat(String groupId) {
    print('Emitting leave-chat for group: $groupId');
    socket?.emit("leave-chat", {"_id": groupId});
  }

  void onJoinChatAck(Function callback) {
    socket?.on('joined-chat', (_) {
      print('Received joined-chat ack');
      callback();
    });
  }

  void onNewMessage(Function(Message) callback) {
    socket?.on("new-message", (data) {
      callback(Message.fromJson(data));
    });
  }

  void disconnect() {
    socket?.disconnect();
  }

  void onConnect(Function callback) {
    socket?.on('connect', (_) => callback());
  }
}
