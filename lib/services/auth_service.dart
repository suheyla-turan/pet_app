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
          'emailVerified': false, // E-posta doğrulama durumu ekle
        });
        print('✅ Firestore kayıt başarılı');
      } catch (firestoreError) {
        print('⚠️ Firestore kayıt hatası: $firestoreError');
        // Firestore hatası kritik değil, devam et
      }

      // E-posta doğrulama gönder
      try {
        await result.user!.sendEmailVerification();
        print('✅ E-posta doğrulama gönderildi');
      } catch (verificationError) {
        print('⚠️ E-posta doğrulama gönderme hatası: $verificationError');
      }

      // Display name güncellemesini daha sonra yap
      _updateDisplayNameLater(result.user!, name);

      // Kayıt başarılı olduktan sonra otomatik olarak çıkış yap
      // Böylece kullanıcı giriş ekranına yönlendirilir
      await Future.delayed(Duration(milliseconds: 1000)); // Kısa bir bekleme
      await _auth.signOut();
      print('✅ Kayıt sonrası otomatik çıkış yapıldı, giriş ekranına yönlendiriliyor');

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
            
            // Başarılı olarak kabul et ve çıkış yap
            await Future.delayed(Duration(milliseconds: 1000));
            await _auth.signOut();
            print('✅ PigeonUserDetails hatası atlandı, kayıt başarılı ve çıkış yapıldı');
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
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // E-posta doğrulama kontrolü
      if (result.user != null && !result.user!.emailVerified) {
        // E-posta doğrulanmamışsa oturumu kapat
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'E-posta adresiniz henüz doğrulanmamış. Lütfen e-postanızı kontrol edin.',
        );
      }
      
      return result;
    } catch (e) {
      print('❌ Giriş hatası: $e');
      
      // Yanlış şifre veya kullanıcı bulunamadı durumunda mevcut oturumu temizle
      if (e.toString().contains('wrong-password') || e.toString().contains('user-not-found')) {
        try {
          if (_auth.currentUser != null) {
            await _auth.signOut();
            print('✅ Yanlış giriş bilgileri nedeniyle mevcut oturum temizlendi');
          }
        } catch (signOutError) {
          print('⚠️ Oturum temizleme hatası: $signOutError');
        }
      }
      
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

  // E-posta doğrulama gönder
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('✅ E-posta doğrulama gönderildi');
      } else if (user?.emailVerified == true) {
        print('ℹ️ E-posta zaten doğrulanmış');
      } else {
        print('❌ Kullanıcı bulunamadı');
      }
    } catch (e) {
      print('❌ E-posta doğrulama gönderme hatası: $e');
      rethrow;
    }
  }

  // E-posta doğrulama durumunu kontrol et
  bool isEmailVerified() {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  // E-posta doğrulama durumunu yenile
  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        print('✅ Kullanıcı bilgileri yenilendi');
      }
    } catch (e) {
      print('❌ Kullanıcı yenileme hatası: $e');
    }
  }

  // E-posta doğrulandıktan sonra otomatik çıkış yap
  Future<void> signOutAfterVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        // E-posta doğrulanmışsa Firestore'u güncelle
        await updateEmailVerificationStatus();
        
        // Kısa bir bekleme sonrası çıkış yap
        await Future.delayed(Duration(seconds: 2));
        await _auth.signOut();
        print('✅ E-posta doğrulama sonrası otomatik çıkış yapıldı, giriş ekranına yönlendiriliyor');
      }
    } catch (e) {
      print('❌ E-posta doğrulama sonrası çıkış hatası: $e');
    }
  }

  // Doğrulanmamış e-posta ile giriş yapmaya çalışan kullanıcıyı otomatik çıkış yap
  Future<void> signOutUnverifiedUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        print('⚠️ Doğrulanmamış e-posta ile giriş yapmaya çalışıldı, otomatik çıkış yapılıyor');
        await _auth.signOut();
        print('✅ Doğrulanmamış kullanıcı otomatik çıkış yapıldı, giriş ekranına yönlendiriliyor');
      }
    } catch (e) {
      print('❌ Doğrulanmamış kullanıcı çıkış hatası: $e');
    }
  }

  // E-posta doğrulama durumunu dinle
  Stream<bool> get emailVerificationStream {
    return _auth.authStateChanges().map((user) => user?.emailVerified ?? false);
  }

  // Kullanıcının uygulamaya erişim izni var mı kontrol et
  bool canUserAccessApp() {
    final user = _auth.currentUser;
    return user != null && user.emailVerified;
  }

  // Uygulama açıldığında e-posta doğrulama durumunu kontrol et
  Future<void> checkEmailVerificationOnAppStart() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        print('⚠️ Uygulama başlangıcında: E-posta doğrulanmamış, otomatik çıkış yapılıyor');
        await _auth.signOut();
        print('✅ Uygulama başlangıcında doğrulanmamış kullanıcı çıkış yapıldı');
      }
    } catch (e) {
      print('❌ Uygulama başlangıcında e-posta doğrulama kontrol hatası: $e');
    }
  }

  // E-posta doğrulama durumunu güncelle (Firestore'da)
  Future<void> updateEmailVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        await _firestore.collection('profiller').doc(user.uid).update({
          'emailVerified': true,
          'emailVerifiedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Firestore e-posta doğrulama durumu güncellendi');
      }
    } catch (e) {
      print('⚠️ Firestore e-posta doğrulama durumu güncelleme hatası: $e');
    }
  }

  // Kullanıcı bilgilerini yenile ve e-posta doğrulama durumunu kontrol et
  Future<void> reloadAndCheckEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        print('✅ Kullanıcı bilgileri yenilendi');
        
        // E-posta doğrulandıysa Firestore'u güncelle
        if (user.emailVerified) {
          await updateEmailVerificationStatus();
        }
      }
    } catch (e) {
      print('❌ Kullanıcı yenileme ve e-posta doğrulama kontrol hatası: $e');
    }
  }
} 