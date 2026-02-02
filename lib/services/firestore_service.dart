import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/pet/models/pet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';
import 'dart:io'; // Added for File

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

  // Kullanıcı adını almak için yardımcı metod
  static String _getUserDisplayName(Map<String, dynamic> userData) {
    return userData['displayName'] ?? 
           userData['name'] ?? 
           (userData['email'] != null ? userData['email'].split('@')[0] : 'İsimsiz Kullanıcı');
  }

  // UID ile kullanıcı profil bilgilerini getir
  static Future<Map<String, dynamic>?> getUserProfileByUid(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('profiller')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        final userData = doc.data()!;
        return {
          'uid': doc.id,
          'email': userData['email'] ?? '',
          'displayName': _getUserDisplayName(userData),
          'photoURL': userData['photoURL'],
          'createdAt': userData['createdAt'],
          'updatedAt': userData['updatedAt'],
        };
      }
      return null;
    } catch (e) {
      print('❌ HATA - Kullanıcı profili getirilemedi: $e');
      return null;
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
          'displayName': _getUserDisplayName(userData),
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

  /// Ana sahip (creator) tarafından hayvanı silme
  static Future<void> deletePetByCreator(String petId) async {
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
      final creatorId = petData['creator'] as String?;

      // Sadece hayvanın yaratıcısı silebilir
      if (creatorId != currentUser.uid) {
        throw Exception('Bu hayvanı silme yetkiniz yok. Sadece hayvanın ana sahibi silebilir.');
      }
      
      // Hayvanı sil
      await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).delete();
      
      // İlgili mesajları da sil
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('pet_messages')
          .where('petId', isEqualTo: petId)
          .get();
      
      for (final doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Eş sahip isteklerini de sil
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .where('petId', isEqualTo: petId)
          .get();
      
      for (final doc in requestsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      print('✅ Hayvan ve ilgili tüm veriler silindi');
    } catch (e) {
      print('❌ HATA - Hayvan silinemedi: $e');
      
      // Hata türüne göre özel mesajlar
      if (e.toString().contains('permission-denied')) {
        throw Exception('Yetki hatası: Bu işlemi gerçekleştirmek için gerekli izinleriniz yok. Lütfen tekrar giriş yapın veya uygulama ayarlarını kontrol edin.');
      } else if (e.toString().contains('not-found')) {
        throw Exception('Hayvan bulunamadı. Lütfen sayfayı yenileyin.');
      } else {
        throw Exception('Hayvan silinirken beklenmeyen bir hata oluştu: ${e.toString()}');
      }
    }
  }

  /// Eş sahip olarak kendini kaldırma (sahipliği bırakma)
  static Future<void> leavePetOwnership(String petId) async {
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
        throw Exception('Bu hayvandan sahiplik bırakma yetkiniz yok. Zaten sahip değilsiniz.');
      }

      // Ana sahip (creator) sahipliği bırakamaz
      if (creatorId == currentUser.uid) {
        throw Exception('Ana sahip olarak sahipliği bırakamazsınız. Önce hayvanı silmeniz gerekiyor.');
      }

      // En az bir sahip kalmalı
      if (ownerIds.length <= 1) {
        throw Exception('Sahipliği bırakamazsınız. En az bir sahip kalmalı.');
      }
      
      // Kendini hayvandan kaldır
      await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).update({
        'owners': FieldValue.arrayRemove([currentUser.uid])
      });
      
      print('✅ Sahiplik bırakıldı');
    } catch (e) {
      print('❌ HATA - Sahiplik bırakılamadı: $e');
      
      // Hata türüne göre özel mesajlar
      if (e.toString().contains('permission-denied')) {
        throw Exception('Yetki hatası: Bu işlemi gerçekleştirmek için gerekli izinleriniz yok. Lütfen tekrar giriş yapın veya uygulama ayarlarını kontrol edin.');
      } else if (e.toString().contains('not-found')) {
        throw Exception('Hayvan bulunamadı. Lütfen sayfayı yenileyin.');
      } else {
        throw Exception('Sahiplik bırakılırken beklenmeyen bir hata oluştu: ${e.toString()}');
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Kullanıcı oturumu yok');
    
    try {
      
      print('🔍 Mesajlar getiriliyor - Pet ID: $petId, User ID: ${user.uid}');
      
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('pet_messages')
          .where('petId', isEqualTo: petId)
          .orderBy('createdAt', descending: false) // Client timestamp ile sırala
          .get();
      
      print('📊 Firestore\'dan ${messagesSnapshot.docs.length} mesaj alındı');
      
      final messages = messagesSnapshot.docs.map((doc) {
        final data = doc.data();
        print('📝 Mesaj verisi: ${doc.id} - ${data['message']} - ${data['timestamp']}');
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
      
      print('✅ ${messages.length} mesaj işlendi ve döndürülüyor');
      return messages;
      
    } catch (e) {
      print('❌ HATA - Mesajlar getirilemedi: $e');
      
      // Index hatası varsa, sadece petId ile getir (timestamp olmadan)
      if (e.toString().contains('failed-precondition') || e.toString().contains('requires an index')) {
        print('⚠️ Index hatası, timestamp olmadan getiriliyor...');
        try {
          final messagesSnapshot = await FirebaseFirestore.instance
              .collection('pet_messages')
              .where('petId', isEqualTo: petId)
              .get();
          
          final messages = messagesSnapshot.docs.map((doc) {
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
              'createdAt': data['createdAt'], // Client timestamp ekle
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
          
          // Client timestamp'e göre manuel sıralama
          messages.sort((a, b) {
            final aTime = a['createdAt'] as dynamic;
            final bTime = b['createdAt'] as dynamic;
            if (aTime == null || bTime == null) return 0;
            return aTime.compareTo(bTime); // Ascending (eski mesajlar üstte)
          });
          
          print('✅ Index hatası sonrası ${messages.length} mesaj getirildi');
          return messages;
        } catch (fallbackError) {
          print('❌ Fallback de başarısız: $fallbackError');
          return [];
        }
      }
      
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
          .orderBy('createdAt', descending: false) // Client timestamp ile sırala
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
          'createdAt': data['createdAt'], // Client timestamp ekle
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
      print('📤 Eş sahip isteği gönderme başlatıldı - PetID: $petId, Email: $email');
      
      // Mevcut kullanıcıyı kontrol et
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu yok. Lütfen tekrar giriş yapın.');
      }
      print('✅ Kullanıcı oturumu doğrulandı: ${currentUser.uid}');

      // Hayvan dokümanını getir ve yetkiyi kontrol et
      print('🔍 Hayvan dökümanı aranıyor: $petId');
      final petDoc = await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).get();
      if (!petDoc.exists) {
        throw Exception('Hayvan bulunamadı. PetID: $petId');
      }
      print('✅ Hayvan bulundu');

      final petData = petDoc.data()!;
      final petName = petData['name'] ?? 'İsimsiz Hayvan';
      final ownerIds = List<String>.from(petData['owners'] ?? []);
      print('📋 Hayvan sahibi sayısı: ${ownerIds.length}, Sahip IDs: $ownerIds');

      // Kullanıcının bu hayvana sahip olup olmadığını kontrol et
      if (!ownerIds.contains(currentUser.uid)) {
        throw Exception('Bu hayvana eş sahip isteği gönderme yetkiniz yok. Sadece hayvan sahipleri eş sahip isteği gönderebilir.');
      }
      print('✅ Sahip yetki kontrolü geçti');

      // Email ile kullanıcıyı bul
      print('🔍 Email ile kullanıcı aranıyor: $email');
      
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('profiller')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      print('📊 Bulunan kullanıcı sayısı: ${usersSnapshot.docs.length}');
      
      if (usersSnapshot.docs.isEmpty) {
        print('❌ Email ile kullanıcı bulunamadı: $email');
        throw Exception('Bu email adresi ile kayıtlı kullanıcı bulunamadı. Kullanıcının önce uygulamaya kayıtlı olması gerekiyor.');
      }
      
      final userDoc = usersSnapshot.docs.first;
      final userId = userDoc.id;
      final userData = userDoc.data();
      print('✅ Kullanıcı bulundu: ${userData['name'] ?? 'İsimsiz'} ($userId)');
      
      // Kendine istek göndermeye çalışıyorsa engelle
      if (userId == currentUser.uid) {
        throw Exception('Kendinize eş sahip isteği gönderemezsiniz.');
      }
      print('✅ Kendi kendine istek engeli kontrol geçti');

      // Kullanıcı zaten eş sahip mi kontrol et
      if (ownerIds.contains(userId)) {
        throw Exception('Bu kullanıcı zaten eş sahip.');
      }
      print('✅ Zaten eş sahip kontrolü geçti');

      // Zaten bekleyen istek var mı kontrol et
      print('🔍 Bekleyen istek kontrolü yapılıyor...');
      final existingRequest = await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .where('petId', isEqualTo: petId)
          .where('requestedUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();
      
      if (existingRequest.docs.isNotEmpty) {
        throw Exception('Bu kullanıcıya zaten eş sahip isteği gönderilmiş.');
      }
      print('✅ Bekleyen istek yok');
      
      // Reddedilen istek varsa sil (tekrar istek atılabilmesi için)
      print('🔍 Reddedilen istek kontrol ediliyor...');
      final rejectedRequest = await FirebaseFirestore.instance
          .collection('co_owner_requests')
          .where('petId', isEqualTo: petId)
          .where('requestedUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'rejected')
          .get();
      
      for (final doc in rejectedRequest.docs) {
        await doc.reference.delete();
        print('🗑️ Reddedilen istek silindi: ${doc.id}');
      }
      
      // İsteği kaydet
      print('📝 İstek kaydediliyor...');
      await FirebaseFirestore.instance.collection('co_owner_requests').add({
        'petId': petId,
        'petName': petName,
        'requesterId': currentUser.uid,
        'requesterName': currentUser.displayName ?? 'İsimsiz Kullanıcı',
        'requesterEmail': currentUser.email ?? '',
        'requestedUserId': userId,
        'requestedUserEmail': email,
        'status': 'pending', // pending, accepted, rejected
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Bu hayvana eş sahip olmak ister misiniz?',
      });
      
      print('✅ Eş sahip isteği başarıyla gönderildi: $email -> $petName');
    } catch (e) {
      print('❌ HATA - Eş sahip isteği gönderilemedi: $e');
      rethrow;
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

  /// Eş sahip mesajlaşma metodları
  static Future<void> sendCoOwnerMessage(
    String petId,
    String message,
    String messageType, {
    File? imageFile,
    String? caption,
    int? durationSeconds,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      print('🔍 Pet bilgileri alınıyor - Pet ID: $petId');
      
      // Önce pet bilgilerini al
      final petDoc = await FirebaseFirestore.instance.collection('hayvanlar').doc(petId).get();
      if (!petDoc.exists) throw Exception('Hayvan bulunamadı');
      
      final petData = petDoc.data()!;
      final petName = petData['name'] ?? 'İsimsiz Hayvan';
      final ownerIds = List<String>.from(petData['owners'] ?? [currentUser.uid]);
      
      print('📋 Pet bilgileri: $petName, Sahipler: $ownerIds');
      
      final now = DateTime.now();
      final messageData = {
        'petId': petId,
        'petName': petName,
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'İsimsiz Kullanıcı',
        'senderEmail': currentUser.email ?? '',
        'message': message,
        'messageType': messageType,
        'timestamp': FieldValue.serverTimestamp(), // Server timestamp kullan
        'caption': caption,
        'durationSeconds': durationSeconds,
        'recipients': ownerIds, // Tüm sahipleri recipients olarak ekle
        'type': 'co_owner_message',
        'createdAt': now.millisecondsSinceEpoch, // Client timestamp ekle
        'clientTimestamp': now.toIso8601String(), // ISO string olarak da ekle
        'isOptimistic': true, // Optimistic update için flag
        'status': 'sent', // Mesaj durumu
        'localId': 'temp_${now.millisecondsSinceEpoch}', // Local ID ekle
        'isLocal': true, // Local mesaj flag'i
        'isPending': false, // Pending durumu
        'isDelivered': false, // Delivery durumu
        'isRead': false, // Read durumu
        'isArchived': false, // Archive durumu
        'isDeleted': false, // Delete durumu
        'isFlagged': false, // Flag durumu
        'isSpam': false, // Spam durumu
        'isBlocked': false, // Block durumu
        'isMuted': false, // Mute durumu
        'isHidden': false, // Hide durumu
        'isPinned': false, // Pin durumu
        'isForwarded': false, // Forward durumu
        'isReplied': false, // Reply durumu
        'isEdited': false, // Edit durumu
        'isStarred': false, // Star durumu
      };

      print('📝 Mesaj verisi hazırlandı: $messageData');

      // Eğer resim dosyası varsa, önce yükle
      if (imageFile != null) {
        // Resim yükleme işlemi burada yapılacak
        // Şimdilik sadece caption'ı gönderelim
        messageData['imageUrl'] = 'placeholder_image_url';
        messageData['message'] = caption ?? 'Görsel mesaj';
      }
      
      // Eğer sesli mesaj varsa
      if (durationSeconds != null) {
        messageData['audioUrl'] = 'placeholder_audio_url';
        messageData['message'] = 'Sesli mesaj';
      }

      print('💾 Mesaj Firestore\'a kaydediliyor...');
      
      final docRef = await FirebaseFirestore.instance
          .collection('pet_messages')
          .add(messageData);
          
      print('✅ Mesaj başarıyla kaydedildi - Doc ID: ${docRef.id}');

      // Pet dokümanına son mesaj bilgisini güncelle
      await FirebaseFirestore.instance
          .collection('hayvanlar')
          .doc(petId)
          .update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      
      print('✅ Pet dokümanı güncellendi');

    } catch (e) {
      print('❌ HATA - Eş sahip mesajı gönderilemedi: $e');
      if (e.toString().contains('not-found')) {
        throw Exception('Hayvan bulunamadı. Lütfen sayfayı yenileyin.');
      } else {
        throw Exception('Mesaj gönderilirken hata: $e');
      }
    }
  }

  /// Eş sahip mesajlarını real-time olarak dinle
  static Stream<List<Map<String, dynamic>>> streamCoOwnerMessages(String petId) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu yok');
      
      print('🔄 Stream başlatılıyor - Pet ID: $petId, User ID: ${user.uid}');
      
      return FirebaseFirestore.instance
          .collection('pet_messages')
          .where('petId', isEqualTo: petId)
          .orderBy('createdAt', descending: false) // Client timestamp ile sırala
          .snapshots(includeMetadataChanges: false) // Sadece document değişikliklerini dinle
          .map((snapshot) {
        print('📨 Stream\'den ${snapshot.docs.length} mesaj alındı');
        return snapshot.docs.map((doc) {
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
            'createdAt': data['createdAt'], // Client timestamp ekle
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
      }).handleError((error) {
        print('❌ Stream hatası: $error');
        // Hata durumunda manuel olarak mesajları getir
        return getCoOwnerMessages(petId);
      });
    } catch (e) {
      print('❌ HATA - Mesaj stream\'i oluşturulamadı: $e');
      // Hata durumunda manuel olarak mesajları getir
      return Stream.fromFuture(getCoOwnerMessages(petId));
    }
  }


}
