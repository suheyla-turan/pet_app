class AIChatMessage {
  final String sender; // 'user' veya 'ai'
  final String text;
  final int timestamp;

  AIChatMessage({required this.sender, required this.text, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory AIChatMessage.fromMap(Map map) {
    return AIChatMessage(
      sender: map['sender'] ?? 'user',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
} 