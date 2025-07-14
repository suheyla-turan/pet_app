import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Auth state değişikliklerini dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/şifre ile kayıt ol
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔄 Kayıt işlemi başlatılıyor: $email');
      
      // Mevcut oturumu temizle
      if (_auth.currentUser != null) {
        await _auth.signOut();
        print('✅ Mevcut oturum temizlendi');
      }
      
      // Kısa bir bekleme süresi ekle
      await Future.delayed(Duration(milliseconds: 500));
      
      // Sadece temel kayıt işlemi yap
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase Auth kayıt başarılı');

      // Kullanıcı bilgilerini Firestore'a kaydet
      try {
        await _firestore.collection('profiller').doc(result.user!.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'photoURL': null,
        });
        print('✅ Firestore kayıt başarılı');
      } catch (firestoreError) {
        print('⚠️ Firestore kayıt hatası: $firestoreError');
        // Firestore hatası kritik değil, devam et
      }

      // Display name güncellemesini daha sonra yap
      _updateDisplayNameLater(result.user!, name);

      print('✅ Kayıt işlemi tamamlandı');
      return result;
    } catch (e) {
      print('❌ Kayıt hatası: $e');
      
      // PigeonUserDetails hatası için özel işlem
      if (e.toString().contains('PigeonUserDetails')) {
        print('⚠️ PigeonUserDetails hatası tespit edildi, kullanıcı bilgilerini kontrol et');
        
        // Kullanıcı oluşturulmuş olabilir, kontrol et
        try {
          final currentUser = _auth.currentUser;
          if (currentUser != null) {
            print('✅ Kullanıcı başarıyla oluşturuldu: ${currentUser.uid}');
            
            // Firestore'a kaydetmeyi tekrar dene
            try {
              await _firestore.collection('profiller').doc(currentUser.uid).set({
                'name': name,
                'email': email,
                'createdAt': FieldValue.serverTimestamp(),
                'photoURL': null,
              });
              print('✅ Firestore kayıt başarılı (ikinci deneme)');
            } catch (firestoreError) {
              print('⚠️ Firestore kayıt hatası (ikinci deneme): $firestoreError');
            }
            
            // Başarılı olarak kabul et
            print('✅ PigeonUserDetails hatası atlandı, kayıt başarılı');
            return null; // Kullanıcı zaten oluşturuldu, null döndür
          }
        } catch (checkError) {
          print('⚠️ Kullanıcı kontrol hatası: $checkError');
        }
      }
      
      rethrow;
    }
  }

  // Display name güncellemesini ayrı bir fonksiyonda yap
  void _updateDisplayNameLater(User user, String name) async {
    try {
      // Biraz bekle ve sonra güncelle
      await Future.delayed(Duration(seconds: 2));
      await user.updateDisplayName(name);
      print('✅ Display name güncellendi');
    } catch (displayNameError) {
      print('⚠️ Display name güncellenemedi: $displayNameError');
      // Bu hata kritik değil
    }
  }

  // Email/şifre ile giriş yap
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('❌ Giriş hatası: $e');
      rethrow;
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('❌ Çıkış hatası: $e');
      rethrow;
    }
  }

  // Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('❌ Şifre sıfırlama hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı bilgilerini güncelle
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (currentUser != null) {
        // Firebase Auth'ta güncelle
        if (displayName != null && displayName.trim().isNotEmpty) {
          await currentUser!.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await currentUser!.updatePhotoURL(photoURL);
        }
        // Firestore'da güncelle veya oluştur
        final dataToUpdate = <String, dynamic>{
          if (displayName != null && displayName.trim().isNotEmpty) 'name': displayName.trim(),
          if (photoURL != null) 'photoURL': photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        print('Firestore profiller güncellemesi: ${currentUser!.uid} => $dataToUpdate');
        await _firestore.collection('profiller').doc(currentUser!.uid).set(
          dataToUpdate,
          SetOptions(merge: true),
        );
        print('✅ Firestore profil güncelleme başarılı');
      }
    } catch (e) {
      print('❌ Profil güncelleme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı bilgilerini getir
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser != null) {
        DocumentSnapshot doc = await _firestore
            .collection('profiller')
            .doc(currentUser!.uid)
            .get();
        
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('❌ Kullanıcı bilgileri getirme hatası: $e');
      return null;
    }
  }

  // Tüm kullanıcı verilerini sil (Admin fonksiyonu)
  Future<void> deleteAllUserData() async {
    try {
      print('🗑️ Tüm kullanıcı verileri siliniyor...');
      
      // Firestore'dan tüm profilleri sil
      QuerySnapshot querySnapshot = await _firestore.collection('profiller').get();
      for (DocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
        print('✅ Silindi: ${doc.id}');
      }
      
      print('✅ Tüm kullanıcı verileri silindi');
    } catch (e) {
      print('❌ Veri silme hatası: $e');
      rethrow;
    }
  }

  // Mevcut kullanıcıyı ve verilerini sil
  Future<void> deleteCurrentUser() async {
    try {
      if (currentUser != null) {
        // Firestore'dan profil verilerini sil
        await _firestore.collection('profiller').doc(currentUser!.uid).delete();
        print('✅ Profil verileri silindi');
        
        // Firebase Auth'dan kullanıcıyı sil
        await currentUser!.delete();
        print('✅ Kullanıcı silindi');
      }
    } catch (e) {
      print('❌ Kullanıcı silme hatası: $e');
      rethrow;
    }
  }
} 