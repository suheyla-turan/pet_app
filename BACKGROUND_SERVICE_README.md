# Background Service - Evcil Hayvan Takip Uygulaması

Bu dokümantasyon, PatiTakip uygulamasının background service özelliğini açıklar.

## 🎯 Amaç

Background service, uygulama kapalıyken de çalışarak evcil hayvanların sağlık durumlarını sürekli olarak kontrol eder ve gerekli bildirimleri gönderir.

## 🔧 Teknik Detaylar

### Kullanılan Teknolojiler
- **WorkManager**: Android ve iOS için background task yönetimi
- **Firebase**: Veritabanı ve authentication
- **Flutter Local Notifications**: Bildirim gönderimi
- **SharedPreferences**: Son kontrol zamanlarını saklama

### Çalışma Sıklığı
- **Ana Kontrol**: Her 1 saatte bir
- **Sağlık Kontrolü**: Her pet için son 1 saatte kontrol edilmediyse
- **Doğum Günü Kontrolü**: Her gün
- **Aşı Kontrolü**: Her gün
- **Veteriner Randevuları**: Her 1 saatte bir
- **Eş Sahip Mesajları**: Her 1 saatte bir

## 📱 Özellikler

### 1. Sağlık Değerleri Kontrolü
- **Su Seviyesi**: %20 altında kritik, %40 altında düşük bildirim
- **Yemek Seviyesi**: %20 altında kritik, %40 altında düşük bildirim
- **Enerji Seviyesi**: %20 altında kritik, %40 altında düşük bildirim
- **Mutluluk Seviyesi**: %20 altında kritik, %40 altında düşük bildirim

### 2. Doğum Günü Hatırlatmaları
- Pet'in doğum günü geldiğinde otomatik bildirim
- Günlük tekrar bildirim gönderilmez

### 3. Aşı Hatırlatmaları
- Aşı vakti geldiğinde otomatik bildirim
- Günlük tekrar bildirim gönderilmez

### 4. Veteriner Randevu Hatırlatmaları
- Randevuya 24 saat kala bildirim
- Randevuya 1 saat kala acil bildirim
- Tamamlanan randevular için bildirim gönderilmez

### 5. Eş Sahip Mesaj Bildirimleri
- Son 1 saatte gelen mesajlar için anında bildirim
- Günlük tekrar bildirim gönderilmez

## 🚀 Kurulum

### 1. Gerekli Paketler
```yaml
dependencies:
  workmanager: ^0.5.2
  flutter_local_notifications: ^17.2.2
  firebase_core: ^3.15.2
  cloud_firestore: ^5.6.12
  firebase_auth: ^5.7.0
  shared_preferences: ^2.2.2
```

### 2. Android Manifest
```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

<!-- WorkManager provider -->
<provider
    android:name="androidx.startup.InitializationProvider"
    android:authorities="${applicationId}.androidx-startup"
    android:exported="false">
    <meta-data
        android:name="androidx.work.WorkManagerInitializer"
        android:value="androidx.startup" />
</provider>
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

## 📋 Kullanım

### 1. Service Başlatma
```dart
// main.dart'ta otomatik başlatılır
await BackgroundService.initialize();
```

### 2. Manuel Kontrol
```dart
// Service durumunu kontrol et
bool isRunning = await BackgroundService.isRunning();

// Service'i durdur
await BackgroundService.stop();

// Service'i yeniden başlat
await BackgroundService.initialize();
```

### 3. Debug Sayfası
Settings > Debug Menüsü > Background Service Test

## 🔍 Debug ve Test

### Log Mesajları
Background service çalışırken console'da şu log'ları göreceksiniz:
```
Background task başlatıldı: petValueCheck
Firebase başlatıldı
Pet değerleri kontrol ediliyor...
Kullanıcı ID: [user_id]
2 pet bulundu
Pet kontrol ediliyor: [pet_name]
[pet_name] sağlık değerleri - Su: 85, Yemek: 90, Enerji: 75, Mutluluk: 95
[pet_name] için sağlık kontrolü tamamlandı
[pet_name] için veteriner randevusu bildirimi gönderiliyor
[pet_name] için eş sahip mesajı bildirimi gönderiliyor
Eş sahip mesajları kontrol edildi
Tüm pet değerleri kontrol edildi
```

### Test Bildirimi
Debug sayfasından test bildirimi gönderebilirsiniz:
```dart
await NotificationService.showCustomNotification(
  id: 999,
  title: 'Test Bildirimi',
  body: 'Background service çalışıyor!',
);
```

## ⚠️ Önemli Notlar

### 1. Pil Optimizasyonu
- Android'de pil optimizasyonu kapatılmalı
- iOS'ta background app refresh açık olmalı

### 2. Ağ Bağlantısı
- Service sadece ağ bağlantısı varken çalışır
- Firebase bağlantısı gerekli

### 3. Kullanıcı Girişi
- Service sadece kullanıcı giriş yapmışsa çalışır
- Giriş yapılmamışsa otomatik durur

### 4. Bildirim İzinleri
- Bildirim izinleri verilmiş olmalı
- iOS'ta notification permission gerekli

## 🐛 Sorun Giderme

### Service Çalışmıyor
1. Bildirim izinlerini kontrol edin
2. Pil optimizasyonunu kapatın
3. Uygulamayı yeniden başlatın
4. Debug sayfasından test edin

### Bildirim Gelmiyor
1. Bildirim sesini kontrol edin
2. Do not disturb modunu kapatın
3. Uygulama bildirim ayarlarını kontrol edin

### Firebase Hatası
1. İnternet bağlantısını kontrol edin
2. Firebase projesini kontrol edin
3. Authentication durumunu kontrol edin

## 📊 Performans

### Batarya Kullanımı
- Minimal batarya tüketimi
- Sadece gerekli durumlarda çalışır
- Akıllı kontrol aralıkları

### Ağ Kullanımı
- Sadece kontrol sırasında ağ kullanır
- Veri transferi minimal
- Offline durumda çalışmaz

## 🔮 Gelecek Özellikler

- [ ] Daha sık kontrol seçenekleri
- [ ] Özelleştirilebilir bildirim sesleri
- [ ] Offline bildirim desteği
- [ ] Geçmiş bildirim log'ları
- [ ] Bildirim istatistikleri

## 📞 Destek

Herhangi bir sorun yaşarsanız:
1. Debug sayfasından test edin
2. Console log'larını kontrol edin
3. Uygulama ayarlarını kontrol edin
4. Geliştirici ekibiyle iletişime geçin
