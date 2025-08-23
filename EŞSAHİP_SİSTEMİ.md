# Eş Sahip İstek Sistemi

Bu dokümantasyon, PatiTakip uygulamasındaki yeni eş sahip istek sistemini açıklamaktadır.

## 🎯 Sistem Amacı

Eş sahip ekleme sistemini daha güvenli ve kullanıcı dostu hale getirmek. Artık eş sahip olarak eklemek istenen kişiye istek gönderilir ve kişi isteği kabul ettiğinde eş sahip olur.

## 🔄 Sistem Akışı

### 1. İstek Gönderme
- Hayvan sahibi, eş sahip olarak eklemek istediği kişinin email adresini girer
- Sistem otomatik olarak istek gönderir
- İstek `co_owner_requests` koleksiyonuna kaydedilir

### 2. İstek Bildirimi
- İstek alan kişiye bildirim gönderilir
- Bildirim: "🤝 Eş Sahip İsteği - [İsteyen Kişi], [Hayvan Adı]'a eş sahip olmak istiyor"

### 3. İstek Yönetimi
- **Kabul Etme**: İstek kabul edildiğinde kişi otomatik olarak eş sahip olur
- **Reddetme**: İstek reddedildiğinde işlem iptal olur
- **İptal Etme**: İsteği gönderen kişi isteği iptal edebilir

### 4. Sonuç Bildirimleri
- **Kabul**: "✅ İstek Kabul Edildi - [Kabul Eden], [Hayvan Adı]'a eş sahip olma isteğinizi kabul etti"
- **Red**: "❌ İstek Reddedildi - [Reddeden], [Hayvan Adı]'a eş sahip olma isteğinizi reddetti"

## 📱 Kullanıcı Arayüzü

### Ana Menü
- Ana sayfada "Eş Sahip İstekleri" butonu eklendi
- Yeşil renkli person_add ikonu ile gösteriliyor

### Eş Sahip Yönetimi Sayfası
- "Eş Sahip İsteği Gönder" butonu
- "İstekleri Görüntüle" butonu
- Açıklayıcı metin: "Eş sahip olarak eklemek istediğiniz kişiye istek gönderin. Kişi isteği kabul ettiğinde eş sahip olacaktır."

### Eş Sahip İstekleri Sayfası
- **Tab 1: Gelen İstekler**
  - Bekleyen istekler listesi
  - Kabul Et / Reddet butonları
  - İstek detayları (hayvan adı, isteyen kişi, email)

- **Tab 2: Gönderilen İstekler**
  - Gönderilen isteklerin durumu
  - Bekliyor / Kabul Edildi / Reddedildi
  - Bekleyen istekler için "İsteği İptal Et" butonu

## 🗄️ Firestore Yapısı

### Koleksiyon: `co_owner_requests`
```json
{
  "petId": "string",
  "petName": "string",
  "requesterId": "string",
  "requesterName": "string",
  "requesterEmail": "string",
  "requestedUserId": "string",
  "requestedUserEmail": "string",
  "status": "pending|accepted|rejected",
  "timestamp": "timestamp",
  "message": "string",
  "acceptedAt": "timestamp?",
  "rejectedAt": "timestamp?"
}
```

### Durum Değerleri
- `pending`: İstek bekliyor
- `accepted`: İstek kabul edildi
- `rejected`: İstek reddedildi

## 🔧 Teknik Detaylar

### Yeni Servis Metodları
- `sendCoOwnerRequest()`: İstek gönderme
- `getPendingCoOwnerRequests()`: Bekleyen istekleri getirme
- `getSentCoOwnerRequests()`: Gönderilen istekleri getirme
- `acceptCoOwnerRequest()`: İsteği kabul etme
- `rejectCoOwnerRequest()`: İsteği reddetme
- `cancelCoOwnerRequest()`: İsteği iptal etme

### Yeni Bildirim Türleri
- `showCoOwnerRequestNotification()`: İstek geldiğinde
- `showCoOwnerRequestAcceptedNotification()`: İstek kabul edildiğinde
- `showCoOwnerRequestRejectedNotification()`: İstek reddedildiğinde

### Güvenlik Kontrolleri
- Sadece hayvan sahipleri istek gönderebilir
- Kendine istek gönderilemez
- Zaten eş sahip olan kişiye istek gönderilemez
- Aynı kişiye tekrar istek gönderilemez

## 🚀 Kullanım Senaryoları

### Senaryo 1: Yeni Eş Sahip Ekleme
1. Hayvan sahibi "Eş Sahip Yönetimi" sayfasına gider
2. Email adresini girer ve "İstek Gönder" butonuna tıklar
3. Sistem isteği gönderir ve onay mesajı gösterir
4. İstek alan kişiye bildirim gider

### Senaryo 2: İstek Kabul Etme
1. Kullanıcı ana menüdeki "Eş Sahip İstekleri" butonuna tıklar
2. "Gelen İstekler" tabında bekleyen isteği görür
3. "Kabul Et" butonuna tıklar
4. Sistem otomatik olarak eş sahip yapar
5. İsteği gönderen kişiye bildirim gider

### Senaryo 3: İstek Reddetme
1. Kullanıcı gelen isteği görür
2. "Reddet" butonuna tıklar
3. Onay dialogu çıkar
4. İstek reddedilir ve isteği gönderen kişiye bildirim gider

## 🔄 Geriye Dönük Uyumluluk

- Eski `addCoOwner()` metodu `addCoOwnerDirect()` olarak yeniden adlandırıldı
- Mevcut eş sahip yönetimi fonksiyonları korundu
- Eski veriler etkilenmez

## 🧪 Test

### Bildirim Testi
- `NotificationTestPage` sayfasında tüm bildirim türleri test edilebilir
- Eş sahip istek bildirimleri için özel test butonları eklendi

### Sistem Testi
1. İki farklı kullanıcı ile giriş yapın
2. Bir kullanıcıdan eş sahip isteği gönderin
3. Diğer kullanıcıdan isteği kabul/red edin
4. Bildirimleri kontrol edin

## 📝 Notlar

- Sistem tamamen güvenli ve yetki kontrollü
- Tüm işlemler Firestore'da loglanır
- Kullanıcı dostu arayüz ve açıklayıcı mesajlar
- Otomatik bildirim sistemi
- Gerçek zamanlı güncelleme

## 🐛 Bilinen Sorunlar

- Şu anda yok

## 🔮 Gelecek Özellikler

- İstek mesajı özelleştirme
- Toplu istek gönderme
- İstek geçmişi ve istatistikler
- Email bildirimleri
