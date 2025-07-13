import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/voice_service.dart';
import '../../profile/profile_page.dart';

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
                            'Ayarlar',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            'Uygulama tercihlerinizi yönetin',
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
                          title: 'Tema',
                          icon: Icons.palette,
                          color: Colors.purple,
                          child: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return Column(
                                children: [
                                  _buildThemeRadioTile(
                                    title: 'Açık',
                                    subtitle: 'Açık tema',
                                    value: ThemeMode.light,
                                    groupValue: themeProvider.themeMode,
                                    onChanged: (mode) => themeProvider.setThemeMode(mode!),
                                    icon: Icons.light_mode,
                                  ),
                                  _buildThemeRadioTile(
                                    title: 'Karanlık',
                                    subtitle: 'Karanlık tema',
                                    value: ThemeMode.dark,
                                    groupValue: themeProvider.themeMode,
                                    onChanged: (mode) => themeProvider.setThemeMode(mode!),
                                    icon: Icons.dark_mode,
                                  ),
                                  _buildThemeRadioTile(
                                    title: 'Sistem Varsayılanı',
                                    subtitle: 'Cihazın tema ayarını kullan',
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
                        
                        // AI Conversation Style Card
                        _buildSettingsCard(
                          title: 'AI Konuşma Stili',
                          icon: Icons.psychology,
                          color: Colors.blue,
                          subtitle: 'AI asistanın size nasıl yanıt vereceğini seçin',
                          child: Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return Column(
                                children: ConversationStyle.values.map((style) {
                                  return _buildRadioTile(
                                    title: style.title,
                                    subtitle: style.description,
                                    value: style,
                                    groupValue: settingsProvider.conversationStyle,
                                    onChanged: (value) {
                                      if (value != null) {
                                        settingsProvider.setConversationStyle(value);
                                      }
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Voice Settings Card
                        _buildSettingsCard(
                          title: 'Sesli Konuşma',
                          icon: Icons.volume_up,
                          color: Colors.green,
                          subtitle: 'AI ile sesli konuşma özelliklerini yönetin',
                          child: Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return Column(
                                children: [
                                  _buildSwitchTile(
                                    title: 'Otomatik Sesli Yanıt',
                                    subtitle: 'AI cevaplarını otomatik olarak sesli oku',
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
                                              'Sesli Dinleme Özelliği',
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
                                          '• Her AI yanıtının altında "Sesli Dinle" butonu bulunur\n'
                                          '• Bu buton ile istediğiniz zaman cevabı sesli dinleyebilirsiniz\n'
                                          '• Otomatik sesli yanıt kapalı olsa bile manuel olarak dinleyebilirsiniz',
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
                          title: 'Sesli Yanıt (TTS)',
                          icon: Icons.record_voice_over,
                          color: Colors.deepPurple,
                          child: Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return FutureBuilder<List<dynamic>>(
                                future: VoiceService().getAvailableVoices(),
                                builder: (context, snapshot) {
                                  final voices = snapshot.data ?? [];
                                  // Only unique voice names
                                  final voiceNames = <String>{};
                                  final voiceItems = [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Varsayılan Ses'),
                                    ),
                                    ...voices
                                        .where((v) => v is Map && v['name'] != null)
                                        .map((v) => v['name'] as String)
                                        .where((name) => voiceNames.add(name))
                                        .map((name) => DropdownMenuItem<String>(
                                              value: name,
                                              child: Text(name),
                                            ))
                                        .toList(),
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
                                        decoration: const InputDecoration(
                                          labelText: 'Konuşmacı (Ses)',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Rate Slider
                                      Text('Konuşma Hızı: ${settingsProvider.ttsRate.toStringAsFixed(2)}'),
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
                                      Text('Ses Perdesi: ${settingsProvider.ttsPitch.toStringAsFixed(2)}'),
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
                          title: 'Bildirimler',
                          icon: Icons.notifications,
                          color: Colors.orange,
                          child: Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return Column(
                                children: [
                                  _buildSwitchTile(
                                    title: 'Bildirimleri Etkinleştir',
                                    subtitle: 'Evcil hayvan bakım bildirimleri',
                                    value: settingsProvider.notificationsEnabled,
                                    onChanged: (value) => settingsProvider.setNotificationsEnabled(value),
                                    icon: Icons.notifications_active,
                                  ),
                                  _buildSwitchTile(
                                    title: 'Ses Efektleri',
                                    subtitle: 'Etkileşim seslerini çal',
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
                          title: 'Gelişmiş Bildirimler',
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
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Varsayılan Ses'),
                                      ),
                                      const DropdownMenuItem<String>(
                                        value: 'notification_sound',
                                        child: Text('Özel Bildirim Sesi'),
                                      ),
                                      const DropdownMenuItem<String>(
                                        value: 'bell_sound',
                                        child: Text('Zil Sesi'),
                                      ),
                                      const DropdownMenuItem<String>(
                                        value: 'chime_sound',
                                        child: Text('Çan Sesi'),
                                      ),
                                      const DropdownMenuItem<String>(
                                        value: 'alert_sound',
                                        child: Text('Uyarı Sesi'),
                                      ),
                                    ],
                                    onChanged: (sound) => settingsProvider.setNotificationSound(sound),
                                    decoration: const InputDecoration(
                                      labelText: 'Bildirim Sesi',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Zamanlı Bildirimler
                                  _buildSwitchTile(
                                    title: 'Zamanlı Bildirimler',
                                    subtitle: 'Günlük hatırlatıcı bildirimleri',
                                    value: settingsProvider.scheduledNotificationsEnabled,
                                    onChanged: (value) => settingsProvider.setScheduledNotificationsEnabled(value),
                                    icon: Icons.schedule,
                                  ),
                                  if (settingsProvider.scheduledNotificationsEnabled) ...[
                                    const SizedBox(height: 12),
                                    Container(
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
                                            Icons.access_time,
                                            color: theme.colorScheme.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Bildirim Zamanı',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                                                  ),
                                                ),
                                                Text(
                                                  '${settingsProvider.scheduledNotificationTime.format(context)}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              final time = await showTimePicker(
                                                context: context,
                                                initialTime: settingsProvider.scheduledNotificationTime,
                                              );
                                              if (time != null) {
                                                settingsProvider.setScheduledNotificationTime(time);
                                              }
                                            },
                                            icon: const Icon(Icons.edit),
                                            tooltip: 'Zamanı Değiştir',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Update Settings Card
                        _buildSettingsCard(
                          title: 'Güncelleme',
                          icon: Icons.update,
                          color: Colors.teal,
                          child: Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return Column(
                                children: [
                                  _buildSwitchTile(
                                    title: 'Otomatik Güncelleme',
                                    subtitle: 'Hayvan durumlarını otomatik güncelle',
                                    value: settingsProvider.autoUpdateEnabled,
                                    onChanged: (value) => settingsProvider.setAutoUpdateEnabled(value),
                                    icon: Icons.auto_awesome,
                                  ),
                                  _buildListTile(
                                    title: 'Güncelleme Aralığı',
                                    subtitle: '${settingsProvider.updateInterval} dakika',
                                    icon: Icons.timer,
                                    onTap: () => _showUpdateIntervalDialog(context, settingsProvider),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Profilim'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ProfilePage()),
                            );
                          },
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

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required ConversationStyle value,
    required ConversationStyle? groupValue,
    required ValueChanged<ConversationStyle?> onChanged,
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
          Radio<ConversationStyle>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
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
        title: const Text('Güncelleme Aralığı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hayvan durumlarının güncellenme sıklığını seçin'),
            const SizedBox(height: 20),
            Slider(
              value: settingsProvider.updateInterval.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              label: '${settingsProvider.updateInterval} dakika',
              onChanged: (value) {
                settingsProvider.setUpdateInterval(value.round());
              },
            ),
          ],
        ),
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