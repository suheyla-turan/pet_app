import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _autoUpdateEnabled = true;
  int _updateInterval = 60; // dakika

  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get autoUpdateEnabled => _autoUpdateEnabled;
  int get updateInterval => _updateInterval;

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

  Future<void> resetToDefaults() async {
    _notificationsEnabled = true;
    _soundEnabled = true;
    _autoUpdateEnabled = true;
    _updateInterval = 60;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', true);
    await prefs.setBool('sound_enabled', true);
    await prefs.setBool('auto_update_enabled', true);
    await prefs.setInt('update_interval', 60);
    
    notifyListeners();
  }
} 