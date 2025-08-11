import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../secrets.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      print('✅ Firebase başlatıldı');
      
      // Firebase Auth'u temizle
      await FirebaseAuth.instance.signOut();
      print('✅ Firebase Auth temizlendi');
      
      // Firebase güvenlik kurallarını kontrol et
      await _checkFirebaseSecurity();
    } catch (e) {
      print('❌ Firebase başlatma hatası: $e');
      rethrow;
    }
  }

  static Future<void> _checkFirebaseSecurity() async {
    try {
      // Firestore bağlantısını test et
      await FirebaseFirestore.instance.collection('test').limit(1).get();
      print('✅ Firebase bağlantısı başarılı');
    } catch (e) {
      print('⚠️ Firebase güvenlik uyarısı: $e');
      print('📝 Firebase Console\'da güvenlik kurallarını kontrol edin');
    }
  }

  static String getApiKey() {
    return Secrets.firebaseApiKey;
  }

  static bool isProduction() {
    // Production ortamında ek güvenlik kontrolleri
    return const bool.fromEnvironment('dart.vm.product');
  }
} 