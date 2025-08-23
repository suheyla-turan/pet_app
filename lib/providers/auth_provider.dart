import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null && _user!.emailVerified;
  bool get isLoggedInButNotVerified => _user != null && !_user!.emailVerified;

  AuthProvider() {
    _init();
    _startEmailVerificationCheck();
    _checkEmailVerificationOnAppStart();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      
      // Eğer kullanıcı giriş yapmış ama e-posta doğrulanmamışsa otomatik çıkış yap
      if (user != null && !user.emailVerified) {
        print('⚠️ Auth state değişikliği: Doğrulanmamış e-posta ile giriş yapıldı, otomatik çıkış yapılıyor');
        // Kısa bir bekleme sonrası otomatik çıkış yap
        Future.delayed(Duration(milliseconds: 1000), () {
          signOutUnverifiedUser();
        });
      }
      
      notifyListeners();
    });
  }

  // Uygulama açıldığında e-posta doğrulama durumunu kontrol et
  Future<void> _checkEmailVerificationOnAppStart() async {
    try {
      await _authService.checkEmailVerificationOnAppStart();
    } catch (e) {
      print('⚠️ Uygulama başlangıcında e-posta doğrulama kontrol hatası: $e');
    }
  }

  // E-posta doğrulama durumunu periyodik olarak kontrol et
  void _startEmailVerificationCheck() {
    // Her 30 saniyede bir e-posta doğrulama durumunu kontrol et
    Future.delayed(Duration(seconds: 30), () {
      if (_user != null && !_user!.emailVerified) {
        // E-posta doğrulanmamışsa otomatik çıkış yap
        print('⚠️ Periyodik kontrol: E-posta doğrulanmamış, otomatik çıkış yapılıyor');
        signOutUnverifiedUser();
        _startEmailVerificationCheck(); // Tekrar başlat
      } else {
        _startEmailVerificationCheck(); // Tekrar başlat
      }
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final result = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      
      // PigeonUserDetails hatası durumunda result null olabilir ama kullanıcı oluşturulmuş olabilir
      if (result == null && _authService.currentUser != null) {
        print('✅ Kayıt başarılı (PigeonUserDetails hatası atlandı)');
        // Kullanıcı otomatik olarak çıkış yapıldı, giriş ekranına yönlendirilecek
        return true;
      }
      
      // Kayıt başarılı olduktan sonra kullanıcı otomatik olarak çıkış yapıldı
      // Bu sayede giriş ekranına yönlendirilecek
      return result != null;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      
      // Yanlış şifre veya kullanıcı bulunamadı durumunda
      // kullanıcı zaten giriş ekranında kalacak
      if (e.toString().contains('wrong-password') || 
          e.toString().contains('user-not-found') ||
          e.toString().contains('email-not-verified')) {
        print('⚠️ Giriş hatası: $e - Kullanıcı giriş ekranında kalacak');
      }
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signOut() async {
    try {
      _setLoading(true);
      clearError();
      await _authService.signOut();
      
      // Çıkış yapıldıktan sonra kullanıcı otomatik olarak giriş ekranına yönlendirilecek
      // RootPage widget'ı auth state değişikliğini dinleyerek yönlendirme yapacak
      print('✅ Çıkış yapıldı, giriş ekranına yönlendiriliyor');
      
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      
      // Kullanıcıyı yeniden yükle
      await _user?.reload();
      _user = _authService.currentUser;
      notifyListeners();

      return true;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _getErrorMessage(String error) {
    print('🔍 Hata detayı: $error');
    
    if (error.contains('weak-password')) {
      return 'Şifre çok zayıf. Daha güçlü bir şifre seçin.';
    } else if (error.contains('email-already-in-use')) {
      return 'Bu email adresi zaten kullanımda.';
    } else if (error.contains('user-not-found')) {
      return 'Bu email adresi ile kayıtlı kullanıcı bulunamadı.';
    } else if (error.contains('wrong-password')) {
      return 'Hatalı şifre.';
    } else if (error.contains('invalid-email')) {
      return 'Geçersiz email adresi.';
    } else if (error.contains('too-many-requests')) {
      return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
    } else if (error.contains('email-not-verified')) {
      return 'E-posta adresiniz henüz doğrulanmamış. Lütfen e-postanızı kontrol edin.';
    } else if (error.contains('PigeonUserDetails')) {
      return 'Kullanıcı bilgileri işlenirken hata oluştu. Lütfen tekrar deneyin.';
    } else if (error.contains('network')) {
      return 'İnternet bağlantısı sorunu. Lütfen bağlantınızı kontrol edin.';
    } else {
      return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  void clearError() {
    _setError(null);
  }

  Future<void> deleteAllUserData() async {
    try {
      _setLoading(true);
      await _authService.deleteAllUserData();
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // E-posta doğrulama gönder
  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // E-posta doğrulama durumunu kontrol et
  bool get isEmailVerified => _authService.isEmailVerified();

  // Kullanıcı bilgilerini yenile
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
    }
  }

  // E-posta doğrulama durumunu dinle
  Stream<bool> get emailVerificationStream => _authService.emailVerificationStream;

  // E-posta doğrulandıktan sonra otomatik çıkış yap
  Future<void> signOutAfterVerification() async {
    try {
      await _authService.signOutAfterVerification();
      // Auth state değişikliği otomatik olarak dinlenecek
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
    }
  }

  // Doğrulanmamış e-posta ile giriş yapmaya çalışan kullanıcıyı otomatik çıkış yap
  Future<void> signOutUnverifiedUser() async {
    try {
      await _authService.signOutUnverifiedUser();
      // Auth state değişikliği otomatik olarak dinlenecek
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
    }
  }

  // Kullanıcıyı yenile ve e-posta doğrulama durumunu kontrol et
  Future<void> checkEmailVerification() async {
    try {
      await _authService.reloadAndCheckEmailVerification();
      _user = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e.toString()));
    }
  }
} 