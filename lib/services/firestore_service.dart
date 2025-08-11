import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/pet/models/pet.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static Future<void> hayvanEkle(Pet pet) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      final petMap = pet.toMap();
      // owners alanı yoksa ekle
      if (petMap['owners'] is! List || (petMap['owners'] as List).isEmpty) {
        petMap['owners'] = [user.uid];
      } else if (!(petMap['owners'] as List).contains(user.uid)) {
        (petMap['owners'] as List).add(user.uid);
      }
      // creator alanı yoksa ekle
      if (petMap['creator'] == null) {
        petMap['creator'] = user.uid;
      }
      await FirebaseFirestore.instance.collection('hayvanlar').add(petMap);
      print('✅ Hayvan Firestore\'a kaydedildi.');
    } catch (e) {
      print('❌ HATA - Firestore\'a kaydedilemedi: $e');
    }
  }

  static Future<void> hayvanGuncelle(String id, Pet pet) async {
    try {
      await FirebaseFirestore.instance.collection('hayvanlar').doc(id).update(pet.toMap());
      print('✅ Hayvan Firestore\'da güncellendi.');
    } catch (e) {
      print('❌ HATA - Firestore\'da güncellenemedi: $e');
    }
  }

  static Future<List<Pet>> hayvanlariGetir() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      final snapshot = await FirebaseFirestore.instance
          .collection('hayvanlar')
          .where('owners', arrayContains: user.uid)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Eski veri formatı kontrolü
        if (data.containsKey('ad')) {
          // Eski format - yeni formata çevir
          return Pet(
            name: data['ad'] ?? '',
            gender: data['cinsiyet'] ?? '',
            birthDate: DateTime.parse(data['dogumTarihi'] ?? DateTime.now().toIso8601String()),
            satiety: 5,
            happiness: 5,
            energy: 5,
            care: 5,
            satietyInterval: 60,
            happinessInterval: 60,
            energyInterval: 60,
            careInterval: 1440,
            vaccines: (data['asilar'] as List? ?? []).map((v) => Vaccine(
              name: v['ad'] ?? '',
              date: DateTime.parse(v['tarih'] ?? DateTime.now().toIso8601String()),
            )).toList(),
            type: data['tür'] ?? 'Köpek',
            imagePath: null,
            lastUpdate: DateTime.now(),
          );
        } else {
          // Yeni format
          data['id'] = doc.id;
          return Pet.fromMap(data);
        }
      }).toList();
    } catch (e) {
      print('❌ HATA - Hayvanlar getirilemedi: $e');
      return [];
    }
  }

  static Future<void> hayvanSil(String id) async {
    try {
      await FirebaseFirestore.instance.collection('hayvanlar').doc(id).delete();
      print('✅ Hayvan Firestore\'dan silindi.');
    } catch (e) {
      print('❌ HATA - Hayvan silinemedi: $e');
    }
  }

  static Future<void> addOwnerToPet(String petId, String newOwnerUid) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('hayvanlar').doc(petId);
      await docRef.update({
        'owners': FieldValue.arrayUnion([newOwnerUid])
      });
      print('✅ Yeni sahip eklendi: $newOwnerUid');
    } catch (e) {
      print('❌ HATA - Sahip eklenemedi: $e');
    }
  }

  // Eş sahip yönetimi metodları
  static Future<List<Map<String, dynamic>>> getCoOwners(String petId) async {
    try {
      final petDoc = await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).get();
      if (!petDoc.exists) throw Exception('Hayvan bulunamadı');
      
      final petData = petDoc.data()!;
      final ownerIds = List<String>.from(petData['owners'] ?? []);
      
      if (ownerIds.isEmpty) return [];
      
      // Kullanıcı bilgilerini getir
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: ownerIds)
          .get();
      
      return usersSnapshot.docs.map((doc) {
        final userData = doc.data();
        return {
          'uid': doc.id,
          'email': userData['email'] ?? '',
          'displayName': userData['displayName'] ?? 'İsimsiz Kullanıcı',
        };
      }).toList();
    } catch (e) {
      print('❌ HATA - Eş sahipler getirilemedi: $e');
      return [];
    }
  }

  static Future<void> addCoOwner(String petId, String email) async {
    try {
      // Email ile kullanıcıyı bul
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (usersSnapshot.docs.isEmpty) {
        throw Exception('Bu email adresi ile kayıtlı kullanıcı bulunamadı');
      }
      
      final userDoc = usersSnapshot.docs.first;
      final userId = userDoc.id;
      
      // Hayvana eş sahip olarak ekle
      await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).update({
        'owners': FieldValue.arrayUnion([userId])
      });
      
      print('✅ Eş sahip eklendi: $email');
    } catch (e) {
      print('❌ HATA - Eş sahip eklenemedi: $e');
      throw e;
    }
  }

  static Future<void> removeCoOwner(String petId, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).update({
        'owners': FieldValue.arrayRemove([userId])
      });
      
      print('✅ Eş sahip kaldırıldı: $userId');
    } catch (e) {
      print('❌ HATA - Eş sahip kaldırılamadı: $e');
      throw e;
    }
  }

  static Future<void> sendMessageToCoOwners(String petId, String message) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      
      final petDoc = await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).get();
      if (!petDoc.exists) throw Exception('Hayvan bulunamadı');
      
      final petData = petDoc.data()!;
      final ownerIds = List<String>.from(petData['owners'] ?? []);
      
      // Mesajı kaydet
      await FirebaseFirestore.instance.collection('messages').add({
        'petId': petId,
        'senderId': user.uid,
        'senderName': user.displayName ?? 'İsimsiz Kullanıcı',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'recipients': ownerIds,
        'type': 'co_owner_message',
      });
      
      print('✅ Mesaj tüm eş sahiplere gönderildi');
    } catch (e) {
      print('❌ HATA - Mesaj gönderilemedi: $e');
      throw e;
    }
  }

  static Future<bool> addOwnerToPetByEmail(String petId, String email) async {
    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('profiller')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (userQuery.docs.isEmpty) {
        print('❌ Kullanıcı bulunamadı: $email');
        return false;
      }
      final uid = userQuery.docs.first.id;
      await addOwnerToPet(petId, uid);
      return true;
    } catch (e) {
      print('❌ HATA - E-posta ile sahip eklenemedi: $e');
      return false;
    }
  }

  static Future<void> sendFeedbackMessage(String message, {String? userId, String? userEmail}) async {
    try {
      final now = DateTime.now();
      await FirebaseFirestore.instance.collection('feedback').add({
        'message': message,
        'timestamp': now.toIso8601String(),
        if (userId != null) 'userId': userId,
        if (userEmail != null) 'userEmail': userEmail,
      });
      print('✅ Feedback mesajı Firestore\'a kaydedildi.');
    } catch (e) {
      print('❌ HATA - Feedback mesajı kaydedilemedi: $e');
    }
  }
}
