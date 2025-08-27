import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:pati_takip/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  final int initialPage;
  final VoidCallback? onComplete;
  const OnboardingPage({super.key, this.initialPage = 0, this.onComplete});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    _pageIndex = widget.initialPage;
  }

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _pageIndex = i),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _OnboardingInfo(
                      title: AppLocalizations.of(context)!.onboardingWelcome,
                      description: AppLocalizations.of(context)!.onboardingDescription,
                      icon: Icons.pets,
                      features: [
                        AppLocalizations.of(context)!.onboardingFeature1,
                        AppLocalizations.of(context)!.onboardingFeature2,
                        AppLocalizations.of(context)!.onboardingFeature3,
                        AppLocalizations.of(context)!.onboardingFeature4
                      ],
                      buttonText: AppLocalizations.of(context)!.next,
                      onButton: () => _pageController.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.ease),
                    ),
                    _OnboardingInfo(
                      title: AppLocalizations.of(context)!.petManagement,
                      description: AppLocalizations.of(context)!.petManagementDescription,
                      icon: Icons.manage_accounts,
                      features: [
                        AppLocalizations.of(context)!.onboardingFeature5,
                        '• Fotoğraf ve bilgi yönetimi',
                        '• Çoklu evcil hayvan desteği',
                        '• Bulut yedekleme ve senkronizasyon'
                      ],
                      buttonText: AppLocalizations.of(context)!.next,
                      onButton: () => _pageController.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.ease),
                    ),
                    _OnboardingInfo(
                      title: 'Sağlık Takibi',
                      description: AppLocalizations.of(context)!.healthTrackingDescription,
                      icon: Icons.health_and_safety,
                      features: [
                        AppLocalizations.of(context)!.onboardingFeature9,
                        AppLocalizations.of(context)!.onboardingFeature10,
                        AppLocalizations.of(context)!.onboardingFeature11,
                        AppLocalizations.of(context)!.onboardingFeature12
                      ],
                      buttonText: AppLocalizations.of(context)!.next,
                      onButton: () => _pageController.animateToPage(3, duration: Duration(milliseconds: 400), curve: Curves.ease),
                    ),
                    _OnboardingInfo(
                      title: AppLocalizations.of(context)!.profileAndHistory,
                      description: AppLocalizations.of(context)!.profileAndHistoryDescription,
                      icon: Icons.psychology,
                      features: [
                        AppLocalizations.of(context)!.onboardingFeature13,
                        AppLocalizations.of(context)!.onboardingFeature14,
                        AppLocalizations.of(context)!.onboardingFeature15,
                        '• Kapsamlı evcil hayvan bakım geçmişi'
                      ],
                      buttonText: AppLocalizations.of(context)!.start,
                      onButton: _goToAuth,
                      onComplete: widget.onComplete,
                    ),
                    // Auth ekranları
                    LoginScreen(
                      onRegisterTap: () => _pageController.animateToPage(5, duration: Duration(milliseconds: 400), curve: Curves.ease),
                      onComplete: widget.onComplete,
                    ),
                    RegisterScreen(
                      onLoginTap: () => _pageController.animateToPage(4, duration: Duration(milliseconds: 400), curve: Curves.ease),
                      onComplete: widget.onComplete,
                    ),
                  ],
                ),
              ),
              if (_pageIndex < 4)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: _goToAuth,
                        style: TextButton.styleFrom(
                          foregroundColor: themeProvider.getSecondaryTextColor(isDark),
                        ),
                        child: Text(
                          'Atla',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Page indicator
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: 4,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 8,
                          dotColor: themeProvider.getSecondaryTextColor(isDark).withOpacity(0.3),
                          activeDotColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      // Empty space for balance
                      const SizedBox(width: 80),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingInfo extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<String> features;
  final String buttonText;
  final VoidCallback onButton;
  final VoidCallback? onComplete;

  const _OnboardingInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.features,
    required this.buttonText,
    required this.onButton,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with theme-aware background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          SizedBox(height: 32),
          
          // Title with theme-aware color
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: themeProvider.getHighContrastTextColor(isDark),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 16),
          
          // Description with theme-aware color
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.getSecondaryTextColor(isDark),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 32),
          
          // Features list with theme-aware colors
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.getHighContrastSecondaryTextColor(isDark),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          SizedBox(height: 40),
          
          // Button with improved design
          Container(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                onButton();
                // Onboarding tamamlandı olarak işaretle
                onComplete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onRegisterTap;
  final VoidCallback? onComplete;
  const LoginScreen({super.key, required this.onRegisterTap, this.onComplete});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  bool _obscure = true;
  final bool _resetLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome icon and title
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.login,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 24),
                
                Text(
                  AppLocalizations.of(context)!.welcomeBack,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.getHighContrastTextColor(isDark),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 8),
                
                Text(
                  AppLocalizations.of(context)!.loginToYourAccount,
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.getSecondaryTextColor(isDark),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 32),
                
                // Email field
                TextFormField(
                  initialValue: email,
                  onChanged: (value) => email = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emailRequired;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return AppLocalizations.of(context)!.emailInvalid;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email,
                    prefixIcon: Icon(Icons.email_outlined),
                    labelStyle: TextStyle(
                      color: themeProvider.getSecondaryTextColor(isDark),
                    ),
                  ),
                  style: TextStyle(
                    color: themeProvider.getHighContrastTextColor(isDark),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Password field
                TextFormField(
                  initialValue: password,
                  onChanged: (value) => password = value,
                  obscureText: _obscure,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppLocalizations.of(context)!.passwordTooShort;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                    prefixIcon: Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    labelStyle: TextStyle(
                      color: themeProvider.getSecondaryTextColor(isDark),
                    ),
                  ),
                  style: TextStyle(
                    color: themeProvider.getHighContrastTextColor(isDark),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Şifre sıfırlama ekranına git
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ResetPasswordScreen(
                            onBack: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.forgotPassword,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Login button with improved design
                Container(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await authProvider.signIn(email: email, password: password);
                              if (success && context.mounted) {
                                FocusScope.of(context).unfocus();
                                // Onboarding tamamlandı olarak işaretle
                                widget.onComplete?.call();
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    child: authProvider.isLoading
                        ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                            AppLocalizations.of(context)!.login,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Register link with improved design
                Container(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: authProvider.isLoading ? null : widget.onRegisterTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeProvider.getHighContrastTextColor(isDark),
                      side: BorderSide(color: themeProvider.getSecondaryTextColor(isDark).withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.noAccountRegister,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
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
  final VoidCallback? onComplete;
  const RegisterScreen({super.key, required this.onLoginTap, this.onComplete});

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome icon and title
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 24),
                
                Text(
                  'Hesap Oluştur',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.getHighContrastTextColor(isDark),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 8),
                
                Text(
                  'Evcil hayvan severler topluluğumuza katılın',
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.getSecondaryTextColor(isDark),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 32),
                
                // Name field
                TextFormField(
                  initialValue: name,
                  onChanged: (value) => name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'İsim gerekli';
                    }
                    if (value.length < 2) {
                      return 'İsim en az 2 karakter olmalı';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Ad Soyad',
                    prefixIcon: Icon(Icons.person_outlined),
                    labelStyle: TextStyle(
                      color: themeProvider.getSecondaryTextColor(isDark),
                    ),
                  ),
                  style: TextStyle(
                    color: themeProvider.getHighContrastTextColor(isDark),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Email field
                TextFormField(
                  initialValue: email,
                  onChanged: (value) => email = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emailRequired;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return AppLocalizations.of(context)!.emailInvalid;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email,
                    prefixIcon: Icon(Icons.email_outlined),
                    labelStyle: TextStyle(
                      color: themeProvider.getSecondaryTextColor(isDark),
                    ),
                  ),
                  style: TextStyle(
                    color: themeProvider.getHighContrastTextColor(isDark),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Password field
                TextFormField(
                  initialValue: password,
                  onChanged: (value) => password = value,
                  obscureText: _obscure,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppLocalizations.of(context)!.passwordTooShort;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                    prefixIcon: Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    labelStyle: TextStyle(
                      color: themeProvider.getSecondaryTextColor(isDark),
                    ),
                  ),
                  style: TextStyle(
                    color: themeProvider.getHighContrastTextColor(isDark),
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Register button with improved design
                Container(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await authProvider.register(email: email, password: password, name: name);
                              if (success && context.mounted) {
                                FocusScope.of(context).unfocus();
                                // Onboarding tamamlandı olarak işaretle
                                widget.onComplete?.call();
                                
                                // Başarı mesajı göster ve e-posta doğrulama gerekliliğini belirt
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Hesap başarıyla oluşturuldu! Lütfen e-posta doğrulaması için e-postanızı kontrol edin.'),
                                    backgroundColor: Colors.green[600],
                                    duration: Duration(seconds: 8),
                                    action: SnackBarAction(
                                      label: AppLocalizations.of(context)!.ok,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                      },
                                    ),
                                  ),
                                );
                                
                                // Form alanlarını temizle
                                setState(() {
                                  email = '';
                                  password = '';
                                  name = '';
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    child: authProvider.isLoading
                        ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                            AppLocalizations.of(context)!.register,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Login link with improved design
                Container(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: authProvider.isLoading ? null : widget.onLoginTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeProvider.getHighContrastTextColor(isDark),
                      side: BorderSide(color: themeProvider.getSecondaryTextColor(isDark).withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Zaten hesabınız var mı? Giriş yapın',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reset password screen - tema desteği ile
class ResetPasswordScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ResetPasswordScreen({super.key, required this.onBack});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: Icon(
                        Icons.arrow_back,
                        color: themeProvider.getHighContrastTextColor(isDark),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.resetPassword,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.getHighContrastTextColor(isDark),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Balance the header
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Reset password icon
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.lock_reset,
                                size: 50,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 24),
                            
                            Text(
                              AppLocalizations.of(context)!.resetPasswordTitle,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.getHighContrastTextColor(isDark),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: 16),
                            
                            Text(
                              AppLocalizations.of(context)!.resetPasswordDescription,
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.getSecondaryTextColor(isDark),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: 32),
                            
                            // Email field
                            TextFormField(
                              initialValue: email,
                              onChanged: (value) => email = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.emailRequired;
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return AppLocalizations.of(context)!.emailInvalid;
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.email,
                                prefixIcon: Icon(Icons.email_outlined),
                                labelStyle: TextStyle(
                                  color: themeProvider.getSecondaryTextColor(isDark),
                                ),
                              ),
                              style: TextStyle(
                                color: themeProvider.getHighContrastTextColor(isDark),
                              ),
                            ),
                            
                            SizedBox(height: 32),
                            
                            // Reset button
                            Container(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() => _isLoading = true);
                                          
                                          try {
                                            // Gerçek Firebase şifre sıfırlama işlemi
                                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                            final success = await authProvider.resetPassword(email);
                                            
                                            if (mounted) {
                                              setState(() => _isLoading = false);
                                              
                                              if (success) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(AppLocalizations.of(context)!.resetMailSent),
                                                    backgroundColor: Colors.green[600],
                                                    duration: Duration(seconds: 4),
                                                  ),
                                                );
                                                widget.onBack();
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(authProvider.errorMessage ?? 'Şifre sıfırlama hatası oluştu'),
                                                    backgroundColor: Colors.red[600],
                                                    duration: Duration(seconds: 4),
                                                  ),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              setState(() => _isLoading = false);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${AppLocalizations.of(context)!.errorOccurred} $e'),
                                                  backgroundColor: Colors.red[600],
                                                  duration: Duration(seconds: 4),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                ),
                                child: _isLoading
                                    ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(
                                        AppLocalizations.of(context)!.resetPasswordButton,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 