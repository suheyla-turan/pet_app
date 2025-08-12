import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/theme_provider.dart';

import '../../../services/voice_service.dart';
import '../../profile/profile_page.dart';
import 'about_page.dart';
import 'feedback_page.dart';
import 'faq_page.dart';
import 'notification_test_page.dart';

import 'package:pati_takip/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
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
        ),
        title: const Text('PatiTakip'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
              // Page Title
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.settings,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.settingsDescription,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Settings Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Theme Settings Card
                        _buildSettingsCard(
                          title: AppLocalizations.of(context)!.theme,
                          icon: Icons.palette,
                          color: Colors.purple,
                          child: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return Column(
                                children: [
                                  _buildThemeRadioTile(
                                    title: AppLocalizations.of(context)!.themeLight,
                                    subtitle: AppLocalizations.of(context)!.themeLightDesc,
                                    value: ThemeMode.light,
                                    groupValue: themeProvider.themeMode,
                                    onChanged: (mode) => themeProvider.setThemeMode(mode!),
                                    icon: Icons.light_mode,
                                  ),
                                  _buildThemeRadioTile(
                                    title: AppLocalizations.of(context)!.themeDark,
                                    subtitle: AppLocalizations.of(context)!.themeDarkDesc,
                                    value: ThemeMode.dark,
                                    groupValue: themeProvider.themeMode,
                                    onChanged: (mode) => themeProvider.setThemeMode(mode!),
                                    icon: Icons.dark_mode,
                                  ),
                                  _buildThemeRadioTile(
                                    title: AppLocalizations.of(context)!.themeSystem,
                                    subtitle: AppLocalizations.of(context)!.themeSystemDesc,
                                    value: ThemeMode.system,
                                    groupValue: themeProvider.themeMode,
                                    onChanged: (mode) => themeProvider.setThemeMode(mode!),
                                    icon: Icons.phone_android,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // DİL SEÇİCİ KARTI
                        _buildSettingsCard(
                          title: AppLocalizations.of(context)!.language,
                          icon: Icons.language,
                          color: Colors.teal,
                          child: Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return DropdownButtonFormField<Locale>(
                                value: settingsProvider.locale ?? const Locale('tr'),
                                items: const [
                                  DropdownMenuItem(
                                    value: Locale('tr'),
                                    child: Text('Türkçe'),
                                  ),
                                  DropdownMenuItem(
                                    value: Locale('en'),
                                    child: Text('English'),
                                  ),
                                ],
                                onChanged: (locale) {
                                  settingsProvider.setLocale(locale);
                                },
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.appLanguage,
                                  border: OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        

                        
                        // Voice Settings Card
                        _buildSettingsCard(
                          title: AppLocalizations.of(context)!.voiceSettings,
                          icon: Icons.volume_up,
                          color: Colors.green,
                          subtitle: AppLocalizations.of(context)!.voiceSettingsDesc,
                          child: Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return Column(
                                children: [
                                  _buildSwitchTile(
                                    title: AppLocalizations.of(context)!.voiceAuto,
                                    subtitle: AppLocalizations.of(context)!.voiceAutoDesc,
                                    value: settingsProvider.voiceResponseEnabled,
                                    onChanged: (value) => settingsProvider.setVoiceResponseEnabled(value),
                                    icon: Icons.auto_awesome,
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.blue.shade600,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(context)!.voiceListenFeature,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.blue.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          AppLocalizations.of(context)!.voiceListenFeatureDesc,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // TTS Ayarları Card
                        _buildSettingsCard(
                          title: AppLocalizations.of(context)!.voiceTTS,
                          icon: Icons.record_voice_over,
                          color: Colors.deepPurple,
                          child: Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return FutureBuilder<List<dynamic>?>(
                                future: VoiceService().getVoices(),
                                builder: (context, snapshot) {
                                  final voices = snapshot.data ?? [];
                                  // Only unique voice names
                                  final voiceNames = <String>{};
                                  final voiceItems = [
                                    // TODO: Add 'voiceDefaultVoice' to localization if needed
                                    // label: AppLocalizations.of(context)!.voiceDefaultVoice,
                                    // value: 'default',
                                    ...voices
                                        .where((v) => v is Map && v['name'] != null)
                                        .map((v) => v['name'] as String)
                                        .where((name) => voiceNames.add(name))
                                        .map((name) => DropdownMenuItem<String>(
                                              value: name,
                                              child: Text(name),
                                            ))
                                        ,
                                  ];
                                  String? selectedVoice = settingsProvider.ttsVoice;
                                  if (selectedVoice != null && !voiceItems.any((item) => item.value == selectedVoice)) {
                                    selectedVoice = null;
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Voice Dropdown
                                      DropdownButtonFormField<String>(
                                        value: selectedVoice,
                                        items: voiceItems,
                                        onChanged: (voice) => settingsProvider.setTtsVoice(voice),
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(context)!.voiceSpeaker,
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Rate Slider
                                      Text('${AppLocalizations.of(context)!.voiceRate}: ${settingsProvider.ttsRate.toStringAsFixed(2)}'),
                                      Slider(
                                        value: settingsProvider.ttsRate,
                                        min: 0.1,
                                        max: 1.0,
                                        divisions: 18,
                                        label: settingsProvider.ttsRate.toStringAsFixed(2),
                                        onChanged: (v) => settingsProvider.setTtsRate(v),
                                      ),
                                      const SizedBox(height: 8),
                                      // Pitch Slider
                                      Text('${AppLocalizations.of(context)!.voicePitch}: ${settingsProvider.ttsPitch.toStringAsFixed(2)}'),
                                      Slider(
                                        value: settingsProvider.ttsPitch,
                                        min: 0.5,
                                        max: 2.0,
                                        divisions: 15,
                                        label: settingsProvider.ttsPitch.toStringAsFixed(2),
                                        onChanged: (v) => settingsProvider.setTtsPitch(v),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Notification Settings Card
                        _buildSettingsCard(
                          title: AppLocalizations.of(context)!.notifications,
                          icon: Icons.notifications,
                          color: Colors.orange,
                          child: Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return Column(
                                children: [
                                  _buildSwitchTile(
                                    title: AppLocalizations.of(context)!.enableNotifications,
                                    subtitle: AppLocalizations.of(context)!.petCareNotifications,
                                    value: settingsProvider.notificationsEnabled,
                                    onChanged: (value) => settingsProvider.setNotificationsEnabled(value),
                                    icon: Icons.notifications_active,
                                  ),
                                  _buildSwitchTile(
                                    title: AppLocalizations.of(context)!.soundEffects,
                                    subtitle: AppLocalizations.of(context)!.playInteractionSounds,
                                    value: settingsProvider.soundEnabled,
                                    onChanged: (value) => settingsProvider.setSoundEnabled(value),
                                    icon: Icons.volume_up,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Gelişmiş Bildirimler Card
                        _buildSettingsCard(
                          title: AppLocalizations.of(context)!.advancedNotifications,
                          icon: Icons.notifications_active,
                          color: Colors.indigo,
                          child: Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bildirim Sesi Seçimi
                                  DropdownButtonFormField<String>(
                                    value: settingsProvider.notificationSound,
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text(AppLocalizations.of(context)!.notificationsDefault),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'notification_sound',
                                        child: Text(AppLocalizations.of(context)!.notificationsCustom),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'bell_sound',
                                        child: Text(AppLocalizations.of(context)!.notificationsBell),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'chime_sound',
                                        child: Text(AppLocalizations.of(context)!.notificationsChime),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'alert_sound',
                                        child: Text(AppLocalizations.of(context)!.notificationsAlert),
                                      ),
                                    ],
                                    onChanged: (sound) => settingsProvider.setNotificationSound(sound),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.notificationsSound,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                ],
                              );
                            },
                          ),
                        ),
                        
                        // Bildirim Test Linki
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationTestPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.science, color: Colors.white),
                            label: const Text(
                              '🧪 Bildirimleri Test Et',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Update Settings Card
                        _buildSettingsCard(
                          title: AppLocalizations.of(context)!.update,
                          icon: Icons.update,
                          color: Colors.teal,
                          child: Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return Column(
                                children: [
                                  _buildSwitchTile(
                                    title: AppLocalizations.of(context)!.autoUpdate,
                                    subtitle: AppLocalizations.of(context)!.autoUpdateDesc,
                                    value: settingsProvider.autoUpdateEnabled,
                                    onChanged: (value) => settingsProvider.setAutoUpdateEnabled(value),
                                    icon: Icons.auto_awesome,
                                  ),
                                  _buildListTile(
                                    title: AppLocalizations.of(context)!.updateInterval,
                                    subtitle: '${settingsProvider.updateInterval} ${AppLocalizations.of(context)!.minutes}',
                                    icon: Icons.timer,
                                    onTap: () => _showUpdateIntervalDialog(context, settingsProvider),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        
                        // --- YENİ MODERN GRUP ---
                        const SizedBox(height: 32),
                        _buildSettingsCard(
                          title: AppLocalizations.of(context)!.infoSupport,
                          icon: Icons.info_outline,
                          color: Colors.indigo,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                                title: Text(AppLocalizations.of(context)!.profile),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => ProfilePage()),
                                  );
                                },
                              ),
                              const Divider(indent: 16, endIndent: 16, height: 0),
                              ListTile(
                                leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                                title: Text(AppLocalizations.of(context)!.about),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => AboutPage()),
                                  );
                                },
                              ),
                              const Divider(indent: 16, endIndent: 16, height: 0),
                              ListTile(
                                leading: Icon(Icons.support_agent, color: Theme.of(context).colorScheme.primary),
                                title: Text(AppLocalizations.of(context)!.support),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => FeedbackPage()),
                                  );
                                },
                              ),
                              const Divider(indent: 16, endIndent: 16, height: 0),
                              ListTile(
                                leading: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.primary),
                                title: Text('Sık Sorulan Sorular'),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => FAQPage()),
                                  );
                                },
                              ),

                            ],
                          ),
                        ),
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

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color color,
    String? subtitle,
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
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                            ),
                          ),
                        ],
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }



  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
              Icon(
                Icons.arrow_forward_ios,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeRadioTile({
    required String title,
    required String subtitle,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Radio<ThemeMode>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
    );
  }

  void _showUpdateIntervalDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.updateInterval),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.updateIntervalDescription),
            const SizedBox(height: 20),
            Slider(
              value: settingsProvider.updateInterval.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              label: '${settingsProvider.updateInterval} ${AppLocalizations.of(context)!.minutes}',
              onChanged: (value) {
                settingsProvider.setUpdateInterval(value.round());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }
} 