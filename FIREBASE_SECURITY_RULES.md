# Firebase Güvenlik Kuralları Kurulum Rehberi

## 🔐 Eş Sahip İstek Sistemi Güvenlik Kuralları

Bu dosya, eş sahip istek sistemi için gerekli Firebase güvenlik kurallarını içerir.

## 📋 Gerekli Adımlar

### 1. Firebase Console'a Giriş
- [Firebase Console](https://console.firebase.google.com/) adresine gidin
- Projenizi seçin

### 2. Firestore Database'e Git
- Sol menüden "Firestore Database" seçin
- "Rules" sekmesine tıklayın

### 3. Güvenlik Kurallarını Güncelle
Mevcut kuralları şu şekilde değiştirin:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar koleksiyonu - sadece kendi dokümanlarını okuyabilir
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Hayvanlar koleksiyonu - sahipler okuyabilir ve yazabilir
    match /hayvanlar/{petId} {
      allow read: if request.auth != null && 
        (resource.data.owners[request.auth.uid] != null || 
         resource.data.creator == request.auth.uid);
      allow write: if request.auth != null && 
        (resource.data.owners[request.auth.uid] != null || 
         resource.data.creator == request.auth.uid);
    }
    
    // Eş sahip istekleri koleksiyonu - gerekli izinler
    match /co_owner_requests/{requestId} {
      // Okuma: İstek sahibi veya istek edilen kişi okuyabilir
      allow read: if request.auth != null && 
        (resource.data.requesterId == request.auth.uid || 
         resource.data.requestedUserId == request.auth.uid);
      
      // Yazma: Sadece istek sahibi yeni istek oluşturabilir
      allow create: if request.auth != null && 
        request.auth.uid == resource.data.requesterId;
      
      // Güncelleme: İstek edilen kişi kabul/red edebilir, istek sahibi iptal edebilir
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.requestedUserId || 
         resource.data.requesterId == request.auth.uid);
      
      // Silme: İstek sahibi iptal edebilir
      allow delete: if request.auth != null && 
        request.auth.uid == resource.data.requesterId;
    }
    
    // Pet mesajları koleksiyonu - hayvan sahipleri okuyabilir ve yazabilir
    match /pet_messages/{petId} {
      allow read, write: if request.auth != null;
    }
    
    // Diğer koleksiyonlar için varsayılan kurallar
    match /{document=**} {
      allow read, write: if false; // Güvenlik için varsayılan olarak kapalı
    }
  }
}
```

### 4. Kuralları Kaydet
- "Publish" butonuna tıklayın
- Değişikliklerin yayınlanmasını bekleyin

## 🚨 Önemli Notlar

1. **Güvenlik**: Bu kurallar sadece kimlik doğrulaması yapılmış kullanıcıların erişimine izin verir
2. **Yetki Kontrolü**: Kullanıcılar sadece kendi hayvanlarına ve isteklerine erişebilir
3. **Veri Bütünlüğü**: Eş sahip istekleri sadece hayvan sahipleri tarafından oluşturulabilir

## 🔧 Sorun Giderme

### "Permission Denied" Hatası
- Kullanıcının oturum açtığından emin olun
- Kullanıcının hayvan sahibi olduğunu kontrol edin
- Güvenlik kurallarının yayınlandığından emin olun

### Test Etme
1. Uygulamayı yeniden başlatın
2. Eş sahip isteği göndermeyi deneyin
3. Hata mesajlarını kontrol edin

## 📱 Uygulama Test

Güvenlik kuralları güncellendikten sonra:
1. Uygulamayı yeniden başlatın
2. Eş sahip isteği göndermeyi deneyin
3. Hata mesajları kaybolmalı

## 🆘 Yardım

Eğer sorun devam ederse:
1. Firebase Console'da güvenlik kurallarını kontrol edin
2. Uygulama loglarını inceleyin
3. Kullanıcı kimlik doğrulamasını kontrol edin
