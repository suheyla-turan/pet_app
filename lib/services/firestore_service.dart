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
}
