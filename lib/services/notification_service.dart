import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  /// Kritik durum bildirimi - evcil hayvan değerleri çok düşük olduğunda
  static Future<void> showCriticalStatusNotification(String petName, String valueType, {String? customSound}) async {
    await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      'critical_channel',
      'Kritik Durum Bildirimleri',
      channelDescription: 'Evcil hayvan kritik durum bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      sound: customSound != null ? RawResourceAndroidNotificationSound(customSound) : null,
      color: const Color(0xFFFF0000), // Kırmızı renk
    );
    
    final iosDetails = DarwinNotificationDetails(
      sound: customSound != null ? '$customSound.wav' : null,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      '🚨 KRİTİK DURUM!',
      '$petName\'ın $valueType değeri kritik seviyede! Acil müdahale gerekli!',
      details,
    );
  }

  /// Doğum günü bildirimi
  static Future<void> showBirthdayNotification(String petName, {String? customSound}) async {
    await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      'birthday_channel',
      'Doğum Günü Bildirimleri',
      channelDescription: 'Evcil hayvan doğum günü bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      sound: customSound != null ? RawResourceAndroidNotificationSound(customSound) : null,
      color: const Color(0xFFFFD700), // Altın sarısı
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

  /// Aşı vakti bildirimi
  static Future<void> showVaccineDueNotification(String petName, String vaccineName, {String? customSound}) async {
    await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      'vaccine_channel',
      'Aşı Bildirimleri',
      channelDescription: 'Evcil hayvan aşı hatırlatma bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      sound: customSound != null ? RawResourceAndroidNotificationSound(customSound) : null,
      color: const Color(0xFF00BFFF), // Mavi
    );
    
    final iosDetails = DarwinNotificationDetails(
      sound: customSound != null ? '$customSound.wav' : null,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3,
      '💉 Aşı Vakti!',
      '$petName için $vaccineName aşısının vakti geldi! Veteriner randevusu almayı unutmayın!',
      details,
    );
  }

  /// Eş sahipten mesaj bildirimi
  static Future<void> showCoOwnerMessageNotification(String petName, String senderName, String message, {String? customSound}) async {
    await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      'message_channel',
      'Mesaj Bildirimleri',
      channelDescription: 'Eş sahiplerden gelen mesaj bildirimleri',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      sound: customSound != null ? RawResourceAndroidNotificationSound(customSound) : null,
      color: const Color(0xFF32CD32), // Yeşil
    );
    
    final iosDetails = DarwinNotificationDetails(
      sound: customSound != null ? '$customSound.wav' : null,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Mesaj çok uzunsa kısalt
    final shortMessage = message.length > 50 ? '${message.substring(0, 50)}...' : message;

    await _notifications.show(
      4,
      '💬 Yeni Mesaj',
      '$senderName\'dan $petName hakkında: $shortMessage',
      details,
    );
  }

  /// Düşük değer bildirimi (mevcut)
  static Future<void> showLowValueNotification(String petName, String valueType, {String? customSound}) async {
    await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      'care_channel',
      'Bakım Bildirimleri',
      channelDescription: 'Evcil hayvan bakım bildirimleri',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
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
      icon: '@mipmap/ic_launcher',
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
      icon: '@mipmap/ic_launcher',
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

  /// Aşı kontrolü için son kontrol tarihini kaydet
  static Future<void> saveLastVaccineCheck(String petId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_vaccine_$petId', date.toIso8601String());
  }

  /// Aşı kontrolü için son kontrol tarihini getir
  static Future<DateTime?> getLastVaccineCheck(String petId) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('last_vaccine_$petId');
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }
} 