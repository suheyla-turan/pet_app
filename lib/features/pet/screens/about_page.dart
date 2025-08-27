import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.getBackgroundGradient(isDark),
        ),
                    child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: themeProvider.getPrimaryTextColor(isDark),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child:                         Text(
                          AppLocalizations.of(context)!.appTitle,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: themeProvider.getPrimaryTextColor(isDark),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Page Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.aboutPageTitle,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: themeProvider.getHighContrastTextColor(isDark),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.aboutPageSubtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.getHighContrastSecondaryTextColor(isDark),
                            fontWeight: FontWeight.w500,
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
                          title: AppLocalizations.of(context)!.appTitle,
                                                      subtitle: AppLocalizations.of(context)!.petTrackingApp,
                          icon: Icons.pets,
                          color: Colors.blue,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(AppLocalizations.of(context)!.appVersion, '1.0.0'),
                              _buildInfoRow(AppLocalizations.of(context)!.developer, '${AppLocalizations.of(context)!.appTitle} Ekibi'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Features Card
                        _buildInfoCard(
                          title: AppLocalizations.of(context)!.aboutFeaturesTitle,
                          subtitle: AppLocalizations.of(context)!.aboutFeaturesSubtitle,
                          icon: Icons.star,
                          color: Colors.orange,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeatureItem('🐕 ${AppLocalizations.of(context)!.petManagement}'),
                              _buildFeatureItem('💉 ${AppLocalizations.of(context)!.vaccines}'),
                              _buildFeatureItem('🔔 ${AppLocalizations.of(context)!.notifications}'),
                              _buildFeatureItem('👥 ${AppLocalizations.of(context)!.coOwnerManagement}'),
                              _buildFeatureItem('☁️ ${AppLocalizations.of(context)!.onboardingFeature12}'),
                              _buildFeatureItem('🎤 ${AppLocalizations.of(context)!.onboardingFeature10}'),
                              _buildFeatureItem('🤖 ${AppLocalizations.of(context)!.aiChat}'),
                              _buildFeatureItem('📱 ${AppLocalizations.of(context)!.onboardingFeature13}'),
                              _buildFeatureItem(AppLocalizations.of(context)!.languageSupport),
                              _buildFeatureItem('🎨 ${AppLocalizations.of(context)!.theme}'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Technology Card
                        _buildInfoCard(
                          title: AppLocalizations.of(context)!.aboutTechnologyTitle,
                          subtitle: AppLocalizations.of(context)!.aboutTechnologySubtitle,
                          icon: Icons.code,
                          color: Colors.green,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeatureItem(AppLocalizations.of(context)!.aboutFlutterTech),
                              _buildFeatureItem(AppLocalizations.of(context)!.aboutFirebaseTech),
                              _buildFeatureItem(AppLocalizations.of(context)!.aboutProviderTech),
                              _buildFeatureItem(AppLocalizations.of(context)!.aboutTTSTech),
                              _buildFeatureItem(AppLocalizations.of(context)!.aboutNotificationsTech),
                              _buildFeatureItem(AppLocalizations.of(context)!.aboutMediaTech),
                              _buildFeatureItem(AppLocalizations.of(context)!.aboutCrossPlatformTech),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        

                        
                        const SizedBox(height: 20),
                        
                        // Privacy & Support Card
                        _buildInfoCard(
                          title: AppLocalizations.of(context)!.aboutPrivacyTitle,
                          subtitle: AppLocalizations.of(context)!.aboutPrivacySubtitle,
                          icon: Icons.security,
                          color: Colors.indigo,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoSection(
                                AppLocalizations.of(context)!.aboutPrivacyPolicy,
                                AppLocalizations.of(context)!.aboutPrivacyPolicyDesc,
                                Icons.privacy_tip,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoSection(
                                AppLocalizations.of(context)!.aboutDataSecurity,
                                AppLocalizations.of(context)!.aboutDataSecurityDesc,
                                Icons.security,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoSection(
                                AppLocalizations.of(context)!.aboutCustomerSupport,
                                AppLocalizations.of(context)!.aboutCustomerSupportDesc,
                                Icons.support_agent,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Copyright
                        Center(
                          child: Text(
                            AppLocalizations.of(context)!.copyrightText(AppLocalizations.of(context)!.appTitle),
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
          color: themeProvider.getReadableCardBackgroundColor(isDark),
          boxShadow: themeProvider.getReadableCardShadow(isDark),
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
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: themeProvider.getHighContrastTextColor(isDark),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.getHighContrastSecondaryTextColor(isDark),
                            fontWeight: FontWeight.w500,
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
} 