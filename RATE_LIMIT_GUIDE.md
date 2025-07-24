# API Rate Limit Rehberi

## Sorun Nedir?

OpenAI Whisper API'si dakikada maksimum 3 istek kabul eder. Bu limit aşıldığında 429 hatası alırsınız.

## Çözümler

### 1. Otomatik Retry Sistemi
Uygulama artık rate limit hatalarını otomatik olarak yönetir:
- 429 hatası alındığında otomatik olarak tekrar dener
- Exponential backoff ile bekleme süreleri: 5s, 10s, 20s
- Maksimum 3 deneme yapar

### 2. Manuel Çözümler

#### A) Bekleme
- Rate limit hatası aldığınızda 20-30 saniye bekleyin
- Ardından tekrar deneyin

#### B) API Anahtarı Güncelleme
- OpenAI hesabınıza giriş yapın
- Yeni bir API anahtarı oluşturun
- `lib/secrets.dart` dosyasını güncelleyin

#### C) Ödeme Yöntemi Ekleme
- OpenAI hesabınıza ödeme yöntemi ekleyin
- Bu, rate limit'inizi artıracaktır

### 3. Kullanım İpuçları

#### Sesli Komut Kullanımı
- Kısa ve net konuşun
- Gürültülü ortamlardan kaçının
- Her komut arasında 20 saniye bekleyin

#### Alternatif Yöntemler
- Metin tabanlı sohbet kullanın
- Sesli komut yerine butonlara dokunun

## Teknik Detaylar

### Rate Limit Ayarları
```dart
static const int _minRequestInterval = 21; // 20s + 1s buffer
static const int _maxRetries = 3;
```

### Bekleme Süreleri
- İlk deneme: 5 saniye
- İkinci deneme: 10 saniye  
- Üçüncü deneme: 20 saniye

## Hata Mesajları

| Hata | Açıklama | Çözüm |
|------|----------|-------|
| 429 | Rate limit aşıldı | Bekleyin veya retry sistemini kullanın |
| 401 | API anahtarı geçersiz | API anahtarınızı kontrol edin |
| 400 | Geçersiz istek | Ses dosyasını kontrol edin |

## Destek

Sorun devam ederse:
1. Uygulamayı yeniden başlatın
2. İnternet bağlantınızı kontrol edin
3. API anahtarınızın geçerli olduğundan emin olun 