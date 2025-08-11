# 🚨 Evcil Hayvan Bildirim Sistemi

Bu dokümanda, evcil hayvan takip uygulamasındaki gelişmiş bildirim sistemi açıklanmaktadır.

## 📱 Bildirim Türleri

### 1. 🚨 Kritik Durum Bildirimleri
**Ne zaman gönderilir:** Evcil hayvan değerleri 1 veya 0 olduğunda
**Öncelik:** Yüksek (High)
**Renk:** Kırmızı
**Örnek:** "🚨 KRİTİK DURUM! Pamuk'ın tokluk değeri kritik seviyede! Acil müdahale gerekli!"

### 2. 🎉 Doğum Günü Bildirimleri
**Ne zaman gönderilir:** Evcil hayvanın doğum günü geldiğinde
**Öncelik:** Yüksek (High)
**Renk:** Altın sarısı
**Örnek:** "🎉 Doğum Günü! Pamuk'ın doğum günü bugün! Onu özel hissettirmeyi unutmayın!"

### 3. 💉 Aşı Vakti Bildirimleri
**Ne zaman gönderilir:** Aşı tarihi geldiğinde
**Öncelik:** Yüksek (High)
**Renk:** Mavi
**Örnek:** "💉 Aşı Vakti! Pamuk için Kuduz Aşısı aşısının vakti geldi! Veteriner randevusu almayı unutmayın!"

### 4. 💬 Eş Sahip Mesaj Bildirimleri
**Ne zaman gönderilir:** Eş sahiplerden mesaj geldiğinde
**Öncelik:** Normal (Default)
**Renk:** Yeşil
**Örnek:** "💬 Yeni Mesaj Ahmet'den Pamuk hakkında: Pamuk bugün çok enerjik görünüyor!"

### 5. ⚠️ Düşük Değer Bildirimleri
**Ne zaman gönderilir:** Evcil hayvan değerleri 2 olduğunda
**Öncelik:** Normal (Default)
**Renk:** Amber
**Örnek:** "⚠️ Bakım Gerekli Pamuk'ın mutluluk değeri düşük! Lütfen kontrol edin."

## 🔧 Teknik Detaylar

### Bildirim Kanal Yapılandırması
- **critical_channel:** Kritik durum bildirimleri için
- **birthday_channel:** Doğum günü bildirimleri için
- **vaccine_channel:** Aşı bildirimleri için
- **message_channel:** Mesaj bildirimleri için
- **care_channel:** Bakım bildirimleri için

### Otomatik Kontroller
- **Her dakika:** Evcil hayvan değerleri kontrol edilir
- **Kritik durum:** Değer 1 veya 0 olduğunda anında bildirim
- **Düşük değer:** Değer 2 olduğunda normal bildirim
- **Aşı kontrolü:** Her dakika aşı tarihleri kontrol edilir
- **Doğum günü:** Günlük kontrol (tekrar bildirim gönderilmez)

### Ses Desteği
- Özel bildirim sesleri desteklenir
- Android ve iOS için ayrı ses yapılandırması
- Kullanıcı tercihlerine göre ses seçimi

## 🧪 Test Etme

Bildirimleri test etmek için:
1. **Ayarlar** sayfasına gidin
2. **🧪 Bildirimleri Test Et** butonuna tıklayın
3. İstediğiniz bildirim türünü test edin

## 📋 Kullanım Senaryoları

### Senaryo 1: Kritik Durum
```
Evcil hayvan tokluk değeri 0'a düştü
↓
🚨 KRİTİK DURUM! bildirimi gönderildi
↓
Kullanıcı acil müdahale yapmalı
```

### Senaryo 2: Aşı Hatırlatması
```
Aşı tarihi geldi
↓
💉 Aşı Vakti! bildirimi gönderildi
↓
Kullanıcı veteriner randevusu almalı
```

### Senaryo 3: Eş Sahip İletişimi
```
Eş sahip mesaj gönderdi
↓
💬 Yeni Mesaj bildirimi gönderildi
↓
Kullanıcı mesajı okuyabilir
```

## 🎯 Özellikler

- ✅ **Türkçe dil desteği**
- ✅ **Otomatik bildirim kontrolü**
- ✅ **Özelleştirilebilir sesler**
- ✅ **Farklı öncelik seviyeleri**
- ✅ **Renk kodlu bildirimler**
- ✅ **Test sayfası**
- ✅ **Gerçek zamanlı kontrol**

## 🔮 Gelecek Özellikler

- [ ] Push notification desteği
- [ ] Bildirim zamanlaması
- [ ] Bildirim gruplandırma
- [ ] Bildirim geçmişi
- [ ] Bildirim istatistikleri

## 📞 Destek

Bildirim sistemi ile ilgili sorunlar için:
- **Ayarlar > Destek** sayfasını kullanın
- **FAQ** sayfasını kontrol edin
- **Geri bildirim** gönderin

---

*Bu sistem, evcil hayvanlarınızın sağlığı ve mutluluğu için tasarlanmıştır.* 🐾
