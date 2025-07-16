# 🐾 Mini Pet App

Evcil hayvan bakım uygulaması - Flutter ile geliştirilmiş modern bir mobil uygulama.

## ✨ Özellikler

- 🐕 Evcil hayvan yönetimi (ekleme, düzenleme, silme)
- 📊 Durum takibi (açlık, mutluluk, enerji, bakım)
- 💉 **Aşı takibi**: Yapılacak ve yapılmış aşılar ayrı, geçmiş ve gelecek aşılar için ekleme ve filtreleme
- ⏰ **Aşı hatırlatma bildirimi**: Yapılacak aşılar için seçilen tarihte otomatik bildirim
- 🤖 **AI destekli çoklu mesajlı sohbet**: Her hayvan için AI ile çoklu mesajlı sohbet, sohbet geçmişi ve detayları
- 🗣️ **Sesli yanıt (TTS)**: AI yanıtlarını ve sohbet mesajlarını sesli dinleyebilme (her mesaj için hoparlör butonu)
- 🎤 **Sesli mesaj yazma (STT)**: Mikrofona basarak AI'ya sesli mesaj yazdırabilme
- 🗨️ Günlük/Sohbet özelliği (pet ile anlık mesajlaşma)
- 👥 Çoklu kullanıcı/sahip ekleme ve yönetimi
- 🏁 Onboarding (ilk kurulum ve kullanıcıya rehberlik)
- 🎨 Açık/Koyu tema desteği
- ⚙️ Gelişmiş ayarlar (konuşma stili, ses seçimi, hız/perde, zamanlı bildirim)
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
2. **Firebase API Key** (Firebase Console'dan alın)

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

## 📱 Kullanım

### Evcil Hayvan Ekleme
1. Ana sayfada + butonuna tıklayın
2. Hayvan bilgilerini doldurun
3. Fotoğraf ekleyin (opsiyonel)
4. Kaydet'e tıklayın

### Bakım İşlemleri
- **Besle**: Açlık seviyesini azaltır (ve sesli olarak hayvan adıyla "Afiyet olsun ..." der)
- **Sev**: Mutluluk seviyesini artırır (ve sesli olarak hayvan adıyla "Sen harika bir dostsun ..." der)
- **Dinlendir**: Enerji seviyesini artırır (ve sesli olarak hayvan adıyla "İyi uykular ..." der)
- **Bakım**: Bakım seviyesini artırır (ve sesli olarak hayvan adıyla "Bakım zamanı, aferin ..." der)

### Aşı Takibi ve Bildirimler
- **Yapılacak Aşılar**: Sadece gelecekteki bir tarih seçilerek eklenebilir, seçilen tarihte otomatik bildirim gelir
- **Yapılmış Aşılar**: Geçmişte yaptırılan aşılar eklenebilir, ayrı listede görüntülenir
- **Aşılar iki ayrı sayfada**: "Yapılacak Aşılar" ve "Yapılmış Aşılar" butonları ile erişim
- **Aşıyı yaptırınca**: "Yapıldı" olarak işaretlenebilir, ilgili listeden diğerine taşınır

### AI Sohbet Özellikleri
- **Çoklu mesajlı sohbet**: Her hayvan için AI ile çoklu mesajlı sohbet ve sohbet geçmişi
- **Sohbet geçmişi ve detayları**: Geçmiş sohbetler listelenebilir ve detayları görüntülenebilir
- **Her AI mesajında hoparlör**: İstediğiniz AI mesajını sesli dinleyebilirsiniz
- **Sesli mesaj yazma**: Mikrofona basarak AI'ya sesli mesaj gönderebilirsiniz

### Bildirimler
- **Doğum günü bildirimi:** Hayvanın doğum gününde otomatik bildirim ve sesli kutlama
- **Zamanlı bildirimler:** Belirli saatte hatırlatma
- **Özel bildirimler:** Kendi bildirim sesinizi seçebilirsiniz
- **Aşı bildirimi:** Yapılacak aşılar için seçilen tarihte otomatik bildirim

### Çoklu Kullanıcı
- Her hayvana birden fazla sahip ekleyebilir, sahipleri yönetebilirsiniz.
- Ana kullanıcı (creator) ve diğer sahipler ayrımı

### Günlük/Sohbet
- Her hayvan için günlük mesajlaşma ve sohbet paneli

### Onboarding
- Uygulamayı ilk açan kullanıcıya rehberlik eden onboarding ekranı

### Gelişmiş Ayarlar
- Konuşma stili (dostane, profesyonel, eğlenceli, şefkatli)
- TTS ses seçimi, hız ve perde ayarı
- Zamanlı bildirim saati seçimi

## 🛠️ Teknik Detaylar

- **Provider Pattern** ile merkezi state yönetimi
- **AIProvider**: Çoklu mesajlı AI sohbeti, sesli okuma/yazma, sohbet geçmişi
- **PetProvider**: Evcil hayvan yönetimi ve bakım
- **NotificationService**: Zamanlı ve özel bildirimler, aşı hatırlatmaları
- **Güvenli API key yönetimi** ve Firebase güvenlik kuralları

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
