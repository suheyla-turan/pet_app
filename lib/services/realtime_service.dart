import 'package:firebase_database/firebase_database.dart';
import 'notification_service.dart';


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
  Future<void> addPetMessage(String petId, String senderUid, String text, {
    String? petName,
    String? senderName,
  }) async {
    final msgRef = _db.child('pet_chats').child(petId).child('messages').push();
    await msgRef.set({
      'sender': senderUid,
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // Eş sahipten mesaj geldiğinde bildirim gönder
    if (petName != null && senderName != null) {
      await NotificationService.showCoOwnerMessageNotification(
        petName,
        senderName,
        text,
      );
    }
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