import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/pet/models/pet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

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
          
          // Creator alanı null ise mevcut kullanıcıyı ata
          if (data['creator'] == null && data['owners'] != null && (data['owners'] as List).isNotEmpty) {
            data['creator'] = (data['owners'] as List).first;
          }
          
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
          .collection('profiller')
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
      // Mevcut kullanıcıyı kontrol et
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu yok. Lütfen tekrar giriş yapın.');
      }

      // Hayvan dokümanını getir ve yetkiyi kontrol et
      final petDoc = await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).get();
      if (!petDoc.exists) {
        throw Exception('Hayvan bulunamadı');
      }

      final petData = petDoc.data()!;
      final ownerIds = List<String>.from(petData['owners'] ?? []);
      final creatorId = petData['creator'] as String?;

      // Kullanıcının bu hayvana sahip olup olmadığını kontrol et
      if (!ownerIds.contains(currentUser.uid)) {
        throw Exception('Bu hayvana eş sahip ekleme yetkiniz yok. Sadece hayvan sahipleri eş sahip ekleyebilir.');
      }

      // Email ile kullanıcıyı bul
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('profiller')
          .where('email', isEqualTo: email)
          .get();
      
      if (usersSnapshot.docs.isEmpty) {
        throw Exception('Bu email adresi ile kayıtlı kullanıcı bulunamadı. Kullanıcının önce uygulamaya kayıt olması gerekiyor.');
      }
      
      final userDoc = usersSnapshot.docs.first;
      final userId = userDoc.id;
      
      // Kendini eş sahip olarak eklemeye çalışıyorsa engelle
      if (userId == currentUser.uid) {
        throw Exception('Kendinizi eş sahip olarak ekleyemezsiniz.');
      }

      // Kullanıcı zaten eş sahip mi kontrol et
      if (ownerIds.contains(userId)) {
        throw Exception('Bu kullanıcı zaten eş sahip.');
      }
      
      // Hayvana eş sahip olarak ekle
      await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).update({
        'owners': FieldValue.arrayUnion([userId])
      });
      
      print('✅ Eş sahip eklendi: $email');
    } catch (e) {
      print('❌ HATA - Eş sahip eklenemedi: $e');
      
      // Hata türüne göre özel mesajlar
      if (e.toString().contains('permission-denied')) {
        throw Exception('Yetki hatası: Bu işlemi gerçekleştirmek için gerekli izinleriniz yok. Lütfen tekrar giriş yapın veya uygulama ayarlarını kontrol edin.');
      } else if (e.toString().contains('not-found')) {
        throw Exception('Hayvan bulunamadı. Lütfen sayfayı yenileyin.');
      } else if (e.toString().contains('unavailable')) {
        throw Exception('Sunucu hatası. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.');
      } else {
        throw Exception('Eş sahip eklenirken beklenmeyen bir hata oluştu: ${e.toString()}');
      }
    }
  }

  // Eski addCoOwner metodunu güncelle - artık istek sistemi kullanılıyor
  // Bu metod sadece geriye dönük uyumluluk için tutuluyor
  static Future<void> addCoOwnerDirect(String petId, String email) async {
    try {
      // Mevcut kullanıcıyı kontrol et
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu yok. Lütfen tekrar giriş yapın.');
      }

      // Hayvan dokümanını getir ve yetkiyi kontrol et
      final petDoc = await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).get();
      if (!petDoc.exists) {
        throw Exception('Hayvan bulunamadı');
      }

      final petData = petDoc.data()!;
      final ownerIds = List<String>.from(petData['owners'] ?? []);
      final creatorId = petData['creator'] as String?;

      // Kullanıcının bu hayvana sahip olup olmadığını kontrol et
      if (!ownerIds.contains(currentUser.uid)) {
        throw Exception('Bu hayvana eş sahip ekleme yetkiniz yok. Sadece hayvan sahipleri eş sahip ekleyebilir.');
      }

      // Email ile kullanıcıyı bul
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('profiller')
          .where('email', isEqualTo: email)
          .get();
      
      if (usersSnapshot.docs.isEmpty) {
        throw Exception('Bu email adresi ile kayıtlı kullanıcı bulunamadı. Kullanıcının önce uygulamaya kayıt olması gerekiyor.');
      }
      
      final userDoc = usersSnapshot.docs.first;
      final userId = userDoc.id;
      
      // Kendini eş sahip olarak eklemeye çalışıyorsa engelle
      if (userId == currentUser.uid) {
        throw Exception('Kendinizi eş sahip olarak ekleyemezsiniz.');
      }

      // Kullanıcı zaten eş sahip mi kontrol et
      if (ownerIds.contains(userId)) {
        throw Exception('Bu kullanıcı zaten eş sahip.');
      }
      
      // Hayvana eş sahip olarak ekle
      await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).update({
        'owners': FieldValue.arrayUnion([userId])
      });
      
      print('✅ Eş sahip eklendi: $email');
    } catch (e) {
      print('❌ HATA - Eş sahip eklenemedi: $e');
      
      // Hata türüne göre özel mesajlar
      if (e.toString().contains('permission-denied')) {
        throw Exception('Yetki hatası: Bu işlemi gerçekleştirmek için gerekli izinleriniz yok. Lütfen tekrar giriş yapın veya uygulama ayarlarını kontrol edin.');
      } else if (e.toString().contains('not-found')) {
        throw Exception('Hayvan bulunamadı. Lütfen sayfayı yenileyin.');
      } else if (e.toString().contains('unavailable')) {
        throw Exception('Sunucu hatası. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.');
      } else {
        throw Exception('Eş sahip eklenirken beklenmeyen bir hata oluştu: ${e.toString()}');
      }
    }
  }

  static Future<void> removeCoOwner(String petId, String userId) async {
    try {
      // Mevcut kullanıcıyı kontrol et
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu yok. Lütfen tekrar giriş yapın.');
      }

      // Hayvan dokümanını getir ve yetkiyi kontrol et
      final petDoc = await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).get();
      if (!petDoc.exists) {
        throw Exception('Hayvan bulunamadı');
      }

      final petData = petDoc.data()!;
      final ownerIds = List<String>.from(petData['owners'] ?? []);
      final creatorId = petData['creator'] as String?;

      // Kullanıcının bu hayvana sahip olup olmadığını kontrol et
      if (!ownerIds.contains(currentUser.uid)) {
        throw Exception('Bu hayvandan eş sahip kaldırma yetkiniz yok. Sadece hayvan sahipleri eş sahip kaldırabilir.');
      }

      // Kendini kaldırmaya çalışıyorsa engelle (en az bir sahip kalmalı)
      if (userId == currentUser.uid && ownerIds.length <= 1) {
        throw Exception('Kendinizi kaldıramazsınız. En az bir sahip kalmalı.');
      }
      
      // Hayvandan eş sahip kaldır
      await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).update({
        'owners': FieldValue.arrayRemove([userId])
      });
      
      print('✅ Eş sahip kaldırıldı: $userId');
    } catch (e) {
      print('❌ HATA - Eş sahip kaldırılamadı: $e');
      
      // Hata türüne göre özel mesajlar
      if (e.toString().contains('permission-denied')) {
        throw Exception('Yetki hatası: Bu işlemi gerçekleştirmek için gerekli izinleriniz yok. Lütfen tekrar giriş yapın veya uygulama ayarlarını kontrol edin.');
      } else if (e.toString().contains('not-found')) {
        throw Exception('Hayvan bulunamadı. Lütfen sayfayı yenileyin.');
      } else {
        throw Exception('Eş sahip kaldırılırken beklenmeyen bir hata oluştu: ${e.toString()}');
      }
    }
  }

  /// Eş sahiplere metin mesajı gönder
  static Future<void> sendMessageToCoOwners(String petId, String message) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      
      final petDoc = await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).get();
      if (!petDoc.exists) throw Exception('Hayvan bulunamadı');
      
      final petData = petDoc.data()!;
      final ownerIds = List<String>.from(petData['owners'] ?? []);
      final petName = petData['name'] ?? 'İsimsiz Hayvan';
      
      // Mesajı kaydet
      await FirebaseFirestore.instance.collection('pet_messages').add({
        'petId': petId,
        'petName': petName,
        'senderId': user.uid,
        'senderName': user.displayName ?? 'İsimsiz Kullanıcı',
        'senderEmail': user.email ?? '',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'recipients': ownerIds,
        'type': 'co_owner_message',
        'messageType': 'text',
      });
      
      // Tüm eş sahiplere bildirim gönder (gönderen hariç)
      for (final recipientId in ownerIds) {
        if (recipientId != user.uid) {
          await NotificationService.showCoOwnerMessageNotification(petName, user.displayName ?? 'İsimsiz Kullanıcı', message);
        }
      }
      
      print('✅ Metin mesajı tüm eş sahiplere gönderildi');
    } catch (e) {
      print('❌ HATA - Metin mesajı gönderilemedi: $e');
      throw e;
    }
  }

  /// Eş sahiplere görsel mesaj gönder
  static Future<void> sendImageMessageToCoOwners(String petId, String imageUrl, String? caption) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      
      final petDoc = await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).get();
      if (!petDoc.exists) throw Exception('Hayvan bulunamadı');
      
      final petData = petDoc.data()!;
      final ownerIds = List<String>.from(petData['owners'] ?? []);
      final petName = petData['name'] ?? 'İsimsiz Hayvan';
      
      // Görsel mesajı kaydet
      await FirebaseFirestore.instance.collection('pet_messages').add({
        'petId': petId,
        'petName': petName,
        'senderId': user.uid,
        'senderName': user.displayName ?? 'İsimsiz Kullanıcı',
        'senderEmail': user.email ?? '',
        'imageUrl': imageUrl,
        'caption': caption,
        'timestamp': FieldValue.serverTimestamp(),
        'recipients': ownerIds,
        'type': 'co_owner_message',
        'messageType': 'image',
      });
      
      // Tüm eş sahiplere bildirim gönder (gönderen hariç)
      for (final recipientId in ownerIds) {
        if (recipientId != user.uid) {
          final notificationText = caption?.isNotEmpty == true ? caption! : 'Görsel mesaj';
          await NotificationService.showCoOwnerMessageNotification(petName, user.displayName ?? 'İsimsiz Kullanıcı', notificationText);
        }
      }
      
      print('✅ Görsel mesaj tüm eş sahiplere gönderildi');
    } catch (e) {
      print('❌ HATA - Görsel mesaj gönderilemedi: $e');
      throw e;
    }
  }

  /// Eş sahiplere sesli mesaj gönder
  static Future<void> sendVoiceMessageToCoOwners(String petId, String audioUrl, int durationSeconds) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      
      final petDoc = await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).get();
      if (!petDoc.exists) throw Exception('Hayvan bulunamadı');
      
      if (!petDoc.exists) throw Exception('Hayvan bulunamadı');
      
      final petData = petDoc.data()!;
      final ownerIds = List<String>.from(petData['owners'] ?? []);
      final petName = petData['name'] ?? 'İsimsiz Hayvan';
      
      // Sesli mesajı kaydet
      await FirebaseFirestore.instance.collection('pet_messages').add({
        'petId': petId,
        'petName': petName,
        'senderId': user.uid,
        'senderName': user.displayName ?? 'İsimsiz Kullanıcı',
        'senderEmail': user.email ?? '',
        'audioUrl': audioUrl,
        'durationSeconds': durationSeconds,
        'timestamp': FieldValue.serverTimestamp(),
        'recipients': ownerIds,
        'type': 'co_owner_message',
        'messageType': 'voice',
      });
      
      // Tüm eş sahiplere bildirim gönder (gönderen hariç)
      for (final recipientId in ownerIds) {
        if (recipientId != user.uid) {
          await NotificationService.showCoOwnerMessageNotification(petName, user.displayName ?? 'İsimsiz Kullanıcı', 'Sesli mesaj');
        }
      }
      
      print('✅ Sesli mesaj tüm eş sahiplere gönderildi');
    } catch (e) {
      print('❌ HATA - Sesli mesaj gönderilemedi: $e');
      throw e;
    }
  }

  /// Eş sahiplerden gelen mesajları getir
  static Future<List<Map<String, dynamic>>> getCoOwnerMessages(String petId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('pet_messages')
          .where('petId', isEqualTo: petId)
          .orderBy('timestamp', descending: true)
          .get();
      
      return messagesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'messageId': doc.id,
          'petId': data['petId'],
          'petName': data['petName'],
          'senderId': data['senderId'],
          'senderName': data['senderName'],
          'senderEmail': data['senderEmail'],
          'message': data['message'],
          'timestamp': data['timestamp'],
          'isOwnMessage': data['senderId'] == user.uid,
          'messageType': data['messageType'] ?? 'text',
          'imageUrl': data['imageUrl'],
          'caption': data['caption'],
          'audioUrl': data['audioUrl'],
          'durationSeconds': data['durationSeconds'],
          'isEdited': data['isEdited'] ?? false,
          'editedAt': data['editedAt'],
        };
      }).toList();
    } catch (e) {
      print('❌ HATA - Mesajlar getirilemedi: $e');
      return [];
    }
  }

  /// Kullanıcının tüm eş sahip olduğu hayvanlardan gelen mesajları getir
  static Future<List<Map<String, dynamic>>> getAllCoOwnerMessages() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('pet_messages')
          .where('recipients', arrayContains: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(50) // Son 50 mesaj
          .get();
      
      return messagesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'messageId': doc.id,
          'petId': data['petId'],
          'petName': data['petName'],
          'senderId': data['senderId'],
          'senderName': data['senderName'],
          'senderEmail': data['senderEmail'],
          'message': data['message'],
          'timestamp': data['timestamp'],
          'isOwnMessage': data['senderId'] == user.uid,
        };
      }).toList();
    } catch (e) {
      print('❌ HATA - Tüm mesajlar getirilemedi: $e');
      return [];
    }
  }

  /// Mesajı sil (sadece kendi mesajlarını silebilir)
  static Future<void> deleteMessage(String messageId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      
      // Mesajı getir ve yetkiyi kontrol et
      final messageDoc = await FirebaseFirestore.instance
          .collection('pet_messages')
          .doc(messageId)
          .get();
      
      if (!messageDoc.exists) throw Exception('Mesaj bulunamadı');
      
      final messageData = messageDoc.data()!;
      final senderId = messageData['senderId'] as String;
      
      // Sadece kendi mesajlarını silebilir
      if (senderId != user.uid) {
        throw Exception('Sadece kendi mesajlarınızı silebilirsiniz');
      }
      
      // Mesajı sil
      await FirebaseFirestore.instance
          .collection('pet_messages')
          .doc(messageId)
          .delete();
      
      print('✅ Mesaj silindi');
    } catch (e) {
      print('❌ HATA - Mesaj silinemedi: $e');
      throw e;
    }
  }

  /// Mesajı düzenle (sadece kendi mesajlarını düzenleyebilir)
  static Future<void> editMessage(String messageId, String newMessage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      
      // Mesajı getir ve yetkiyi kontrol et
      final messageDoc = await FirebaseFirestore.instance
          .collection('pet_messages')
          .doc(messageId)
          .get();
      
      if (!messageDoc.exists) throw Exception('Mesaj bulunamadı');
      
      final messageData = messageDoc.data()!;
      final senderId = messageData['senderId'] as String;
      final messageType = messageData['messageType'] as String?;
      
      // Sadece kendi mesajlarını düzenleyebilir
      if (senderId != user.uid) {
        throw Exception('Sadece kendi mesajlarınızı düzenleyebilirsiniz');
      }
      
      // Sadece metin mesajları düzenlenebilir
      if (messageType != 'text') {
        throw Exception('Sadece metin mesajları düzenlenebilir');
      }
      
      // Mesajı güncelle
      await FirebaseFirestore.instance
          .collection('pet_messages')
          .doc(messageId)
          .update({
        'message': newMessage,
        'editedAt': FieldValue.serverTimestamp(),
        'isEdited': true,
      });
      
      print('✅ Mesaj düzenlendi');
    } catch (e) {
      print('❌ HATA - Mesaj düzenlenemedi: $e');
      throw e;
    }
  }

  // Eşsahip istek sistemi metodları
  static Future<void> sendCoOwnerRequest(String petId, String email) async {
    try {
      // Mevcut kullanıcıyı kontrol et
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu yok. Lütfen tekrar giriş yapın.');
      }

      // Hayvan dokümanını getir ve yetkiyi kontrol et
      final petDoc = await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).get();
      if (!petDoc.exists) {
        throw Exception('Hayvan bulunamadı');
      }

      final petData = petDoc.data()!;
      final ownerIds = List<String>.from(petData['owners'] ?? []);

      // Kullanıcının bu hayvana sahip olup olmadığını kontrol et
      if (!ownerIds.contains(currentUser.uid)) {
        throw Exception('Bu hayvana eş sahip isteği gönderme yetkiniz yok. Sadece hayvan sahipleri eş sahip isteği gönderebilir.');
      }

      // Email ile kullanıcıyı bul
      print('🔍 Email ile kullanıcı aranıyor: $email');
      
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('profiller')
          .where('email', isEqualTo: email)
          .get();
      
      print('📊 Bulunan kullanıcı sayısı: ${usersSnapshot.docs.length}');
      
      if (usersSnapshot.docs.isEmpty) {
        // Debug: Tüm profiller koleksiyonunu kontrol et
        final allUsersSnapshot = await FirebaseFirestore.instance
            .collection('profiller')
            .get();
        print('📋 Toplam kullanıcı sayısı: ${allUsersSnapshot.docs.length}');
        
        // İlk birkaç kullanıcının email'ini yazdır
        for (int i = 0; i < allUsersSnapshot.docs.length && i < 3; i++) {
          final userData = allUsersSnapshot.docs[i].data();
          print('👤 Kullanıcı ${i + 1}: ${userData['email']}');
        }
        
        throw Exception('Bu email adresi ile kayıtlı kullanıcı bulunamadı. Kullanıcının önce uygulamaya kayıtlı olması gerekiyor.');
      }
      
      final userDoc = usersSnapshot.docs.first;
      final userId = userDoc.id;
      
      // Kendine istek göndermeye çalışıyorsa engelle
      if (userId == currentUser.uid) {
        throw Exception('Kendinize eş sahip isteği gönderemezsiniz.');
      }

      // Kullanıcı zaten eş sahip mi kontrol et
      if (ownerIds.contains(userId)) {
        throw Exception('Bu kullanıcı zaten eş sahip.');
      }

      // Zaten bekleyen istek var mı kontrol et
      final existingRequest = await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .where('petId', isEqualTo: petId)
          .where('requestedUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();
      
      if (existingRequest.docs.isNotEmpty) {
        throw Exception('Bu kullanıcıya zaten eş sahip isteği gönderilmiş.');
      }
      
      // Reddedilen istek varsa sil (tekrar istek atılabilmesi için)
      final rejectedRequest = await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .where('petId', isEqualTo: petId)
          .where('requestedUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'rejected')
          .get();
      
      for (final doc in rejectedRequest.docs) {
        await doc.reference.delete();
      }
      
      // İsteği kaydet
      await FirebaseFirestore.instance.collection('co_owner_requests').add({
        'petId': petId,
        'petName': petData['name'] ?? 'İsimsiz Hayvan',
        'requesterId': currentUser.uid,
        'requesterName': currentUser.displayName ?? 'İsimsiz Kullanıcı',
        'requesterEmail': currentUser.email ?? '',
        'requestedUserId': userId,
        'requestedUserEmail': email,
        'status': 'pending', // pending, accepted, rejected
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Bu hayvana eş sahip olmak ister misiniz?',
      });
      
      print('✅ Eş sahip isteği gönderildi: $email');
    } catch (e) {
      print('❌ HATA - Eş sahip isteği gönderilemedi: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingCoOwnerRequests(String userId) async {
    try {
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .where('requestedUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .get();
      
      return requestsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'requestId': doc.id,
          'petId': data['petId'],
          'petName': data['petName'],
          'requesterId': data['requesterId'],
          'requesterName': data['requesterName'],
          'requesterEmail': data['requesterEmail'],
          'message': data['message'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    } catch (e) {
      print('❌ HATA - Bekleyen istekler getirilemedi: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getSentCoOwnerRequests(String userId) async {
    try {
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .where('requesterId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      
      return requestsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'requestId': doc.id,
          'petId': data['petId'],
          'petName': data['petName'],
          'requestedUserId': data['requestedUserId'],
          'requestedUserEmail': data['requestedUserEmail'],
          'status': data['status'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    } catch (e) {
      print('❌ HATA - Gönderilen istekler getirilemedi: $e');
      return [];
    }
  }

  static Future<void> acceptCoOwnerRequest(String requestId) async {
    try {
      final requestDoc = await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .doc(requestId)
          .get();
      
      if (!requestDoc.exists) {
        throw Exception('İstek bulunamadı');
      }
      
      final requestData = requestDoc.data()!;
      final petId = requestData['petId'] as String;
      final requestedUserId = requestData['requestedUserId'] as String;
      final requesterName = requestData['requesterName'] as String;
      final petName = requestData['petName'] as String;
      
      // İsteği kabul edildi olarak işaretle
      await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .doc(requestId)
          .update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      
      // Hayvana eş sahip olarak ekle
      await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).update({
        'owners': FieldValue.arrayUnion([requestedUserId])
      });
      
      // İstek atan kişiye kabul bildirimi gönder
      await NotificationService.showCoOwnerRequestAcceptedNotification(petName, requesterName);
      
      print('✅ Eş sahip isteği kabul edildi');
    } catch (e) {
      print('❌ HATA - İstek kabul edilemedi: $e');
      throw e;
    }
  }

  static Future<void> rejectCoOwnerRequest(String requestId) async {
    try {
      final requestDoc = await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .doc(requestId)
          .get();
      
      if (!requestDoc.exists) {
        throw Exception('İstek bulunamadı');
      }
      
      final requestData = requestDoc.data()!;
      final requesterId = requestData['requesterId'] as String;
      final petName = requestData['petName'] as String;
      
      // İsteği reddedildi olarak işaretle
      await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .doc(requestId)
          .update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
      
      // İstek atan kişiye red bildirimi gönder
      await NotificationService.showCoOwnerRequestRejectedNotification(petName, 'Siz');
      
      print('✅ Eş sahip isteği reddedildi');
    } catch (e) {
      print('❌ HATA - İstek reddedilemedi: $e');
      throw e;
    }
  }

  static Future<void> cancelCoOwnerRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .doc(requestId)
          .delete();
      
      print('✅ Eş sahip isteği iptal edildi');
    } catch (e) {
      print('❌ HATA - İstek iptal edilemedi: $e');
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
