class Group {
  final String id, name, description;
  final String? imageUrl;
  final String? lastMessage;
  final String? lastMessageTime;

  Group({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['file']?['localFilePath'],
      lastMessage: json['latestMessage']?['content'],
      lastMessageTime: json['latestMessage']?['createdAt'],
    );
  }
}
