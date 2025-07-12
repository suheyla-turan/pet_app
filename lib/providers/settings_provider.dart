import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ConversationStyle {
  friendly('Dostane', 'Sıcak ve samimi bir ton kullanır'),
  professional('Profesyonel', 'Resmi ve bilgilendirici bir ton kullanır'),
  playful('Eğlenceli', 'Eğlenceli ve oyuncu bir ton kullanır'),
  caring('Şefkatli', 'Şefkatli ve koruyucu bir ton kullanır');

  const ConversationStyle(this.title, this.description);
  final String title;
  final String description;
}

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _autoUpdateEnabled = true;
  int _updateInterval = 60; // dakika
  ConversationStyle _conversationStyle = ConversationStyle.friendly;
  bool _voiceResponseEnabled = false;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get autoUpdateEnabled => _autoUpdateEnabled;
  int get updateInterval => _updateInterval;
  ConversationStyle get conversationStyle => _conversationStyle;
  bool get voiceResponseEnabled => _voiceResponseEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _autoUpdateEnabled = prefs.getBool('auto_update_enabled') ?? true;
      _updateInterval = prefs.getInt('update_interval') ?? 60;
      
      // Konuşma stili ayarını yükle
      final styleIndex = prefs.getInt('conversation_style') ?? 0;
      _conversationStyle = ConversationStyle.values[styleIndex.clamp(0, ConversationStyle.values.length - 1)];
      
      // Sesli yanıt ayarını yükle
      _voiceResponseEnabled = prefs.getBool('voice_response_enabled') ?? false;
      
      notifyListeners();
    } catch (e) {
      print('❌ HATA - Ayarlar yüklenemedi: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
    notifyListeners();
  }

  Future<void> setAutoUpdateEnabled(bool enabled) async {
    _autoUpdateEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_update_enabled', enabled);
    notifyListeners();
  }

  Future<void> setUpdateInterval(int minutes) async {
    _updateInterval = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('update_interval', minutes);
    notifyListeners();
  }

  Future<void> setConversationStyle(ConversationStyle style) async {
    _conversationStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('conversation_style', style.index);
    notifyListeners();
  }

  Future<void> setVoiceResponseEnabled(bool enabled) async {
    _voiceResponseEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_response_enabled', enabled);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _notificationsEnabled = true;
    _soundEnabled = true;
    _autoUpdateEnabled = true;
    _updateInterval = 60;
    _conversationStyle = ConversationStyle.friendly;
    _voiceResponseEnabled = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', true);
    await prefs.setBool('sound_enabled', true);
    await prefs.setBool('auto_update_enabled', true);
    await prefs.setInt('update_interval', 60);
    await prefs.setInt('conversation_style', 0);
    await prefs.setBool('voice_response_enabled', false);
    
    notifyListeners();
  }
} 