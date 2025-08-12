import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // Locale için

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
      
      // Locale yükle
      final localeCode = prefs.getString('locale');
      if (localeCode != null) {
        _locale = Locale(localeCode);
      } else {
        // İlk açılışta cihaz dili Türkçe ise otomatik Türkçe yap
        final deviceLocale = window.locale.languageCode;
        if (deviceLocale == 'tr') {
          _locale = const Locale('tr');
        } else {
          _locale = null;
        }
      }
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



  void setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove('locale');
    } else {
      await prefs.setString('locale', locale.languageCode);
    }
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
    
    notifyListeners();
  }
} 