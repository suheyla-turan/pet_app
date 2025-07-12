import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  static Future<void> showBirthdayNotification(String petName) async {
    await initialize();
    
    const androidDetails = AndroidNotificationDetails(
      'birthday_channel',
      'Doğum Günü Bildirimleri',
      channelDescription: 'Evcil hayvan doğum günü bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '🎉 Doğum Günü!',
      '$petName\'ın doğum günü bugün! Onu özel hissettirmeyi unutmayın!',
      details,
    );
  }

  static Future<void> showLowValueNotification(String petName, String valueType) async {
    await initialize();
    
    const androidDetails = AndroidNotificationDetails(
      'care_channel',
      'Bakım Bildirimleri',
      channelDescription: 'Evcil hayvan bakım bildirimleri',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '⚠️ Bakım Gerekli',
      '$petName\'ın $valueType değeri düşük! Lütfen kontrol edin.',
      details,
    );
  }

  static Future<void> saveLastBirthdayCheck(String petId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_birthday_$petId', date.toIso8601String());
  }

  static Future<DateTime?> getLastBirthdayCheck(String petId) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('last_birthday_$petId');
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }
} 