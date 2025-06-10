class Message {
  final String id, groupId, content, senderName;
  final String? fileUrl;
  final String? createdAt;

  Message({
    required this.id,
    required this.groupId,
    required this.content,
    required this.senderName,
    this.fileUrl,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      groupId: json['group'],
      content: json['content'] ?? '',
      senderName: json['sender']?['firstName'] ?? '',
      fileUrl: json['file']?['localFilePath'],
      createdAt: json['createdAt'],
    );
  }
}
