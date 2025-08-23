import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('PatiTakip'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: themeProvider.getPrimaryTextColor(isDark),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: themeProvider.getPrimaryTextColor(isDark),
        ),
        iconTheme: IconThemeData(
          color: themeProvider.getPrimaryTextColor(isDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Page Title
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Hakkında',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: themeProvider.getPrimaryTextColor(isDark),
                      ),
                    ),
                    Text(
                      'Uygulama bilgileri ve özellikler',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.getSecondaryTextColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              
              // About Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // App Info Card
                        _buildInfoCard(
                          title: 'PatiTakip',
                          subtitle: 'Evcil Hayvan Takip Uygulaması',
                          icon: Icons.pets,
                          color: Colors.blue,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Uygulama Sürümü', '1.0.0'),
                              _buildInfoRow('Geliştirici', 'PatiTakip Ekibi'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Features Card
                        _buildInfoCard(
                          title: 'Özellikler',
                          subtitle: 'Uygulamanın sunduğu özellikler',
                          icon: Icons.star,
                          color: Colors.orange,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeatureItem('🐕 Evcil hayvan profili yönetimi'),
                              _buildFeatureItem('💉 Aşı takip sistemi'),
                              _buildFeatureItem('🔔 Akıllı bildirim sistemi'),
                              _buildFeatureItem('👥 Çoklu kullanıcı desteği'),
                              _buildFeatureItem('☁️ Bulut yedekleme'),
                              _buildFeatureItem('🎤 Sesli mesajlaşma'),
                              _buildFeatureItem('🤖 AI destekli sohbet'),
                              _buildFeatureItem('📱 Çoklu platform desteği'),
                              _buildFeatureItem('🌐 Türkçe/İngilizce dil desteği'),
                              _buildFeatureItem('🎨 Açık/Koyu tema'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Technology Card
                        _buildInfoCard(
                          title: 'Teknolojiler',
                          subtitle: 'Kullanılan teknolojiler',
                          icon: Icons.code,
                          color: Colors.green,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeatureItem('Flutter 3.8+ & Dart'),
                              _buildFeatureItem('Firebase (Auth, Firestore)'),
                              _buildFeatureItem('Provider State Management'),
                              _buildFeatureItem('Flutter TTS & Sound'),
                              _buildFeatureItem('Local Notifications'),
                              _buildFeatureItem('Image Picker & Media'),
                              _buildFeatureItem('Cross-platform Support'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        

                        
                        const SizedBox(height: 20),
                        
                        // Privacy & Support Card
                        _buildInfoCard(
                          title: 'Gizlilik & Destek',
                          subtitle: 'Veri güvenliği ve destek bilgileri',
                          icon: Icons.security,
                          color: Colors.indigo,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoSection(
                                '🔒 Gizlilik',
                                'Verileriniz güvenle saklanır ve üçüncü taraflarla paylaşılmaz. Detaylı gizlilik politikamızı web sitemizde bulabilirsiniz.',
                                Icons.privacy_tip,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoSection(
                                '🛡️ Güvenlik',
                                'Firebase güvenlik kuralları ile verileriniz korunur. SSL şifreleme ile güvenli iletişim sağlanır.',
                                Icons.security,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoSection(
                                '📞 Destek',
                                'Sorularınız için destek ekibimizle iletişime geçebilirsiniz. Geri bildirimleriniz bizim için değerlidir.',
                                Icons.support_agent,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        

                        
                        const SizedBox(height: 30),
                        
                        // Copyright
                        Center(
                          child: Text(
                            '© 2025 PatiTakip - Tüm hakları saklıdır',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Card(
      elevation: 12,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: themeProvider.getCardBackgroundColor(isDark),
          boxShadow: [
            BoxShadow(
              color: themeProvider.getShadowColor(isDark),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: themeProvider.getPrimaryTextColor(isDark),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.getSecondaryTextColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSocialMediaButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialButton(
          icon: Icons.facebook,
          label: 'Facebook',
          color: const Color(0xFF1877F2),
          onTap: () => _launchSocialMedia('facebook'),
        ),
        _buildSocialButton(
          icon: Icons.camera_alt,
          label: 'Instagram',
          color: const Color(0xFFE4405F),
          onTap: () => _launchSocialMedia('instagram'),
        ),
        _buildSocialButton(
          icon: Icons.flutter_dash,
          label: 'Twitter',
          color: const Color(0xFF1DA1F2),
          onTap: () => _launchSocialMedia('twitter'),
        ),
        _buildSocialButton(
          icon: Icons.play_circle,
          label: 'YouTube',
          color: const Color(0xFFFF0000),
          onTap: () => _launchSocialMedia('youtube'),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String description, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }





  // URL Launch Functions
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info@patitakip.com',
      query: 'subject=PatiTakip Uygulaması Hakkında',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorDialog('E-posta uygulaması bulunamadı');
    }
  }

  Future<void> _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://www.patitakip.com');
    
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorDialog('Web sitesi açılamadı');
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/905551234567?text=Merhaba, PatiTakip uygulaması hakkında bilgi almak istiyorum.');
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorDialog('WhatsApp açılamadı');
    }
  }

  Future<void> _launchSocialMedia(String platform) async {
    String url = '';
    String platformName = '';
    
    switch (platform) {
      case 'facebook':
        url = 'https://www.facebook.com/patitakip';
        platformName = 'Facebook';
        break;
      case 'instagram':
        url = 'https://www.instagram.com/patitakip';
        platformName = 'Instagram';
        break;
      case 'twitter':
        url = 'https://www.twitter.com/patitakip';
        platformName = 'Twitter';
        break;
      case 'youtube':
        url = 'https://www.youtube.com/@patitakip';
        platformName = 'YouTube';
        break;
    }
    
    if (url.isNotEmpty) {
      final Uri socialUri = Uri.parse(url);
      if (await canLaunchUrl(socialUri)) {
        await launchUrl(socialUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog('$platformName açılamadı');
      }
    }
  }

  // Dialog Functions
  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uygulamayı Değerlendir'),
        content: const Text('Deneyiminizi değerlendirin ve geliştirmemize yardımcı olun. Uygulama mağazasında 5 yıldız vermeyi unutmayın!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchAppStore();
            },
            child: const Text('Mağazaya Git'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uygulamayı Paylaş'),
        content: const Text('🐾 PatiTakip - Evcil hayvanlarınız için en iyi bakım deneyimi! Uygulamayı arkadaşlarınızla paylaşın.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showFollowDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bizi Takip Edin'),
        content: const Text('Güncellemeler, yeni özellikler ve haberler için sosyal medyada bizi takip edin!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSocialMediaOptions();
            },
            child: const Text('Sosyal Medya'),
          ),
        ],
      ),
    );
  }

  void _showRemoveAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Kaldır'),
        content: const Text('Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz silinir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRemoveAccountConfirmation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showSocialMediaOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sosyal Medya Hesaplarımız'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
              title: const Text('Facebook'),
              onTap: () {
                Navigator.pop(context);
                _launchSocialMedia('facebook');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFE4405F)),
              title: const Text('Instagram'),
              onTap: () {
                Navigator.pop(context);
                _launchSocialMedia('instagram');
              },
            ),
            ListTile(
              leading: const Icon(Icons.flutter_dash, color: Color(0xFF1DA1F2)),
              title: const Text('Twitter'),
              onTap: () {
                Navigator.pop(context);
                _launchSocialMedia('twitter');
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle, color: Color(0xFFFF0000)),
              title: const Text('YouTube'),
              onTap: () {
                Navigator.pop(context);
                _launchSocialMedia('youtube');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showRemoveAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Son Onay'),
        content: const Text('Hesabınızı silmek için lütfen "HESABIMI SİL" yazın:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRemoveAccountFinal();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }

  void _showRemoveAccountFinal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesap Silindi'),
        content: const Text('Hesabınız başarıyla silindi. Uygulamayı kullanmaya devam etmek isterseniz, tekrar kayıt olabilirsiniz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchAppStore() async {
    // Android için Play Store, iOS için App Store
    final Uri storeUri = Uri.parse('https://play.google.com/store/apps/details?id=com.example.pati_takip');
    
    if (await canLaunchUrl(storeUri)) {
      await launchUrl(storeUri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorDialog('Uygulama mağazası açılamadı');
    }
  }
} 