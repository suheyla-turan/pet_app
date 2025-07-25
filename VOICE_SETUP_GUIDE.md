# 🎤 AI Ses Tanıma Kurulum Rehberi

Bu rehber, PatiTakip uygulamasında AI ses tanıma özelliğini çalıştırmak için gerekli adımları açıklar.

## 📋 Gereksinimler

1. **OpenAI API Key** - Whisper API için gerekli
2. **İnternet Bağlantısı** - API çağrıları için
3. **Mikrofon İzni** - Ses kaydı için

## 🔑 OpenAI API Key Alma

1. [OpenAI Platform](https://platform.openai.com/) adresine gidin
2. Hesabınıza giriş yapın (veya yeni hesap oluşturun)
3. Sol menüden "API Keys" seçin
4. "Create new secret key" butonuna tıklayın
5. API key'inizi kopyalayın ve güvenli bir yerde saklayın

## ⚙️ API Key Ayarlama

1. `lib/secrets.dart` dosyasını açın
2. `openaiApiKey` değişkenini bulun
3. `'YOUR_OPENAI_API_KEY_HERE'` yerine gerçek API key'inizi yazın:

```dart
const String openaiApiKey = 'sk-your-actual-api-key-here';
```

## 🧪 Test Etme

1. Uygulamayı çalıştırın
2. Ayarlar sayfasına gidin
3. "Ses Tanıma Testi" seçeneğine tıklayın
4. Mikrofon butonuna basın ve konuşun
5. Anlık transkripsiyonu görün

## 🔧 Sorun Giderme

### Ses Tanıma Çalışmıyor

**Olası Nedenler:**
- API key ayarlanmamış
- İnternet bağlantısı yok
- Mikrofon izni verilmemiş
- API limit aşıldı

**Çözümler:**
1. API key'in doğru ayarlandığından emin olun
2. İnternet bağlantınızı kontrol edin
3. Uygulama izinlerini kontrol edin
4. Birkaç dakika bekleyip tekrar deneyin

### API Limit Hatası

OpenAI API'nin ücretsiz planında dakikada 3 istek sınırı vardır. Bu durumda:
- Birkaç dakika bekleyin
- Daha kısa ses kayıtları yapın
- Ücretli plana geçmeyi düşünün

### Mikrofon İzni

Android/iOS'ta mikrofon izni verilmediyse:
1. Cihaz ayarlarına gidin
2. Uygulama izinlerini bulun
3. Mikrofon iznini etkinleştirin

## 📱 Kullanım

### AI Chat Sayfasında
1. Mikrofon butonuna basın (sürekli dinleme)
2. Konuşun - anlık yazıya dökülür
3. Tekrar butona basarak durdurun
4. AI otomatik yanıt verir

### AI FAB ile
1. Ekrandaki AI butonuna basın
2. Sesli komut paneli açılır
3. Mikrofon butonuna basın ve konuşun
4. Komutları işler (besleme, oyun, bakım, vb.)

## 🎯 Desteklenen Komutlar

- **"Besle"** - Pet'i besler
- **"Oyna"** - Pet ile oyun oynar
- **"Bakım yap"** - Pet bakımı yapar
- **"Durum"** - Pet durumunu gösterir
- **"Aşı ekle"** - Aşı kaydı ekler

## 💡 İpuçları

1. **Net konuşun** - Daha iyi tanıma için
2. **Sessiz ortam** - Gürültü azaltır
3. **Kısa cümleler** - Daha hızlı işleme
4. **Türkçe konuşun** - Daha iyi sonuç

## 🆘 Yardım

Sorun yaşıyorsanız:
1. Debug konsolunu kontrol edin
2. API key'inizi doğrulayın
3. İnternet bağlantınızı test edin
4. Uygulamayı yeniden başlatın

---

**Not:** Bu özellik OpenAI API kullanır ve internet bağlantısı gerektirir. 