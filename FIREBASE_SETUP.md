# Firebase Kurulum ve Güvenlik Kuralları

## 🔥 Firebase Realtime Database Güvenlik Kuralları

AI Chat özelliğindeki "Bir hata oluştu" hatasını çözmek için Firebase Realtime Database güvenlik kurallarını düzenlemeniz gerekiyor.

### 📍 Firebase Console'a Gidin
1. [Firebase Console](https://console.firebase.google.com/) açın
2. `petapp-7c378` projesini seçin
3. Sol menüden "Realtime Database" seçin
4. "Rules" sekmesine tıklayın

### 🔒 Güvenlik Kurallarını Güncelleyin

Mevcut kuralları aşağıdaki kurallarla değiştirin:

```json
{
  "rules": {
    "pets": {
      "$petId": {
        ".read": "auth != null && (data.child('owners').hasChild(auth.uid) || data.child('coOwners').hasChild(auth.uid))",
        ".write": "auth != null && (data.child('owners').hasChild(auth.uid) || data.child('coOwners').hasChild(auth.uid))"
      }
    },
    "pet_chats": {
      "$petId": {
        ".read": "auth != null && root.child('pets').child($petId).child('owners').hasChild(auth.uid) || root.child('pets').child($petId).child('coOwners').hasChild(auth.uid)",
        ".write": "auth != null && root.child('pets').child($petId).child('owners').hasChild(auth.uid) || root.child('pets').child($petId).child('coOwners').hasChild(auth.uid)",
        "messages": {
          "$messageId": {
            ".read": "auth != null && root.child('pets').child($petId).child('owners').hasChild(auth.uid) || root.child('pets').child($petId).child('coOwners').hasChild(auth.uid)",
            ".write": "auth != null && root.child('pets').child($petId).child('owners').hasChild(auth.uid) || root.child('pets').child($petId).child('coOwners').hasChild(auth.uid)"
          }
        }
      }
    },
    "pet_status": {
      "$petId": {
        ".read": "auth != null && root.child('pets').child($petId).child('owners').hasChild(auth.uid) || root.child('pets').child($petId).child('coOwners').hasChild(auth.uid)",
        ".write": "auth != null && root.child('pets').child($petId).child('owners').hasChild(auth.uid) || root.child('pets').child($petId).child('coOwners').hasChild(auth.uid)"
      }
    },
    "users": {
      "$userId": {
        ".read": "auth != null && auth.uid == $userId",
        ".write": "auth != null && auth.uid == $userId"
      }
    }
  }
}
```

### 📝 Kuralların Açıklaması

- **pets**: Evcil hayvan bilgilerine sadece sahipleri ve eş sahipleri erişebilir
- **pet_chats**: Sohbet mesajlarına sadece evcil hayvanın sahipleri ve eş sahipleri erişebilir
- **pet_status**: Evcil hayvan durum bilgilerine sadece sahipleri ve eş sahipleri erişebilir
- **users**: Kullanıcılar sadece kendi bilgilerine erişebilir

### ✅ Kuralları Kaydetme

1. Kuralları yukarıdaki JSON ile değiştirin
2. "Publish" butonuna tıklayın
3. Değişikliklerin etkili olması için birkaç dakika bekleyin

### 🧪 Test Etme

1. Uygulamayı yeniden başlatın
2. AI Chat sayfasına gidin
3. "Bir hata oluştu" mesajı artık görünmemeli

## 🚨 Hala Hata Alıyorsanız

### 1. Kullanıcı Kimlik Doğrulaması
- Kullanıcının giriş yapmış olduğundan emin olun
- Firebase Auth durumunu kontrol edin

### 2. Evcil Hayvan Sahipliği
- Evcil hayvanın `owners` veya `coOwners` listesinde kullanıcının UID'si olmalı
- Firestore'daki evcil hayvan verilerini kontrol edin

### 3. Veritabanı Yapısı
- Realtime Database'de `pets`, `pet_chats`, `pet_status` klasörleri olmalı
- Her evcil hayvan için doğru yapıda veri olmalı

### 4. Log Kontrolü
- Android Studio'da logları kontrol edin
- Firebase Console'da "Usage" sekmesinde hataları görün

## 📱 Uygulama İçi Hata Yönetimi

Kod güncellemeleri ile birlikte:
- ✅ Hata mesajları Türkçe ve kullanıcı dostu
- ✅ Yeniden deneme seçenekleri
- ✅ Yardım dialog'u
- ✅ Güvenlik kontrolleri
- ✅ Hata logları

## 🔧 Ek Gereksinimler

- `firebase_auth` paketi yüklü olmalı
- Kullanıcı giriş yapmış olmalı
- Evcil hayvan verileri doğru yapıda olmalı
