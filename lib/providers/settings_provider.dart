import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // Added for TimeOfDay

enum ConversationStyle {
  friendly,
  professional,
  playful,
  caring,
}

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _autoUpdateEnabled = true;
  int _updateInterval = 60; // dakika
  ConversationStyle _conversationStyle = ConversationStyle.friendly;
  bool _voiceResponseEnabled = false;
  String? _ttsVoice;
  double _ttsRate = 0.3;
  double _ttsPitch = 1.0;
  String? _notificationSound;
  bool _scheduledNotificationsEnabled = false;
  TimeOfDay _scheduledNotificationTime = const TimeOfDay(hour: 9, minute: 0);
  Locale? _locale;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get autoUpdateEnabled => _autoUpdateEnabled;
  int get updateInterval => _updateInterval;
  ConversationStyle get conversationStyle => _conversationStyle;
  bool get voiceResponseEnabled => _voiceResponseEnabled;
  String? get ttsVoice => _ttsVoice;
  double get ttsRate => _ttsRate;
  double get ttsPitch => _ttsPitch;
  String? get notificationSound => _notificationSound;
  bool get scheduledNotificationsEnabled => _scheduledNotificationsEnabled;
  TimeOfDay get scheduledNotificationTime => _scheduledNotificationTime;
  Locale? get locale => _locale;

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
      _ttsVoice = prefs.getString('tts_voice');
      _ttsRate = prefs.getDouble('tts_rate') ?? 0.3;
      _ttsPitch = prefs.getDouble('tts_pitch') ?? 1.0;
      
      _notificationSound = prefs.getString('notification_sound');
      _scheduledNotificationsEnabled = prefs.getBool('scheduled_notifications_enabled') ?? false;
      final hour = prefs.getInt('scheduled_notification_hour') ?? 9;
      final minute = prefs.getInt('scheduled_notification_minute') ?? 0;
      _scheduledNotificationTime = TimeOfDay(hour: hour, minute: minute);
      
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

  Future<void> setTtsVoice(String? voice) async {
    _ttsVoice = voice;
    final prefs = await SharedPreferences.getInstance();
    if (voice == null) {
      await prefs.remove('tts_voice');
    } else {
      await prefs.setString('tts_voice', voice);
    }
    notifyListeners();
  }

  Future<void> setTtsRate(double rate) async {
    _ttsRate = rate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_rate', rate);
    notifyListeners();
  }

  Future<void> setTtsPitch(double pitch) async {
    _ttsPitch = pitch;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_pitch', pitch);
    notifyListeners();
  }

  Future<void> setNotificationSound(String? sound) async {
    _notificationSound = sound;
    final prefs = await SharedPreferences.getInstance();
    if (sound == null) {
      await prefs.remove('notification_sound');
    } else {
      await prefs.setString('notification_sound', sound);
    }
    notifyListeners();
  }

  Future<void> setScheduledNotificationsEnabled(bool enabled) async {
    _scheduledNotificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('scheduled_notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> setScheduledNotificationTime(TimeOfDay time) async {
    _scheduledNotificationTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('scheduled_notification_hour', time.hour);
    await prefs.setInt('scheduled_notification_minute', time.minute);
    notifyListeners();
  }

  void setLocale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _notificationsEnabled = true;
    _soundEnabled = true;
    _autoUpdateEnabled = true;
    _updateInterval = 60;
    _conversationStyle = ConversationStyle.friendly;
    _voiceResponseEnabled = false;
    _ttsVoice = null;
    _ttsRate = 0.3;
    _ttsPitch = 1.0;
    _notificationSound = null;
    _scheduledNotificationsEnabled = false;
    _scheduledNotificationTime = const TimeOfDay(hour: 9, minute: 0);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', true);
    await prefs.setBool('sound_enabled', true);
    await prefs.setBool('auto_update_enabled', true);
    await prefs.setInt('update_interval', 60);
    await prefs.setInt('conversation_style', 0);
    await prefs.setBool('voice_response_enabled', false);
    await prefs.remove('tts_voice');
    await prefs.setDouble('tts_rate', 0.3);
    await prefs.setDouble('tts_pitch', 1.0);
    await prefs.remove('notification_sound');
    await prefs.setBool('scheduled_notifications_enabled', false);
    await prefs.setInt('scheduled_notification_hour', 9);
    await prefs.setInt('scheduled_notification_minute', 0);
    
    notifyListeners();
  }
} 