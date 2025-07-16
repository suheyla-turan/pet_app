import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

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

  static Future<void> showBirthdayNotification(String petName, {String? customSound}) async {
    await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      'birthday_channel',
      'Doğum Günü Bildirimleri',
      channelDescription: 'Evcil hayvan doğum günü bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      sound: customSound != null ? RawResourceAndroidNotificationSound(customSound) : null,
    );
    
    final iosDetails = DarwinNotificationDetails(
      sound: customSound != null ? '$customSound.wav' : null,
    );
    
    final details = NotificationDetails(
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

  static Future<void> showLowValueNotification(String petName, String valueType, {String? customSound}) async {
    await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      'care_channel',
      'Bakım Bildirimleri',
      channelDescription: 'Evcil hayvan bakım bildirimleri',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      sound: customSound != null ? RawResourceAndroidNotificationSound(customSound) : null,
    );
    
    final iosDetails = DarwinNotificationDetails(
      sound: customSound != null ? '$customSound.wav' : null,
    );
    
    final details = NotificationDetails(
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

  /// Belirli bir zamanda planlanmış bildirim (isteğe bağlı özel ses)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? androidSound,
    String? iosSound,
  }) async {
    await initialize();
    final androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Zamanlanmış Bildirimler',
      channelDescription: 'Zamanlanmış bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      sound: androidSound != null ? RawResourceAndroidNotificationSound(androidSound) : null,
    );
    final iosDetails = DarwinNotificationDetails(
      sound: iosSound,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    // Not: timezone paketi ve initializeTimeZones() main.dart'ta çağrılmalı!
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Anında özel bildirim göster (isteğe bağlı özel ses)
  /// [androidSound]: Android için raw resource dosya adı (uzantısız)
  /// [iosSound]: iOS için ses dosyası adı (uzantılı)
  static Future<void> showCustomNotification({
    required int id,
    required String title,
    required String body,
    String? androidSound,
    String? iosSound,
  }) async {
    await initialize();
    final androidDetails = AndroidNotificationDetails(
      'custom_channel',
      'Özel Bildirimler',
      channelDescription: 'Kullanıcı tanımlı bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      sound: androidSound != null ? RawResourceAndroidNotificationSound(androidSound) : null,
    );
    final iosDetails = DarwinNotificationDetails(
      sound: iosSound,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notifications.show(
      id,
      title,
      body,
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