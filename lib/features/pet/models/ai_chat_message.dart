enum MessageType {
  text,
  voice,
  image,
}

class AIChatMessage {
  final String sender; // 'user' veya 'ai'
  final String text;
  final int timestamp;
  final MessageType type;
  final String? mediaUrl; // Ses dosyası veya resim URL'i
  final int? voiceDuration; // Ses mesajı süresi (saniye)
  final String? imageCaption; // Resim açıklaması

  AIChatMessage({
    required this.sender, 
    required this.text, 
    required this.timestamp,
    this.type = MessageType.text,
    this.mediaUrl,
    this.voiceDuration,
    this.imageCaption,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'text': text,
      'timestamp': timestamp,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'voiceDuration': voiceDuration,
      'imageCaption': imageCaption,
    };
  }

  factory AIChatMessage.fromMap(Map map) {
    return AIChatMessage(
      sender: map['sender'] ?? 'user',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      mediaUrl: map['mediaUrl'],
      voiceDuration: map['voiceDuration'],
      imageCaption: map['imageCaption'],
    );
  }

  // Text mesajı oluşturma
  factory AIChatMessage.text({
    required String sender,
    required String text,
    required int timestamp,
  }) {
    return AIChatMessage(
      sender: sender,
      text: text,
      timestamp: timestamp,
      type: MessageType.text,
    );
  }

  // Ses mesajı oluşturma
  factory AIChatMessage.voice({
    required String sender,
    required String text,
    required int timestamp,
    required String mediaUrl,
    required int voiceDuration,
  }) {
    return AIChatMessage(
      sender: sender,
      text: text,
      timestamp: timestamp,
      type: MessageType.voice,
      mediaUrl: mediaUrl,
      voiceDuration: voiceDuration,
    );
  }

  // Resim mesajı oluşturma
  factory AIChatMessage.image({
    required String sender,
    required String text,
    required int timestamp,
    required String mediaUrl,
    String? imageCaption,
  }) {
    return AIChatMessage(
      sender: sender,
      text: text,
      timestamp: timestamp,
      type: MessageType.image,
      mediaUrl: mediaUrl,
      imageCaption: imageCaption,
    );
  }
} 