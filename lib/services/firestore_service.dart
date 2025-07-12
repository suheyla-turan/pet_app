import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/pet/models/pet.dart';

class FirestoreService {
  static Future<void> hayvanEkle(Pet pet) async {
    try {
      await FirebaseFirestore.instance.collection('hayvanlar').add(pet.toMap());
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
      final snapshot = await FirebaseFirestore.instance.collection('hayvanlar').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Eski veri formatı kontrolü
        if (data.containsKey('ad')) {
          // Eski format - yeni formata çevir
          return Pet(
            name: data['ad'] ?? '',
            gender: data['cinsiyet'] ?? '',
            birthDate: DateTime.parse(data['dogumTarihi'] ?? DateTime.now().toIso8601String()),
            hunger: 5,
            happiness: 5,
            energy: 5,
            care: 5,
            hungerInterval: 60,
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
}
