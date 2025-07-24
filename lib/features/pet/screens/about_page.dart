import 'package:flutter/material.dart';
import 'package:pati_takip/l10n/app_localizations.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [
                  const Color(0xFF1A202C),
                  const Color(0xFF2D3748),
                  const Color(0xFF4A5568),
                ]
              : [
                  const Color(0xFFF7FAFC),
                  const Color(0xFFEDF2F7),
                  const Color(0xFFE2E8F0),
                ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Beautiful Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Hakkında',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            'Uygulama bilgileri ve özellikler',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                            ),
                          ),
                        ],
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
                              _buildInfoRow('İletişim', 'info@patitakip.com'),
                              _buildInfoRow('Web Sitesi', 'www.patitakip.com'),
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
                              _buildFeatureItem('Evcil hayvan profili yönetimi'),
                              _buildFeatureItem('Aşı takip sistemi'),
                              _buildFeatureItem('Yapay zeka destekli sohbet'),
                              _buildFeatureItem('Sesli komut özelliği'),
                              _buildFeatureItem('Bildirim sistemi'),
                              _buildFeatureItem('Çoklu kullanıcı desteği'),
                              _buildFeatureItem('Bulut yedekleme'),
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
                              _buildFeatureItem('Flutter & Dart'),
                              _buildFeatureItem('Firebase'),
                              _buildFeatureItem('OpenAI API'),
                              _buildFeatureItem('Speech Recognition'),
                              _buildFeatureItem('Text-to-Speech'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Privacy & Support Card
                        _buildInfoCard(
                          title: 'Gizlilik & Destek',
                          subtitle: 'Veri güvenliği ve destek bilgileri',
                          icon: Icons.security,
                          color: Colors.purple,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoSection(
                                'Gizlilik',
                                'Verileriniz güvenle saklanır ve üçüncü taraflarla paylaşılmaz. Detaylı gizlilik politikamızı web sitemizde bulabilirsiniz.',
                                Icons.privacy_tip,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoSection(
                                'Destek',
                                'Sorularınız için destek ekibimizle iletişime geçebilirsiniz. Geri bildirimleriniz bizim için değerlidir.',
                                Icons.support_agent,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action Buttons
                        _buildActionButtons(),
                        
                        const SizedBox(height: 30),
                        
                        // Copyright
                        Center(
                          child: Text(
                            '© 2024 PatiTakip - Tüm hakları saklıdır',
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
    
    return Card(
      elevation: 8,
      shadowColor: color.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.grey.shade800,
                    Colors.grey.shade700,
                  ]
                : [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
          ),
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
                      color: color.withOpacity(0.1),
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
                            color: isDark ? Colors.white : const Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
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

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.star,
            label: 'Değerlendir',
            color: Colors.orange,
            onTap: () => _showRatingDialog(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.share,
            label: 'Paylaş',
            color: Colors.blue,
            onTap: () => _showShareDialog(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.favorite,
            label: 'Takip Et',
            color: Colors.pink,
            onTap: () => _showFollowDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
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

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uygulamayı Değerlendir'),
        content: const Text('Deneyiminizi değerlendirin ve geliştirmemize yardımcı olun.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
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
        content: const Text('Arkadaşlarınızla PatiTakip\'i paylaşın.'),
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
        content: const Text('Güncellemeler ve haberler için sosyal medyada bizi takip edin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
} 