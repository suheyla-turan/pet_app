# 🐾 Mini Pet App

Evcil hayvan bakım uygulaması - Flutter ile geliştirilmiş modern bir mobil uygulama.

## ✨ Özellikler

- 🐕 Evcil hayvan yönetimi (ekleme, düzenleme, silme)
- 📊 Durum takibi (açlık, mutluluk, enerji, bakım)
- 💉 Aşı takibi ve hatırlatmaları
- 🤖 AI destekli bakım önerileri (Gemini API)
- 🔔 Akıllı bildirimler
- 🎨 Açık/Koyu tema desteği
- ⚙️ Kapsamlı ayarlar
- 🔒 Güvenli API key yönetimi

## 🚀 Kurulum

### 1. Projeyi Klonlayın
```bash
git clone <repository-url>
cd pet_app
```

### 2. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 3. API Key'leri Yapılandırın

#### 🔑 Güvenlik Önemli!
API key'lerinizi güvenli bir şekilde yapılandırmanız gerekiyor:

1. `lib/secrets_example.dart` dosyasını `lib/secrets.dart` olarak kopyalayın
2. API key'lerinizi `lib/secrets.dart` dosyasına ekleyin:

```dart
const String geminiApiKey = 'YOUR_ACTUAL_GEMINI_API_KEY';
const String firebaseApiKey = 'YOUR_ACTUAL_FIREBASE_API_KEY';
```

#### 📋 Gerekli API Key'ler:

1. **Gemini API Key** (Google AI Studio'dan alın)
   - [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
   - Yeni API key oluşturun
   - `geminiApiKey` değişkenine ekleyin

2. **Firebase API Key** (Firebase Console'dan alın)
   - [Firebase Console](https://console.firebase.google.com/) adresine gidin
   - Projenizi seçin
   - Project Settings > General > Web API Key
   - `firebaseApiKey` değişkenine ekleyin

### 4. Firebase Yapılandırması

1. Firebase Console'da yeni proje oluşturun
2. Android uygulaması ekleyin
3. `google-services.json` dosyasını `android/app/` klasörüne yerleştirin
4. Firestore Database'i etkinleştirin
5. Güvenlik kurallarını yapılandırın

### 5. Uygulamayı Çalıştırın
```bash
flutter run
```

## 🔒 Güvenlik

### API Key Güvenliği
- ✅ `lib/secrets.dart` dosyası `.gitignore`'da
- ✅ API key'ler GitHub'a yüklenmez
- ✅ Production'da environment variables kullanın

### Firebase Güvenlik Kuralları
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /hayvanlar/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📱 Kullanım

### Evcil Hayvan Ekleme
1. Ana sayfada + butonuna tıklayın
2. Hayvan bilgilerini doldurun
3. Fotoğraf ekleyin (opsiyonel)
4. Kaydet'e tıklayın

### Bakım İşlemleri
- **Besle**: Açlık seviyesini azaltır
- **Sev**: Mutluluk seviyesini artırır
- **Dinlendir**: Enerji seviyesini artırır
- **Bakım**: Bakım seviyesini artırır

### AI Önerileri
- Mama önerileri
- Oyun önerileri
- Bakım önerileri
- Özel sorular sorabilme

## 🛠️ Teknik Detaylar

### State Management
- **Provider Pattern** kullanılıyor
- Merkezi state yönetimi
- Reactive UI güncellemeleri

### Provider'lar
- `PetProvider`: Evcil hayvan yönetimi
- `AIProvider`: AI servisleri
- `ThemeProvider`: Tema yönetimi
- `SettingsProvider`: Uygulama ayarları

### Güvenlik Özellikleri
- API key'ler güvenli dosyada
- Firebase güvenlik kuralları
- Production ortamı kontrolleri
- Hata yönetimi

## 📁 Proje Yapısı

```
lib/
├── features/
│   └── pet/
│       ├── models/
│       ├── screens/
│       └── widgets/
├── providers/
│   ├── pet_provider.dart
│   ├── ai_provider.dart
│   ├── theme_provider.dart
│   └── settings_provider.dart
├── services/
│   ├── firestore_service.dart
│   ├── gemini_service.dart
│   ├── notification_service.dart
│   └── firebase_config.dart
├── secrets.dart (güvenli API key'ler)
└── main.dart
```

## 🚨 Önemli Notlar

1. **API Key'leri Asla Paylaşmayın!**
2. `lib/secrets.dart` dosyasını GitHub'a yüklemeyin
3. Production'da environment variables kullanın
4. Firebase güvenlik kurallarını düzenli kontrol edin

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 📞 İletişim

Sorularınız için issue açabilir veya pull request gönderebilirsiniz.

---

**⚠️ Güvenlik Uyarısı**: API key'lerinizi güvenli tutun ve asla public repository'lere yüklemeyin!
