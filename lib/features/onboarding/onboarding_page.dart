import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToAuth() {
    _pageController.animateToPage(4, duration: Duration(milliseconds: 400), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _OnboardingInfo(
                    title: 'Mini Pet Uygulamasına Hoşgeldiniz!',
                    description: 'Evcil dostlarınızın bakımını kolayca takip edin.',
                    lottieAsset: 'assets/golden.json',
                    buttonText: 'İleri',
                    onButton: () => _pageController.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.ease),
                  ),
                  _OnboardingInfo(
                    title: 'Evcil Hayvanlarını Ekle',
                    description: 'Kedi, köpek veya diğer dostlarını uygulamaya ekle, bilgilerini kaydet.',
                    lottieAsset: 'assets/golden.json',
                    buttonText: 'İleri',
                    onButton: () => _pageController.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.ease),
                  ),
                  _OnboardingInfo(
                    title: 'Aşı ve Bakım Takibi',
                    description: 'Aşı, mama, sağlık ve bakım zamanlarını unutma, bildirim al.',
                    lottieAsset: 'assets/golden.json',
                    buttonText: 'İleri',
                    onButton: () => _pageController.animateToPage(3, duration: Duration(milliseconds: 400), curve: Curves.ease),
                  ),
                  _OnboardingInfo(
                    title: 'Profil ve Geçmiş',
                    description: 'Tüm sağlık geçmişi ve profil bilgileri her zaman yanında.',
                    lottieAsset: 'assets/golden.json',
                    buttonText: 'Başla',
                    onButton: _goToAuth,
                  ),
                  // Auth ekranları
                  LoginScreen(
                    onRegisterTap: () => _pageController.animateToPage(5, duration: Duration(milliseconds: 400), curve: Curves.ease),
                  ),
                  RegisterScreen(
                    onLoginTap: () => _pageController.animateToPage(4, duration: Duration(milliseconds: 400), curve: Curves.ease),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 6,
                effect: WormEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                ),
                onDotClicked: (index) {
                  if (index < 4) {
                    _pageController.animateToPage(index, duration: Duration(milliseconds: 400), curve: Curves.ease);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingInfo extends StatelessWidget {
  final String title;
  final String description;
  final String lottieAsset;
  final String buttonText;
  final VoidCallback onButton;
  const _OnboardingInfo({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.buttonText,
    required this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              lottieAsset,
              width: 180,
              height: 180,
              repeat: true,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.pets, size: 120, color: Colors.amber),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: onButton,
              style: ElevatedButton.styleFrom(minimumSize: Size(140, 44)),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onRegisterTap;
  const LoginScreen({super.key, required this.onRegisterTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  bool _obscure = true;
  bool _resetLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Giriş Yap', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                SizedBox(height: 24),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) => email = v,
                  validator: (v) => v != null && v.contains('@') ? null : 'Geçerli email girin',
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  obscureText: _obscure,
                  onChanged: (v) => password = v,
                  validator: (v) => v != null && v.length >= 6 ? null : 'En az 6 karakter',
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                      );
                    },
                    child: Text('Şifremi Unuttum?'),
                  ),
                ),
                if (_resetLoading)
                 Center(child: Padding(
                   padding: EdgeInsets.only(bottom: 8),
                   child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                 )),
                if (authProvider.errorMessage != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(child: Text(authProvider.errorMessage!, style: TextStyle(color: Colors.red[900]))),
                      ],
                    ),
                  ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await authProvider.signIn(email: email, password: password);
                            if (success && context.mounted) {
                              FocusScope.of(context).unfocus();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(minimumSize: Size(160, 48)),
                  child: authProvider.isLoading
                      ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Giriş Yap'),
                ),
                SizedBox(height: 12),
                OutlinedButton(
                  onPressed: authProvider.isLoading ? null : widget.onRegisterTap,
                  child: Text('Hesabınız yok mu? Kayıt Ol'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginTap;
  const RegisterScreen({super.key, required this.onLoginTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '', name = '';
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Kayıt Ol', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                SizedBox(height: 24),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'İsim',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => name = v,
                  validator: (v) => v != null && v.length >= 2 ? null : 'İsim girin',
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) => email = v,
                  validator: (v) => v != null && v.contains('@') ? null : 'Geçerli email girin',
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  obscureText: _obscure,
                  onChanged: (v) => password = v,
                  validator: (v) => v != null && v.length >= 6 ? null : 'En az 6 karakter',
                ),
                if (authProvider.errorMessage != null)
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(child: Text(authProvider.errorMessage!, style: TextStyle(color: Colors.red[900]))),
                      ],
                    ),
                  ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await authProvider.register(email: email, password: password, name: name);
                            if (success && context.mounted) {
                              FocusScope.of(context).unfocus();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(minimumSize: Size(160, 48)),
                  child: authProvider.isLoading
                      ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Kayıt Ol'),
                ),
                SizedBox(height: 12),
                OutlinedButton(
                  onPressed: authProvider.isLoading ? null : widget.onLoginTap,
                  child: Text('Zaten hesabınız var mı? Giriş Yap'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  bool _loading = false;
  bool _showSuccess = false;
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Şifre Yenile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_showSuccess)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          SizedBox(width: 8),
                          Expanded(child: Text('Şifre sıfırlama maili gönderildi!', style: TextStyle(color: Colors.green[900]))),
                        ],
                      ),
                    ),
                  Text('Şifre Yenile', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => email = v,
                    validator: (v) => v != null && v.contains('@') ? null : 'Geçerli email girin',
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _loading = true);
                              await authProvider.resetPassword(email);
                              setState(() {
                                _loading = false;
                                _showSuccess = true;
                              });
                              await Future.delayed(const Duration(seconds: 10));
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                    child: _loading
                        ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Şifreyi Sıfırla'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 