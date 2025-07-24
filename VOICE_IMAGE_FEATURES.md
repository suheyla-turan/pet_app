# Ses ve Görsel Mesaj Özellikleri

Bu güncelleme ile PatiTakip uygulamasının günlük sohbet kısmına ses ve görsel mesaj gönderme özellikleri eklendi.

## Yeni Özellikler

### 🎤 Ses Mesajları
- **Ses Kayıt**: Mikrofon butonuna basarak ses kaydı başlatabilirsiniz
- **Kayıt Süresi**: Kayıt sırasında süre göstergesi görünür
- **Ses Oynatma**: Gönderilen ses mesajlarını oynatabilirsiniz
- **Süre Gösterimi**: Ses mesajlarının süresi görüntülenir

### 📷 Görsel Mesajlar
- **Galeri Seçimi**: Galeriden resim seçebilirsiniz
- **Kamera Çekimi**: Kamera ile yeni fotoğraf çekebilirsiniz
- **Resim Önizleme**: Resimleri büyük görüntüleyebilirsiniz
- **Açıklama Ekleme**: Resimlere açıklama ekleyebilirsiniz

## Kullanım

### Ses Mesajı Gönderme
1. Sohbet ekranında mikrofon butonuna basın
2. Konuşmaya başlayın
3. Durdur butonuna basarak kaydı tamamlayın
4. Ses mesajı otomatik olarak gönderilir

### Görsel Mesaj Gönderme
1. Sohbet ekranında resim butonuna basın
2. "Galeriden Seç" veya "Fotoğraf Çek" seçeneklerinden birini seçin
3. Resmi seçin veya çekin
4. Resim otomatik olarak gönderilir

## Teknik Detaylar

### Eklenen Dosyalar
- `lib/services/media_service.dart` - Medya işlemleri için servis
- `lib/features/pet/widgets/chat_message_widget.dart` - Mesaj görüntüleme widget'ı

### Güncellenen Dosyalar
- `lib/features/pet/models/ai_chat_message.dart` - Mesaj modeli genişletildi
- `lib/features/pet/screens/ai_chat_page.dart` - Sohbet sayfası güncellendi
- `lib/providers/ai_provider.dart` - AI provider'a yeni metodlar eklendi
- `lib/main.dart` - Media service başlatma eklendi

### Mesaj Tipleri
- `MessageType.text` - Metin mesajları
- `MessageType.voice` - Ses mesajları
- `MessageType.image` - Görsel mesajlar

### İzinler
- Mikrofon izni (ses kaydı için)
- Kamera izni (fotoğraf çekimi için)
- Galeri izni (resim seçimi için)

## Bağımlılıklar
- `image_picker: ^1.0.7` - Resim seçimi ve kamera
- `flutter_sound: ^9.28.0` - Ses kayıt ve oynatma
- `permission_handler: ^12.0.1` - İzin yönetimi
- `path_provider: ^2.1.2` - Dosya yolu yönetimi

## Notlar
- Ses dosyaları AAC formatında kaydedilir
- Resimler 1024x1024 maksimum boyutunda sıkıştırılır
- Tüm medya dosyaları geçici dizinde saklanır
- AI yanıtları metin formatında kalır 