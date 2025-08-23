class ChatHistory {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastModified;
  final int messageCount;
  final String? petId;
  final String? petName;
  final String? lastMessage;

  ChatHistory({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastModified,
    required this.messageCount,
    this.petId,
    this.petName,
    this.lastMessage,
  });

  factory ChatHistory.fromMap(Map<String, dynamic> map, String id) {
    return ChatHistory(
      id: id,
      title: map['title'] ?? 'Yeni Sohbet',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastModified: DateTime.fromMillisecondsSinceEpoch(map['lastModified'] ?? 0),
      messageCount: map['messageCount'] ?? 0,
      petId: map['petId'],
      petName: map['petName'],
      lastMessage: map['lastMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastModified': lastModified.millisecondsSinceEpoch,
      'messageCount': messageCount,
      'petId': petId,
      'petName': petName,
      'lastMessage': lastMessage,
    };
  }

  ChatHistory copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastModified,
    int? messageCount,
    String? petId,
    String? petName,
    String? lastMessage,
  }) {
    return ChatHistory(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      messageCount: messageCount ?? this.messageCount,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
