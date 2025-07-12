import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../secrets.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Firebase güvenlik kurallarını kontrol et
    await _checkFirebaseSecurity();
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
    return firebaseApiKey;
  }

  static bool isProduction() {
    // Production ortamında ek güvenlik kontrolleri
    return const bool.fromEnvironment('dart.vm.product');
  }
} 