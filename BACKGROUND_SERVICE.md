# Background Service - Evcil Hayvan Değer Güncelleme

Bu dokümantasyon, uygulama çalışmıyorken de evcil hayvan değerlerinin (tokluk, enerji, mutluluk, bakım) otomatik olarak güncellenmesi için geliştirilen background service sistemini açıklar.

## 🎯 Amaç

- Uygulama kapalıyken evcil hayvan değerlerini otomatik güncelle
- Kritik değer seviyelerinde bildirim gönder
- Doğum günü ve aşı hatırlatmalarını yap
- Periyodik kontrolleri gerçekleştir

## 🏗️ Mimari

### 1. WorkManager Entegrasyonu
- **workmanager** paketi kullanılarak background task'lar yönetilir
- Android ve iOS'ta native background processing sağlanır
- Sistem restart'larından sonra otomatik olarak devam eder

### 2. Periyodik Görevler
- **15 dakikada bir**: Evcil hayvan değerleri kontrol edilir
- **Manuel task**: Kullanıcı istediğinde tetiklenebilir

### 3. Firebase Entegrasyonu
- Firestore'da evcil hayvan verileri güncellenir
- Real-time veri senkronizasyonu sağlanır

## 📱 Platform Desteği

### Android
- `WAKE_LOCK` izni ile background processing
- `RECEIVE_BOOT_COMPLETED` ile sistem restart sonrası devam
- `FOREGROUND_SERVICE` ile ön plan servisi desteği

### iOS
- `background-processing` modu
- `background-fetch` ile periyodik güncelleme
- `remote-notification` desteği

## 🔧 Kurulum

### 1. Gerekli Paketler
```yaml
dependencies:
  workmanager: ^0.5.2
  background_fetch: ^1.3.2
  flutter_local_notifications: ^17.2.2
  shared_preferences: ^2.2.2
```

### 2. Android Manifest
```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

### 3. iOS Info.plist
```xml
<key>UIBackgroundModes</key>
<array>
    <string>background-processing</string>
    <string>background-fetch</string>
    <string>remote-notification</string>
</array>
```

## 🚀 Kullanım

### 1. Service Başlatma
```dart
// main.dart'ta
await BackgroundService.initialize();

// PetProvider'da
await initializeBackgroundService();
```

### 2. Manuel Task Başlatma
```dart
await BackgroundService.startBackgroundTask();
```

### 3. Service Durdurma
```dart
await BackgroundService.stopBackgroundTask();
```

## 📊 Değer Güncelleme Mantığı

### Tokluk (Satiety)
- **Interval**: 60 dakika (varsayılan)
- **Azalma**: Her interval'da 1 puan
- **Kritik seviye**: ≤2 (acil bildirim)
- **Düşük seviye**: ≤4 (normal bildirim)

### Mutluluk (Happiness)
- **Interval**: 60 dakika (varsayılan)
- **Azalma**: Her interval'da 1 puan
- **Kritik seviye**: ≤2 (acil bildirim)
- **Düşük seviye**: ≤4 (normal bildirim)

### Enerji (Energy)
- **Interval**: 60 dakika (varsayılan)
- **Azalma**: Her interval'da 1 puan
- **Kritik seviye**: ≤2 (acil bildirim)
- **Düşük seviye**: ≤4 (normal bildirim)

### Bakım (Care)
- **Interval**: 1440 dakika (24 saat)
- **Azalma**: Her interval'da 1 puan
- **Kritik seviye**: ≤2 (acil bildirim)
- **Düşük seviye**: ≤4 (normal bildirim)

## 🔔 Bildirim Sistemi

### Kritik Durum Bildirimleri
- **Ses**: Özel kritik uyarı sesi
- **Öncelik**: Yüksek
- **Görsel**: 🚨 KRİTİK DURUM! ikonu

### Düşük Değer Bildirimleri
- **Ses**: Standart bildirim sesi
- **Öncelik**: Normal
- **Görsel**: ⚠️ Bakım Gerekli ikonu

### Özel Bildirimler
- **Doğum günü**: 🎉 Doğum Günü!
- **Aşı vakti**: 💉 Aşı Vakti!
- **Eş sahip mesajları**: 💬 Yeni Mesaj

## 🧪 Test

### Background Service Test Sayfası
- `lib/features/debug/background_service_test_page.dart`
- Service durumunu kontrol etme
- Manuel task başlatma
- Service durdurma

### Test Senaryoları
1. **Uygulama açık**: Normal timer ile güncelleme
2. **Uygulama arka planda**: Background service ile güncelleme
3. **Uygulama kapalı**: WorkManager ile güncelleme
4. **Sistem restart**: Otomatik service başlatma

## ⚠️ Sınırlamalar

### Android
- Battery optimization kısıtlamaları
- Doze mode etkileri
- Background process kısıtlamaları

### iOS
- Background execution time limitleri
- Background app refresh kısıtlamaları
- System resource kısıtlamaları

## 🔍 Debug ve Loglama

### Console Logları
```dart
print('✅ Background service başlatıldı');
print('❌ Background service başlatılamadı: $e');
print('Background task error: $e');
```

### SharedPreferences
- `last_background_update`: Son güncelleme zamanı
- `last_birthday_$petId`: Son doğum günü kontrolü
- `last_vaccine_$petId`: Son aşı kontrolü

## 🚨 Hata Yönetimi

### Firebase Bağlantı Hataları
- Retry mekanizması
- Offline cache desteği
- Graceful degradation

### Bildirim Hataları
- Fallback bildirim sistemi
- Local notification backup
- Error logging

## 🔄 Gelecek Geliştirmeler

1. **Smart Scheduling**: Kullanıcı davranışlarına göre interval ayarlama
2. **Machine Learning**: Değer azalma hızını öğrenme
3. **Offline Support**: İnternet olmadığında local güncelleme
4. **Custom Intervals**: Kullanıcı tanımlı güncelleme sıklığı
5. **Analytics**: Background service performans metrikleri

## 📚 Referanslar

- [WorkManager Documentation](https://pub.dev/packages/workmanager)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Android Background Processing](https://developer.android.com/guide/background)
- [iOS Background Execution](https://developer.apple.com/documentation/backgroundtasks)
