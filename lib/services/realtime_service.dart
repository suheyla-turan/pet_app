import 'package:firebase_database/firebase_database.dart';
import 'package:pati_takip/features/pet/models/ai_chat_message.dart';
import 'dart:convert'; // Added for jsonDecode
import 'package:http/http.dart' as http; // Added for http
// PetProfilePage ve widget importlarını kaldırdım

class RealtimeService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> setFeedingTime(String petId, DateTime feedingTime) async {
    await _db.child('pets').child(petId).update({
      'feedingTime': feedingTime.millisecondsSinceEpoch,
    });
  }

  Future<DateTime?> getFeedingTime(String petId) async {
    final snapshot = await _db.child('pets').child(petId).child('feedingTime').get();
    if (snapshot.value != null) {
      return DateTime.fromMillisecondsSinceEpoch(snapshot.value as int);
    }
    return null;
  }
}

class PetMessage {
  final String? key;
  final String sender;
  final String text;
  final int timestamp;
  PetMessage({this.key, required this.sender, required this.text, required this.timestamp});
  factory PetMessage.fromMap(Map map, [String? key]) => PetMessage(
    key: key,
    sender: map['sender'],
    text: map['text'],
    timestamp: map['timestamp'],
  );
}

extension PetChatRealtime on RealtimeService {
  Future<void> addPetMessage(String petId, String senderUid, String text) async {
    final msgRef = _db.child('pet_chats').child(petId).child('messages').push();
    await msgRef.set({
      'sender': senderUid,
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<List<PetMessage>> getPetMessagesStream(String petId) {
    return _db.child('pet_chats').child(petId).child('messages')
      .orderByChild('timestamp')
      .onValue
      .map((event) {
        final data = event.snapshot.value;
        if (data == null || data is! Map) return [];
        final mapData = data;
        if (mapData.isEmpty) return [];
        return mapData.entries.map((e) => PetMessage.fromMap(e.value, e.key)).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });
  }

  Future<void> deletePetMessage(String petId, String messageKey) async {
    await _db.child('pet_chats').child(petId).child('messages').child(messageKey).remove();
  }
}

extension PetStatusRealtime on RealtimeService {
  Future<void> updatePetStatus(String petId, {int? satiety, int? happiness, int? energy}) async {
    final updateData = <String, dynamic>{
      if (satiety != null) 'satiety': satiety,
      if (happiness != null) 'happiness': happiness,
      if (energy != null) 'energy': energy,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await _db.child('pet_status').child(petId).update(updateData);
  }

  Stream<Map<String, dynamic>?> getPetStatusStream(String petId) {
    return _db.child('pet_status').child(petId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return null;
      return Map<String, dynamic>.from(data);
    });
  }
}

extension AIChatRealtime on RealtimeService {
  Future<String> startNewAIChat(String petId) async {
    final chatRef = _db.child('ai_chats').child(petId).push();
    await chatRef.set({'createdAt': DateTime.now().millisecondsSinceEpoch});
    return chatRef.key!;
  }

  Future<void> addAIChatMessage(String petId, String chatId, AIChatMessage message) async {
    final msgRef = _db.child('ai_chats').child(petId).child(chatId).child('messages').push();
    await msgRef.set(message.toMap());
  }

  Stream<List<AIChatMessage>> getAIChatMessagesStream(String petId, String chatId) {
    return _db.child('ai_chats').child(petId).child(chatId).child('messages')
      .orderByChild('timestamp')
      .onValue
      .map((event) {
        final data = event.snapshot.value;
        if (data == null || data is! Map) return [];
        final mapData = data;
        if (mapData.isEmpty) return [];
        return mapData.entries.map((e) => AIChatMessage.fromMap(e.value)).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });
  }

  Future<List<Map<String, dynamic>>> getAIChatList(String petId) async {
    final snapshot = await _db.child('ai_chats').child(petId).get();
    if (snapshot.value == null || snapshot.value is! Map) return [];
    final mapData = snapshot.value as Map;
    List<Map<String, dynamic>> result = [];
    for (final entry in mapData.entries) {
      final chatId = entry.key;
      final chatData = entry.value as Map;
      // Sadece mesajı olan sohbetleri döndür
      if (chatData.containsKey('messages') && (chatData['messages'] as Map).isNotEmpty) {
        result.add({
          'chatId': chatId,
          'createdAt': chatData['createdAt'] ?? 0,
        });
      }
    }
    return result..sort((a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int));
  }

  Future<void> deleteAIChat(String petId, String chatId) async {
    await _db.child('ai_chats').child(petId).child(chatId).remove();
  }
}

// Widget ve context işlemlerini kaldırıyorum

Future<Map<String, dynamic>> getIntentFromAI(String command) async {
  // Burada kendi backend veya AI API'nı çağırmalısın
  // Örnek response: { "intent": "feed", "petId": "golden123" }
  final response = await http.post(
    Uri.parse('https://senin-backend.com/ai-intent'),
    body: {'command': command},
  );
  return jsonDecode(response.body);
}

final realtimeService = RealtimeService();

void handleVoiceCommand(String command) async {
  final intentData = await getIntentFromAI(command);

  switch (intentData['intent']) {
    case 'feed':
      await realtimeService.setFeedingTime(intentData['petId'], DateTime.now());
      await realtimeService.updatePetStatus(intentData['petId'], satiety: 100);
      break;
    case 'sleep':
      await realtimeService.updatePetStatus(intentData['petId'], energy: 100);
      break;
    case 'go_to_profile':
      // context'i parametre olarak geçirmen gerekebilir
      // Navigator.push(context, MaterialPageRoute(
      //   builder: (_) => PetProfilePage(petId: intentData['petId']),
      // ));
      break;
    // Diğer komutlar...
    default:
      // Bilinmeyen komut
      break;
  }
} 