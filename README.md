# 🐾 PatiTakip - Evcil Hayvan Bakım Uygulaması

Modern Flutter ile geliştirilmiş, AI destekli kapsamlı evcil hayvan bakım ve takip uygulaması.

## 🌟 Öne Çıkan Özellikler

### 🐕 Evcil Hayvan Yönetimi
- **Kapsamlı Profil Sistemi**: Evcil hayvan ekleme, düzenleme, silme
- **Detaylı Bilgi Takibi**: İsim, tür, cinsiyet, doğum tarihi, ağırlık, renk
- **Fotoğraf Yönetimi**: Galeri veya kamera ile fotoğraf ekleme
- **Çoklu Sahip Desteği**: Her hayvana birden fazla sahip ekleme ve yönetimi

### 📊 Akıllı Durum Takibi
- **4 Temel Metrik**: Açlık, mutluluk, enerji, bakım seviyeleri
- **Görsel Göstergeler**: Progress bar'lar ile anlık durum görüntüleme
- **Otomatik Azalma**: Zamanla doğal olarak azalan değerler
- **Sesli Geri Bildirim**: Her bakım işleminde hayvan adıyla sesli onay

### 💉 Gelişmiş Aşı Takip Sistemi
- **Ayrı Listeler**: Yapılacak ve yapılmış aşılar için ayrı sayfalar
- **Akıllı Filtreleme**: Otomatik liste güncelleme ve filtreleme
- **Kolay İşaretleme**: Tik atarak aşıları tamamlama
- **Tarih Yönetimi**: Geçmiş ve gelecek aşılar için esnek tarih sistemi
- **Otomatik Bildirimler**: Planlanan aşılar için zamanlı hatırlatmalar

### 🤖 AI Destekli Sohbet Sistemi
- **Çoklu Mesajlı Sohbet**: Her hayvan için ayrı AI sohbet geçmişi
- **Sohbet Geçmişi**: Geçmiş konuşmaları görüntüleme ve detayları
- **Sesli Yanıt (TTS)**: Her AI mesajını sesli dinleme (hoparlör butonu)
- **Sesli Mesaj Yazma**: Whisper STT ile AI'ya sesli mesaj gönderme
- **Sürekli Dinleme**: AI asistan ile sürekli sesli iletişim

### 🎤 Gelişmiş Ses Özellikleri
- **Sesli Komut Sistemi**: Doğal dil ile komut verme
- **Ses Mesajları**: Chat için ses kayıt ve oynatma
- **Çoklu Ses Servisi**: Ses kayıt, AI dinleme, TTS entegrasyonu
- **Çakışma Yönetimi**: Akıllı ses servisi koordinasyonu

### 📷 Medya Desteği
- **Görsel Mesajlar**: Galeri ve kamera ile resim gönderme
- **Ses Dosyaları**: AAC formatında ses kayıt ve oynatma
- **Resim Önizleme**: Büyük görüntüleme ve açıklama ekleme
- **Dosya Yönetimi**: Geçici dosya sistemi ile optimizasyon

### 🔔 Akıllı Bildirim Sistemi
- **Doğum Günü Bildirimleri**: Otomatik kutlama ve sesli mesajlar
- **Aşı Hatırlatmaları**: Planlanan aşılar için zamanlı bildirimler
- **Özelleştirilebilir Sesler**: Kendi bildirim sesinizi seçme
- **Zamanlı Bildirimler**: Belirli saatte hatırlatma sistemi

### 🌐 Çoklu Dil Desteği
- **Tam Lokalizasyon**: Türkçe/İngilizce tam destek
- **Dinamik Değişim**: Anında dil değişimi ve güncelleme
- **ARB Tabanlı**: Flutter'ın resmi lokalizasyon sistemi
- **Kapsamlı Çeviri**: Tüm UI elementleri ve metinler

### 🎨 Kişiselleştirme
- **Açık/Koyu Tema**: Otomatik ve manuel tema seçimi
- **Konuşma Stili**: Dostane, profesyonel, eğlenceli, şefkatli
- **TTS Ayarları**: Ses seçimi, hız, perde kontrolü
- **Bildirim Tercihleri**: Zaman ve ses ayarları

### 🚀 Kullanıcı Deneyimi
- **Onboarding**: İlk kullanım rehberi ve kurulum
- **Draggable AI FAB**: Sürüklenebilir AI asistan butonu
- **Responsive Tasarım**: Tüm ekran boyutlarına uyum
- **Smooth Animations**: Akıcı geçişler ve animasyonlar

## 🛠️ Teknik Özellikler

### 📱 Platform Desteği
- **Android**: Tam destek (API 21+)
- **iOS**: Tam destek
- **Web**: Responsive web uygulaması
- **Windows**: Desktop uygulaması
- **macOS**: Desktop uygulaması
- **Linux**: Desktop uygulaması

### 🔧 Mimari
- **Provider Pattern**: Merkezi state yönetimi
- **Clean Architecture**: Katmanlı mimari yapısı
- **Firebase Backend**: Cloud Firestore, Authentication
- **AI Integration**: OpenAI GPT ve Whisper API
- **Local Storage**: SharedPreferences ile yerel veri

### 📦 Kullanılan Teknolojiler
- **Flutter 3.8+**: Cross-platform framework
- **Firebase**: Backend ve authentication
- **OpenAI API**: GPT-4 ve Whisper entegrasyonu
- **Provider**: State management
- **Flutter TTS**: Text-to-Speech
- **Flutter Sound**: Ses kayıt ve oynatma
- **Image Picker**: Medya seçimi
- **Local Notifications**: Bildirim sistemi

## 🚀 Kurulum ve Yapılandırma

### 1. Sistem Gereksinimleri
```bash
Flutter SDK: ^3.8.1
Dart SDK: ^3.8.1
Android Studio / VS Code
Git
```

### 2. Projeyi Klonlayın
```bash
git clone <repository-url>
cd pet_app
```

### 3. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 4. API Key Yapılandırması

#### 🔑 Güvenlik Önemli!
API key'lerinizi güvenli bir şekilde yapılandırmanız gerekiyor:

1. `lib/secrets_example.dart` dosyasını `lib/secrets.dart` olarak kopyalayın
2. API key'lerinizi `lib/secrets.dart` dosyasına ekleyin:

```dart
const String openaiApiKey = 'YOUR_ACTUAL_OPENAI_API_KEY';
const String firebaseApiKey = 'YOUR_ACTUAL_FIREBASE_API_KEY';
```

#### 📋 Gerekli API Key'ler:

1. **OpenAI API Key** 
   - [OpenAI Platform](https://platform.openai.com/api-keys) adresinden alın
   - GPT-4 ve Whisper API erişimi gerekli

2. **Firebase API Key**
   - [Firebase Console](https://console.firebase.google.com/) adresinden alın
   - Authentication ve Firestore erişimi gerekli

### 5. Firebase Yapılandırması

1. **Firebase Projesi Oluşturun**
   ```bash
   # Firebase CLI kurulumu
   npm install -g firebase-tools
   firebase login
   firebase init
   ```

2. **Android Yapılandırması**
   - Firebase Console'da Android uygulaması ekleyin
   - `google-services.json` dosyasını `android/app/` klasörüne yerleştirin
   - Package name: `com.example.pati_takip`

3. **iOS Yapılandırması**
   - Firebase Console'da iOS uygulaması ekleyin
   - `GoogleService-Info.plist` dosyasını `ios/Runner/` klasörüne yerleştirin
   - Bundle ID: `com.example.patiTakip`

4. **Firestore Database**
   - Firestore Database'i etkinleştirin
   - Güvenlik kurallarını yapılandırın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /users/{userId}/pets/{petId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /users/{userId}/pets/{petId}/vaccines/{vaccineId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /users/{userId}/pets/{petId}/chat/{messageId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 6. İzinler

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Bu uygulama ses kaydı için mikrofon izni gerektirir</string>
<key>NSCameraUsageDescription</key>
<string>Bu uygulama fotoğraf çekimi için kamera izni gerektirir</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Bu uygulama fotoğraf seçimi için galeri izni gerektirir</string>
```

### 7. Uygulamayı Çalıştırın
```bash
# Debug modunda çalıştırma
flutter run

# Release build
flutter build apk --release
flutter build ios --release
```

## 📱 Kullanım Kılavuzu

### 🐕 Evcil Hayvan Ekleme
1. Ana sayfada **+** butonuna tıklayın
2. Hayvan bilgilerini doldurun:
   - İsim, tür, cinsiyet
   - Doğum tarihi, ağırlık, renk
   - Fotoğraf (opsiyonel)
3. **Kaydet** butonuna tıklayın

### 🍖 Bakım İşlemleri
- **Besle**: Açlık seviyesini azaltır + sesli "Afiyet olsun [isim]"
- **Sev**: Mutluluk seviyesini artırır + sesli "Sen harika bir dostsun [isim]"
- **Dinlendir**: Enerji seviyesini artırır + sesli "İyi uykular [isim]"
- **Bakım**: Bakım seviyesini artırır + sesli "Bakım zamanı, aferin [isim]"

### 💉 Aşı Yönetimi
1. **Yapılacak Aşılar** sayfasına gidin
2. **+** butonu ile yeni aşı ekleyin
3. Aşı türü, tarih ve açıklama girin
4. **Tik** atarak aşıyı tamamlayın
5. Aşı otomatik olarak **Yapılmış Aşılar** listesine taşınır

### 🤖 AI Sohbet Özellikleri
1. **AI Chat** sayfasına gidin
2. **Sesli Komut** butonu ile komut verin
3. **Hoparlör** butonu ile AI yanıtını dinleyin
4. **Sohbet Geçmişi** ile önceki konuşmaları görüntüleyin

### 🎤 Sesli Komutlar
Desteklenen komut örnekleri:
- "Duman'ı besle"
- "Bakım yap"
- "Bugün kuduz aşısı yaptırdım"
- "5 gün sonra karma aşı ekle"
- "Duman'ın durumu nasıl"

### 📷 Medya Mesajları
1. **Ses Mesajı**: Mikrofon butonu ile kayıt
2. **Görsel Mesaj**: Resim butonu ile galeri/kamera
3. **Büyük Görüntüleme**: Resimlere tıklayarak önizleme

### ⚙️ Ayarlar
- **Tema**: Açık/Koyu tema seçimi
- **Dil**: Türkçe/İngilizce dil değişimi
- **TTS**: Ses, hız, perde ayarları
- **Bildirimler**: Zaman ve ses tercihleri
- **Konuşma Stili**: AI asistan kişiliği

## 📁 Proje Yapısı

```
lib/
├── features/                    # Özellik bazlı klasörler
│   ├── onboarding/             # İlk kurulum
│   │   └── onboarding_page.dart
│   ├── pet/                    # Evcil hayvan özellikleri
│   │   ├── models/             # Veri modelleri
│   │   │   ├── pet.dart
│   │   │   ├── vaccine.dart
│   │   │   └── ai_chat_message.dart
│   │   ├── screens/            # Ekranlar
│   │   │   ├── pet_list_page.dart
│   │   │   ├── pet_detail_page.dart
│   │   │   ├── pet_form_page.dart
│   │   │   ├── vaccine_page.dart
│   │   │   ├── ai_chat_page.dart
│   │   │   ├── ai_chat_history_page.dart
│   │   │   ├── settings_page.dart
│   │   │   ├── about_page.dart
│   │   │   └── feedback_page.dart
│   │   └── widgets/            # Özel widget'lar
│   │       ├── chat_message_widget.dart
│   │       ├── progress_indicator.dart
│   │       └── voice_command_widget.dart
│   └── profile/                # Profil özellikleri
│       └── profile_page.dart
├── providers/                  # State management
│   ├── pet_provider.dart       # Evcil hayvan yönetimi
│   ├── ai_provider.dart        # AI sohbet ve ses
│   ├── auth_provider.dart      # Kimlik doğrulama
│   ├── settings_provider.dart  # Ayarlar
│   └── theme_provider.dart     # Tema yönetimi
├── services/                   # Servisler
│   ├── firestore_service.dart  # Firebase veritabanı
│   ├── openai_service.dart     # OpenAI API
│   ├── whisper_service.dart    # Whisper STT
│   ├── notification_service.dart # Bildirimler
│   ├── media_service.dart      # Medya işlemleri
│   ├── voice_service.dart      # Ses servisleri
│   ├── auth_service.dart       # Kimlik doğrulama
│   ├── firebase_config.dart    # Firebase yapılandırması
│   └── realtime_service.dart   # Gerçek zamanlı veri
├── widgets/                    # Genel widget'lar
│   └── ai_fab.dart            # AI asistan butonu
├── l10n/                      # Lokalizasyon
│   ├── app_en.arb            # İngilizce çeviriler
│   ├── app_tr.arb            # Türkçe çeviriler
│   ├── app_localizations.dart # Lokalizasyon sınıfı
│   ├── app_localizations_en.dart
│   └── app_localizations_tr.dart
├── secrets.dart               # API key'ler (güvenli)
├── firebase_options.dart      # Firebase yapılandırması
└── main.dart                  # Ana uygulama
```

## 🔧 Geliştirme

### Kod Standartları
- **Dart/Flutter Lints**: Otomatik kod analizi
- **Provider Pattern**: State management
- **Null Safety**: Tam null safety desteği
- **Async/Await**: Asenkron işlemler
- **Error Handling**: Kapsamlı hata yönetimi

### Test
```bash
# Unit testler
flutter test

# Widget testler
flutter test test/widget_test.dart

# Integration testler
flutter drive --target=test_driver/app.dart
```

### Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🚨 Önemli Notlar

### 🔒 Güvenlik
1. **API Key'leri Asla Paylaşmayın!**
2. `lib/secrets.dart` dosyasını GitHub'a yüklemeyin
3. Production'da environment variables kullanın
4. Firebase güvenlik kurallarını düzenli kontrol edin

### 📱 Platform Özellikleri
- **Android**: Tam destek, tüm özellikler aktif
- **iOS**: Tam destek, App Store uyumlu
- **Web**: Responsive tasarım, PWA desteği
- **Desktop**: Windows, macOS, Linux desteği

### 🔄 Güncellemeler
- Flutter SDK güncellemeleri
- Firebase SDK güncellemeleri
- OpenAI API güncellemeleri
- Güvenlik yamaları

## 🤝 Katkıda Bulunma

1. **Fork** yapın
2. **Feature branch** oluşturun (`git checkout -b feature/amazing-feature`)
3. **Commit** yapın (`git commit -m 'Add amazing feature'`)
4. **Push** yapın (`git push origin feature/amazing-feature`)
5. **Pull Request** oluşturun

### Katkı Kuralları
- Kod standartlarına uyun
- Test yazın
- Dokümantasyon güncelleyin
- Güvenlik kurallarına uyun

## 📄 Lisans

Bu proje **MIT lisansı** altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 📞 İletişim ve Destek

- **Issues**: [GitHub Issues](https://github.com/username/peti_takip/issues)
- **Discussions**: [GitHub Discussions](https://github.com/username/peti_takip/discussions)
- **Wiki**: [Proje Wiki](https://github.com/username/peti_takip/wiki)

## 🙏 Teşekkürler

- **Flutter Team**: Harika framework için
- **Firebase Team**: Backend servisleri için
- **OpenAI Team**: AI API'leri için
- **Tüm Katkıda Bulunanlar**: Projeye destek için

---

**⚠️ Güvenlik Uyarısı**: API key'lerinizi güvenli tutun ve asla public repository'lere yüklemeyin!

**🐾 PatiTakip** - Evcil hayvanlarınız için en iyi bakım deneyimi! 🐕❤️
