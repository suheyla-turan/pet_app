import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class RealtimeService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Güvenlik kontrolü
  bool _isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  // Hata yönetimi için wrapper
  Future<T?> _safeDatabaseOperation<T>(Future<T> Function() operation) async {
    try {
      if (!_isUserAuthenticated()) {
        throw Exception('Kullanıcı giriş yapmamış');
      }
      return await operation();
    } on Exception catch (e) {
      print('❌ Database hatası: ${e.toString()}');
      if (e.toString().contains('Permission denied')) {
        throw Exception('Bu işlem için yetkiniz bulunmuyor');
      }
      throw Exception('Veritabanı hatası: ${e.toString()}');
    } catch (e) {
      print('❌ Genel hata: $e');
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  Future<void> setFeedingTime(String petId, DateTime feedingTime) async {
    await _safeDatabaseOperation(() async {
      await _db.child('pets').child(petId).update({
        'feedingTime': feedingTime.millisecondsSinceEpoch,
      });
    });
  }

  Future<DateTime?> getFeedingTime(String petId) async {
    return await _safeDatabaseOperation<DateTime?>(() async {
      final snapshot = await _db.child('pets').child(petId).child('feedingTime').get();
      if (snapshot.value != null) {
        return DateTime.fromMillisecondsSinceEpoch(snapshot.value as int);
      }
      return null;
    });
  }
}

class PetMessage {
  final String? key;
  final String sender;
  final String text;
  final int timestamp;
  final String? imagePath;
  final String? audioPath;
  
  PetMessage({
    this.key, 
    required this.sender, 
    required this.text, 
    required this.timestamp,
    this.imagePath,
    this.audioPath,
  });
  
  factory PetMessage.fromMap(Map map, [String? key]) => PetMessage(
    key: key,
    sender: map['sender'],
    text: map['text'],
    timestamp: map['timestamp'],
    imagePath: map['imagePath'],
    audioPath: map['audioPath'],
  );
}

extension PetChatRealtime on RealtimeService {
  Future<void> addPetMessage(String petId, String senderUid, String text, {
    String? petName,
    String? senderName,
    String? imagePath,
    String? audioPath,
  }) async {
    await _safeDatabaseOperation(() async {
      final msgRef = _db.child('pet_chats').child(petId).child('messages').push();
      final messageData = {
        'sender': senderUid,
        'text': text,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (imagePath != null) 'imagePath': imagePath,
        if (audioPath != null) 'audioPath': audioPath,
      };
      await msgRef.set(messageData);
      
      // Eş sahipten mesaj geldiğinde bildirim gönder
      if (petName != null && senderName != null) {
        await NotificationService.showCoOwnerMessageNotification(
          petName,
          senderName,
          text,
        );
      }
    });
  }

  Stream<List<PetMessage>> getPetMessagesStream(String petId) {
    if (!_isUserAuthenticated()) {
      return Stream.value([]); // Boş liste döndür, hata fırlatma
    }

    try {
      return _db.child('pet_chats').child(petId).child('messages')
        .orderByChild('timestamp')
        .onValue
        .handleError((error) {
          // Hata durumunda boş liste döndür
          return [];
        })
        .map<List<PetMessage>>((event) {
          try {
            final data = event.snapshot.value;
            if (data == null) {
              return [];
            }
            if (data is! Map) {
              return [];
            }
            final mapData = data;
            if (mapData.isEmpty) {
              return [];
            }
            final messages = mapData.entries.map((e) {
              return PetMessage.fromMap(e.value, e.key);
            }).toList();
            messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            return messages;
          } catch (e) {
            return []; // Hata durumunda boş liste döndür
          }
        });
    } catch (e) {
      return Stream.value([]); // Hata durumunda boş liste döndür
    }
  }

  Future<void> deletePetMessage(String petId, String messageKey) async {
    await _safeDatabaseOperation(() async {
      await _db.child('pet_chats').child(petId).child('messages').child(messageKey).remove();
    });
  }
}

extension PetStatusRealtime on RealtimeService {
  Future<void> updatePetStatus(String petId, {int? satiety, int? happiness, int? energy}) async {
    await _safeDatabaseOperation(() async {
      final updateData = <String, dynamic>{
        if (satiety != null) 'satiety': satiety,
        if (happiness != null) 'happiness': happiness,
        if (energy != null) 'energy': energy,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      await _db.child('pet_status').child(petId).update(updateData);
    });
  }

  Stream<Map<String, dynamic>?> getPetStatusStream(String petId) {
    if (!_isUserAuthenticated()) {
      print('❌ Kullanıcı kimlik doğrulaması yapılmamış');
      return Stream.value(null); // Null döndür, hata fırlatma
    }

    try {
      return _db.child('pet_status').child(petId).onValue
        .handleError((error) {
          print('❌ Pet status stream hatası: $error');
          return null; // Hata durumunda null döndür
        })
        .map((event) {
          try {
            final data = event.snapshot.value;
            if (data == null || data is! Map) return null;
            return Map<String, dynamic>.from(data);
          } catch (e) {
            print('❌ Pet status parse hatası: $e');
            return null; // Hata durumunda null döndür
          }
        });
    } catch (e) {
      print('❌ Pet status stream oluşturulamadı: $e');
      return Stream.value(null); // Hata durumunda null döndür
    }
  }
} 