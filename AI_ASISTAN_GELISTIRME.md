# AI Asistan Geliştirme ve Kullanım Kılavuzu

## 🚀 AI Asistan Özellikleri

### ✅ Mevcut Özellikler
- **Gerçek AI Entegrasyonu**: OpenAI GPT-3.5 ve Claude AI desteği
- **Kişiselleştirilmiş Yanıtlar**: Evcil hayvan bilgilerine göre özel tavsiyeler
- **Fallback Sistemi**: AI servisi çalışmazsa basit keyword matching
- **Çoklu Dil Desteği**: Türkçe ve İngilizce
- **Sesli Mesaj**: Mikrofon ile sesli soru sorma
- **Görsel Mesaj**: Fotoğraf ile soru sorma
- **Firebase Entegrasyonu**: Mesajların bulutta saklanması

### 🔧 Teknik Detaylar

#### AI Servisleri
1. **OpenAI GPT-3.5**: Birincil AI servisi
2. **Anthropic Claude**: Yedek AI servisi
3. **Fallback System**: Basit keyword matching

#### Prompt Mühendisliği
```dart
String _buildAIPrompt(String userMessage, String petContext) {
  return '''
Sen bir evcil hayvan bakım uzmanısın. Aşağıdaki evcil hayvan bilgileri ve kullanıcının sorusu verilmiştir.

$petContext

Kullanıcı Sorusu: $userMessage

Lütfen evcil hayvanın özel durumunu göz önünde bulundurarak, kişiselleştirilmiş, detaylı ve faydalı bir yanıt ver. Yanıtın:
1. Evcil hayvanın adını kullan
2. Yaş ve türe özel öneriler içersin
3. Mevcut durumunu (doygunluk, mutluluk, enerji, bakım) dikkate alsın
4. Pratik ve uygulanabilir tavsiyeler versin
5. Türkçe olarak yazılsın
6. 100-200 kelime arasında olsun

Yanıt:
''';
}
```

## 📱 Kullanım

### 1. AI Chat Sayfasına Erişim
- Pet detay sayfasından "AI Chat" butonuna tıklayın
- Veya ana menüden "AI Asistan" seçeneğini seçin

### 2. Soru Sorma
- **Metin ile**: Alt kısımdaki metin alanına sorunuzu yazın
- **Sesli**: Mikrofon butonuna basarak sesli soru sorun
- **Görsel**: Resim butonuna basarak fotoğraf ile soru sorun

### 3. AI Yanıtları
- AI, evcil hayvanınızın bilgilerini kullanarak kişiselleştirilmiş yanıt verir
- Yanıtlar evcil hayvanın yaşı, türü, cinsiyeti ve mevcut durumunu dikkate alır
- Pratik ve uygulanabilir tavsiyeler sunar

## 🔑 API Anahtarları

### OpenAI API
```dart
// lib/secrets.dart dosyasında
static const String openaiApiKey = 'sk-...';
```

### Anthropic API
```dart
// lib/secrets.dart dosyasında
static const String anthropicApiKey = 'sk-ant-api03-...';
```

## 🛠️ Geliştirme

### Yeni AI Servisi Ekleme
1. `_callNewAIService` metodu ekleyin
2. `_callAIService` metodunda yeni servisi çağırın
3. API anahtarını `secrets.dart` dosyasına ekleyin

### Prompt Optimizasyonu
1. `_buildAIPrompt` metodunu güncelleyin
2. Evcil hayvan bilgilerini genişletin
3. Yanıt formatını iyileştirin

### Fallback Sistemi
1. `_generateFallbackResponse` metodunu genişletin
2. Yeni keyword'ler ekleyin
3. Yanıt kalitesini artırın

## 📊 Performans

### AI Servis Durumu
- **Yeşil**: AI servisi aktif ve çalışıyor
- **Kırmızı**: AI servisi çalışmıyor, fallback kullanılıyor

### Yanıt Süreleri
- **OpenAI**: ~2-3 saniye
- **Claude**: ~3-4 saniye
- **Fallback**: ~0.1 saniye

## 🐛 Sorun Giderme

### AI Servisi Çalışmıyor
1. API anahtarlarını kontrol edin
2. İnternet bağlantısını kontrol edin
3. API limitlerini kontrol edin

### Yanıt Kalitesi Düşük
1. Prompt'u optimize edin
2. Evcil hayvan bilgilerini genişletin
3. Fallback sistemini iyileştirin

### Performans Sorunları
1. API çağrılarını cache'leyin
2. Prompt uzunluğunu optimize edin
3. Rate limiting ekleyin

## 🔮 Gelecek Geliştirmeler

### Planlanan Özellikler
- [ ] Daha fazla AI modeli desteği
- [ ] Görsel analizi (AI ile fotoğraf yorumlama)
- [ ] Sesli yanıt (AI yanıtını sesli okuma)
- [ ] Çok dilli destek (İngilizce, Almanca, Fransızca)
- [ ] Öğrenme sistemi (kullanıcı geri bildirimleri)

### Teknik İyileştirmeler
- [ ] Vector database entegrasyonu
- [ ] Context window genişletme
- [ ] Streaming yanıtlar
- [ ] Offline AI modelleri

## 📚 Kaynaklar

- [OpenAI API Dokümantasyonu](https://platform.openai.com/docs)
- [Anthropic API Dokümantasyonu](https://docs.anthropic.com/)
- [Flutter HTTP Paketi](https://pub.dev/packages/http)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)

## 🤝 Katkıda Bulunma

1. Bu repository'yi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.
