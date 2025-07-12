import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tema Ayarları
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tema',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        title: const Text('Karanlık Tema'),
                        subtitle: const Text('Uygulamayı karanlık temada kullan'),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) => themeProvider.setTheme(value),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Bildirim Ayarları
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bildirimler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Consumer<SettingsProvider>(
                    builder: (context, settingsProvider, child) {
                      return Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Bildirimleri Etkinleştir'),
                            subtitle: const Text('Evcil hayvan bakım bildirimleri'),
                            value: settingsProvider.notificationsEnabled,
                            onChanged: (value) => settingsProvider.setNotificationsEnabled(value),
                          ),
                          SwitchListTile(
                            title: const Text('Ses Efektleri'),
                            subtitle: const Text('Etkileşim seslerini çal'),
                            value: settingsProvider.soundEnabled,
                            onChanged: (value) => settingsProvider.setSoundEnabled(value),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Güncelleme Ayarları
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Güncelleme',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Consumer<SettingsProvider>(
                    builder: (context, settingsProvider, child) {
                      return Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Otomatik Güncelleme'),
                            subtitle: const Text('Hayvan durumlarını otomatik güncelle'),
                            value: settingsProvider.autoUpdateEnabled,
                            onChanged: (value) => settingsProvider.setAutoUpdateEnabled(value),
                          ),
                          ListTile(
                            title: const Text('Güncelleme Aralığı'),
                            subtitle: Text('${settingsProvider.updateInterval} dakika'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _showUpdateIntervalDialog(context, settingsProvider),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Varsayılan Ayarlar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Diğer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Consumer<SettingsProvider>(
                    builder: (context, settingsProvider, child) {
                      return ListTile(
                        title: const Text('Varsayılan Ayarlara Sıfırla'),
                        subtitle: const Text('Tüm ayarları varsayılan değerlere döndür'),
                        leading: const Icon(Icons.restore),
                        onTap: () => _showResetDialog(context, settingsProvider),
                      );
                    },
                  ),
                ],
              ),
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
        title: const Text('Güncelleme Aralığı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hayvan durumlarının güncellenme sıklığını seçin:'),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: settingsProvider.updateInterval,
              isExpanded: true,
              items: [30, 60, 120, 180, 240, 300].map((minutes) {
                return DropdownMenuItem(
                  value: minutes,
                  child: Text('$minutes dakika'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setUpdateInterval(value);
                }
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

  void _showResetDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayarları Sıfırla'),
        content: const Text('Tüm ayarlar varsayılan değerlere döndürülecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              settingsProvider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayarlar varsayılan değerlere sıfırlandı')),
              );
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }
} 