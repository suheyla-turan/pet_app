import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import 'package:pati_takip/l10n/app_localizations.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-posta Doğrulama'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, // Şeffaf app bar - sayfa arka planı ile uyumlu
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        automaticallyImplyLeading: false,
      ),
              body: Container(
        decoration: BoxDecoration(
          gradient: Provider.of<ThemeProvider>(context).getBackgroundGradient(
            Theme.of(context).brightness == Brightness.dark
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // E-posta doğrulama ikonu
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 60,
                      color: Colors.blue[600],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Başlık
                  const Text(
                    'E-posta Adresinizi Doğrulayın',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Açıklama
                  Text(
                    'Kayıt olduktan sonra e-posta adresinize bir doğrulama bağlantısı gönderdik. '
                    'Lütfen e-postanızı kontrol edin ve bağlantıya tıklayın. '
                    'Doğrulama tamamlandıktan sonra giriş ekranına yönlendirileceksiniz.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // E-posta adresi
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final email = authProvider.user?.email ?? '';
                      return Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.email_outlined, color: Colors.grey[600]),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                email,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Doğrulama kontrol et butonu
                  ElevatedButton(
                    onPressed: _isChecking ? null : _checkVerification,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.green[600],
                    ),
                    child: _isChecking
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Doğrulamayı Kontrol Et ve Giriş Ekranına Git',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tekrar gönder butonu
                  OutlinedButton(
                    onPressed: _isResending ? null : _resendVerification,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      side: BorderSide(color: Colors.blue[600]!),
                    ),
                    child: _isResending
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue[600],
                            ),
                          )
                        : Text(
                            'Tekrar Gönder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[600],
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Çıkış yap butonu
                  TextButton(
                    onPressed: _signOut,
                    child: Text(
                      'Çıkış Yap',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Bilgi metni
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600]),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'E-posta doğrulandıktan sonra giriş ekranına yönlendirileceksiniz. Lütfen doğrulama yapıp tekrar giriş yapın.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Doğrulama durumunu kontrol et
  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkEmailVerification();
      
      if (mounted) {
        if (authProvider.isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ E-posta doğrulandı! Giriş ekranına yönlendiriliyorsunuz...'),
              backgroundColor: Colors.green[600],
            ),
          );
          
          // Otomatik çıkış yap ve giriş ekranına yönlendir
          await authProvider.signOutAfterVerification();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ E-posta henüz doğrulanmamış. Lütfen e-postanızı kontrol edin.'),
              backgroundColor: Colors.orange[600],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Bir hata oluştu: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  // Doğrulama e-postasını tekrar gönder
  Future<void> _resendVerification() async {
    setState(() => _isResending = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendEmailVerification();
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Doğrulama e-postası tekrar gönderildi!'),
              backgroundColor: Colors.green[600],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ E-posta gönderilemedi. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.red[600],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Bir hata oluştu: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  // Çıkış yap
  Future<void> _signOut() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Çıkış yapılırken hata oluştu: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }
}
