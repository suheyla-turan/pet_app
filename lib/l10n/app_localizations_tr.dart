// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'PatiTakip';

  @override
  String get settings => 'Ayarlar';

  @override
  String get profile => 'Profilim';

  @override
  String get about => 'Hakkında';

  @override
  String get support => 'Destek / Geri Bildirim';

  @override
  String get infoSupport => 'Bilgi & Destek';

  @override
  String get theme => 'Tema';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get done => 'Tamam';

  @override
  String get language => 'Dil';

  @override
  String get appLanguage => 'Uygulama Dili';

  @override
  String get enableNotifications => 'Bildirimleri Etkinleştir';

  @override
  String get advancedNotifications => 'Gelişmiş Bildirimler';

  @override
  String get scheduledNotifications => 'Zamanlı Bildirimler';

  @override
  String get updateInterval => 'Güncelleme Aralığı';

  @override
  String get updateIntervalDescription => 'Hayvan durumlarının güncellenme sıklığını seçin';

  @override
  String get ok => 'Tamam';

  @override
  String get askHint => 'Sorunuzu yazın...';

  @override
  String get cancel => 'İptal';

  @override
  String get ask => 'Sor';

  @override
  String get addUser => 'Kullanıcı Ekle';

  @override
  String get userEmailHint => 'Kullanıcı e-posta adresi';

  @override
  String get add => 'Ekle';

  @override
  String get petIdNotFound => 'Pet ID bulunamadı!';

  @override
  String get userAdded => 'Kullanıcı eklendi!';

  @override
  String get userNotFound => 'Kullanıcı bulunamadı!';

  @override
  String get mainUserCannotRemoveSelf => 'Ana kullanıcı kendini çıkaramaz!';

  @override
  String get onlyMainUserCanRemove => 'Sadece ana kullanıcı başkasını çıkarabilir!';

  @override
  String get settingsDescription => 'Uygulama tercihlerinizi yönetin';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Karanlık';

  @override
  String get themeSystem => 'Sistem Varsayılanı';

  @override
  String get themeLightDesc => 'Açık tema';

  @override
  String get themeDarkDesc => 'Karanlık tema';

  @override
  String get themeSystemDesc => 'Cihazın tema ayarını kullan';

  

  @override
  String get voiceSettings => 'Sesli Konuşma';

  @override
  String get voiceSettingsDesc => 'AI ile sesli konuşma özelliklerini yönetin';

  @override
  String get voiceAuto => 'Otomatik Sesli Yanıt';

  @override
  String get voiceAutoDesc => 'AI cevaplarını otomatik olarak sesli oku';

  @override
  String get voiceListenFeature => 'Sesli Dinleme Özelliği';

  @override
  String get voiceListenFeatureDesc => 'Her AI yanıtının altında \'Sesli Dinle\' butonu bulunur. Bu buton ile istediğiniz zaman cevabı sesli dinleyebilirsiniz. Otomatik sesli yanıt kapalı olsa bile manuel olarak dinleyebilirsiniz.';

  @override
  String get voiceTTS => 'Sesli Yanıt (TTS)';

  @override
  String get voiceSpeaker => 'Konuşmacı (Ses)';

  @override
  String get voiceRate => 'Konuşma Hızı';

  @override
  String get voicePitch => 'Ses Perdesi';

  @override
  String get notificationsSound => 'Bildirim Sesi';

  @override
  String get notificationsDefault => 'Varsayılan Ses';

  @override
  String get notificationsCustom => 'Özel Bildirim Sesi';

  @override
  String get notificationsBell => 'Zil Sesi';

  @override
  String get notificationsChime => 'Çan Sesi';

  @override
  String get notificationsAlert => 'Uyarı Sesi';

  @override
  String get scheduledNotificationsDesc => 'Günlük hatırlatıcı bildirimleri';

  @override
  String get update => 'Güncelleme';

  @override
  String get autoUpdate => 'Otomatik Güncelleme';

  @override
  String get autoUpdateDesc => 'Hayvan durumlarını otomatik güncelle';

  @override
  String get petTypeDog => 'Köpek';

  @override
  String get petTypeCat => 'Kedi';

  @override
  String get petTypeBird => 'Kuş';

  @override
  String get petTypeFish => 'Balık';

  @override
  String get petTypeHamster => 'Hamster';

  @override
  String get petTypeRabbit => 'Tavşan';

  @override
  String get petTypeOther => 'Diğer';

  @override
  String get genderMale => 'Erkek';

  @override
  String get genderFemale => 'Dişi';

  @override
  String get statusInfo => 'Durum Bilgileri';

  @override
  String get satiety => 'Tokluk';

  @override
  String get happiness => 'Mutluluk';

  @override
  String get energy => 'Enerji';

  @override
  String get maintenance => 'Bakım';

  @override
  String get excellent => 'Mükemmel!';

  @override
  String get quickActions => 'Hızlı İşlemler';

  @override
  String get feed => 'Besle';

  @override
  String get pet => 'Sev';

  @override
  String get rest => 'Dinlendir';

  @override
  String get care => 'Bakım';

  @override
  String get breed => 'Cins';

  @override
  String get age => 'Yaş';

  @override
  String yearsOld(Object age) {
    return '$age yaşında';
  }

  @override
  String birthDate(Object day, Object month, Object year) {
    return 'Doğum Tarihi: $day/$month/$year';
  }

  @override
  String get type => 'Tür';

  @override
  String get gender => 'Cinsiyet';

  @override
  String get settingsSection => 'Ayarlar';

  @override
  String get infoSupportSection => 'Bilgi & Destek';

  @override
  String get critical => 'Kritik';

  @override
  String get good => 'İyi';

  @override
  String get medium => 'Orta';

  @override
  String get low => 'Düşük';

  @override
  String get aboutDescription => 'Bu uygulama, evcil hayvanlarınızın bakımını kolaylaştırmak, aşı takibini yapmak, günlük notlar almak ve yapay zeka ile sohbet edebilmek için geliştirilmiştir.';

  @override
  String get ttsTurkishNotFound => 'Türkçe TTS dili bulunamadı, İngilizce kullanılıyor';

  @override
  String get ttsServiceFailed => 'Sesli konuşma servisi başlatılamadı';

  @override
  String get speechNotEnabled => 'Konuşma tanıma etkin değil';

  @override
  String get onboardingWelcome => 'PatiTakip\'e Hoş Geldin!';

  @override
  String get onboardingDescription => 'Evcil hayvanlarını, aşılarını ve daha fazlasını takip et.';

  @override
  String get next => 'İleri';

  @override
  String get addPet => 'Evcil Hayvan Ekle';

  @override
  String get addPetDescription => 'Takip için evcil hayvanını ekle.';

  @override
  String get vaccinationAndCare => 'Aşı & Bakım';

  @override
  String get vaccinationAndCareDescription => 'Sağlıklı kalmak için hatırlatıcılar al.';

  @override
  String get profileAndHistory => 'Profil & Geçmiş';

  @override
  String get profileAndHistoryDescription => 'Profilini ve hayvan geçmişini görüntüle.';

  @override
  String get start => 'Başla';

  @override
  String get login => 'Giriş Yap';

  @override
  String get email => 'E-posta';

  @override
  String get validEmail => 'Geçerli bir e-posta adresi girin.';

  @override
  String get password => 'Şifre';

  @override
  String get min6Chars => 'En az 6 karakter.';

  @override
  String get forgotPassword => 'Şifremi Unuttum?';

  @override
  String get noAccountRegister => 'Hesabın yok mu? Kayıt ol';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get name => 'İsim';

  @override
  String get enterName => 'Lütfen isminizi girin.';

  @override
  String get alreadyAccountLogin => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get resetPassword => 'Şifre Sıfırla';

  @override
  String get resetMailSent => 'Sıfırlama e-postası gönderildi!';

  @override
  String get resetPasswordButton => 'Sıfırlama E-postası Gönder';

  @override
  String get editPet => 'Evcil Hayvanı Düzenle';

  @override
  String get enterPetInfo => 'Evcil hayvan bilgilerini girin.';

  @override
  String get basicInfo => 'Temel Bilgiler';

  @override
  String get petType => 'Hayvan Türü';

  @override
  String get selectPetType => 'Hayvan türü seç';

  @override
  String get enterBreed => 'Lütfen cins girin.';

  @override
  String get female => 'Dişi';

  @override
  String get male => 'Erkek';

  @override
  String get selectGender => 'Cinsiyet seç';

  @override
  String get selectBirthDate => 'Doğum tarihi seç';

  @override
  String get intervalSettings => 'Aralık Ayarları';

  @override
  String get satietyInterval => 'Tokluk Aralığı';

  @override
  String get happinessInterval => 'Mutluluk Aralığı';

  @override
  String get energyInterval => 'Enerji Aralığı';

  @override
  String get careInterval => 'Bakım Aralığı';

  @override
  String get save => 'Kaydet';

  @override
  String get feedingTimeLabel => 'Beslenme Zamanı:';

  @override
  String get notSet => 'Ayarlanmadı';

  @override
  String get birthDateLabel => 'Doğum Tarihi';

  @override
  String get petCareNotifications => 'Evcil hayvan bakım bildirimleri';

  @override
  String get soundEffects => 'Ses Efektleri';

  @override
  String get playInteractionSounds => 'Etkileşim seslerini çal';

  @override
  String get photo => 'Fotoğraf';

  @override
  String get addPhoto => 'Fotoğraf Ekle';

  @override
  String get myPets => 'Evcil Hayvanlarım';

  @override
  String get manageYourPets => 'Evcil hayvanlarını yönet';

  @override
  String get petsLoading => 'Hayvanlar yükleniyor...';

  @override
  String get noPetsAdded => 'Henüz hayvan eklenmedi!';

  @override
  String get addPetHint => 'İlk hayvanını eklemek için + butonuna tıkla.';

  @override
  String get hunger => 'Açlık';

  @override
  String get feedingTimeSaved => 'Beslenme zamanı kaydedildi!';

  @override
  String get vaccinesToBeTaken => 'Yapılacak Aşılar';

  @override
  String get vaccinesTaken => 'Yapılan Aşılar';

  @override
  String get askQuestionChat => 'Sohbette soru sor';

  @override
  String get owners => 'Sahipler';

  @override
  String get diaryChat => 'Günlük Sohbet';

  @override
  String get errorOccurred => 'Bir hata oluştu.';

  @override
  String get noMessages => 'Henüz mesaj yok.';

  @override
  String get writeMessage => 'Mesaj yaz...';

  @override
  String get chatHistory => 'Sohbet Geçmişi';

  @override
  String get aiChat => 'AI Sohbet';

  @override
  String get newChat => 'Yeni Sohbet';

  @override
  String get speakQuestion => 'Sorunu sesli sor';

  @override
  String get chatHint => 'Mesajını yaz...';

  @override
  String get feedbackThanks => 'Geri bildiriminiz için teşekkürler!';

  @override
  String get feedbackDescription => 'Düşüncelerinizi veya sorunlarınızı bize iletin.';

  @override
  String get yourMessage => 'Mesajınız';

  @override
  String get enterMessage => 'Lütfen bir mesaj girin.';

  @override
  String get send => 'Gönder';

  @override
  String get doneVaccineAdd => 'Yapıldı Olarak İşaretle';

  @override
  String get vaccineAdd => 'Aşı Ekle';

  @override
  String get vaccineName => 'Aşı Adı';

  @override
  String get selectDate => 'Tarih Seç';

  @override
  String get doneVaccines => 'Tamamlanan Aşılar';

  @override
  String get vaccines => 'Aşılar';

  @override
  String noVaccines(Object showDone) {
    return 'Aşı bulunamadı.';
  }

  @override
  String date(Object date) {
    return 'Tarih: $date';
  }

  @override
  String deletePetError(Object error) {
    return 'Hayvan silinemedi: $error';
  }

  @override
  String get deleteNote => 'Notu Sil';

  @override
  String get deleteNoteConfirm => 'Bu notu silmek istediğinize emin misiniz?';

  @override
  String get noteDeleted => 'Not başarıyla silindi!';

  @override
  String noteDeleteError(Object error) {
    return 'Not silinirken hata oluştu: $error';
  }

  @override
  String error(Object error) {
    return 'Hata: $error';
  }

  @override
  String deleteProfileError(Object error) {
    return 'Profil silinemedi: $error';
  }

  @override
  String get aboutApp => 'Uygulama Hakkında';

  @override
  String get version => 'Sürüm';

  @override
  String get developer => 'Geliştirici';

  @override
  String get copyright => '© 2024 PatiTakip';

  @override
  String get nameLabel => 'İsim';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get deleteProfile => 'Profili Sil';

  @override
  String get deleteProfileConfirm => 'Profilinizi silmek istediğinize emin misiniz?';

  @override
  String get delete => 'Sil';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get nameMinLengthError => 'İsim en az 2 karakter olmalı.';

  @override
  String get minutes => 'dakika';

  @override
  String get vaccineTime => 'Aşı Zamanı';

  @override
  String get statusInfoTitle => 'Durum Bilgileri';

  @override
  String get details => 'Detaylar';

  @override
  String get dog => 'Köpek';

  @override
  String get cat => 'Kedi';

  @override
  String get bird => 'Kuş';

  @override
  String get fish => 'Balık';

  @override
  String get hamster => 'Hamster';

  @override
  String get rabbit => 'Tavşan';

  @override
  String get other => 'Diğer';

  @override
  String get selectFromGallery => 'Galeriden Seç';

  @override
  String get takePhoto => 'Fotoğraf Çek';

  @override
  String get useRecognizedText => 'Bu Metni Kullan';

  @override
  String get faq => 'Sık Sorulan Sorular';

  @override
  String get faqTitle => 'Sık Sorulan Sorular';

  @override
  String get faqDescription => 'Uygulama hakkında sık sorulan sorular ve cevapları';

  @override
  String get faqGeneral => 'Genel Sorular';

  @override
  String get faqFeatures => 'Özellikler';

  @override
  String get faqTechnical => 'Teknik Sorular';

  @override
  String get faqSupport => 'Destek';

  @override
  String get faqWhatIsPatiTakip => 'PatiTakip nedir?';

  @override
  String get faqWhatIsPatiTakipAnswer => 'PatiTakip, evcil hayvanlarınızın bakımını kolaylaştırmak için geliştirilmiş kapsamlı bir mobil uygulamadır. Aşı takibi, günlük notlar, yapay zeka destekli sohbet ve sesli komut özellikleri sunar.';

  @override
  String get faqHowToAddPet => 'Evcil hayvan nasıl eklenir?';

  @override
  String get faqHowToAddPetAnswer => 'Ana sayfada + butonuna tıklayarak yeni evcil hayvan ekleyebilirsiniz. Hayvan türü, cins, cinsiyet ve doğum tarihi gibi temel bilgileri girmeniz gerekiyor.';

  @override
  String get faqHowToTrackVaccines => 'Aşı takibi nasıl yapılır?';

  @override
  String get faqHowToTrackVaccinesAnswer => 'Evcil hayvan detay sayfasında \'Aşılar\' sekmesine giderek yeni aşı ekleyebilir veya mevcut aşıları görüntüleyebilirsiniz. Tamamlanan aşıları işaretleyebilirsiniz.';

  @override
  String get faqHowToUseAI => 'AI sohbet özelliği nasıl kullanılır?';

  @override
  String get faqHowToUseAIAnswer => 'Ana sayfada sağ alt köşedeki AI butonuna tıklayarak yapay zeka ile sohbet edebilirsiniz. Hem yazılı hem de sesli soru sorabilirsiniz.';

  @override
  String get faqVoiceCommands => 'Sesli komutlar nasıl çalışır?';

  @override
  String get faqVoiceCommandsAnswer => 'AI sohbet sayfasında mikrofon butonuna basarak sesli soru sorabilirsiniz. Uygulama sesinizi metne çevirir ve AI yanıt verir.';

  @override
  String get faqNotifications => 'Bildirimler nasıl ayarlanır?';

  @override
  String get faqNotificationsAnswer => 'Ayarlar > Bildirimler bölümünden bildirim tercihlerinizi yönetebilirsiniz. Evcil hayvan bakım hatırlatıcıları ve aşı zamanları için bildirim alabilirsiniz.';

  @override
  String get faqDataBackup => 'Verilerim güvenli mi?';

  @override
  String get faqDataBackupAnswer => 'Evet, tüm verileriniz Firebase güvenli bulut sunucularında saklanır. Hesabınıza giriş yaptığınızda verileriniz her zaman erişilebilir.';

  @override
  String get faqMultiplePets => 'Birden fazla evcil hayvan ekleyebilir miyim?';

  @override
  String get faqMultiplePetsAnswer => 'Evet, istediğiniz kadar evcil hayvan ekleyebilirsiniz. Her hayvan için ayrı profil ve takip sistemi bulunur.';

  @override
  String get faqShareAccount => 'Hesabımı başkalarıyla paylaşabilir miyim?';

  @override
  String get faqShareAccountAnswer => 'Evet, evcil hayvan detay sayfasında \'Sahipler\' bölümünden diğer kullanıcıları ekleyebilirsiniz. Bu sayede aile üyeleri de hayvan bakımına katılabilir.';

  @override
  String get faqAppUpdates => 'Uygulama güncellemeleri nasıl çalışır?';

  @override
  String get faqAppUpdatesAnswer => 'Ayarlar > Güncelleme bölümünden otomatik güncelleme ayarlarını yapabilirsiniz. Yeni özellikler ve iyileştirmeler düzenli olarak eklenir.';

  @override
  String get faqContactSupport => 'Destek ekibiyle nasıl iletişime geçebilirim?';

  @override
  String get faqContactSupportAnswer => 'Bu sayfada \'Geri Bildirim Gönder\' bölümünü kullanarak veya doğrudan e-posta göndererek destek ekibimizle iletişime geçebilirsiniz.';

  @override
  String get faqPrivacyPolicy => 'Gizlilik politikası nedir?';

  @override
  String get faqPrivacyPolicyAnswer => 'Kişisel verileriniz güvenle korunur ve üçüncü taraflarla paylaşılmaz. Detaylı gizlilik politikamızı uygulama içinde bulabilirsiniz.';

  @override
  String get faqTermsOfService => 'Kullanım şartları nelerdir?';

  @override
  String get faqTermsOfServiceAnswer => 'Uygulamayı kullanarak kullanım şartlarımızı kabul etmiş olursunuz. Tam metni uygulama içinde bulabilirsiniz.';

  @override
  String get aboutAppVersion => 'Uygulama Sürümü';

  @override
  String get aboutAppVersionValue => '1.0.0';

  @override
  String get aboutDeveloper => 'Geliştirici';

  @override
  String get aboutDeveloperValue => 'PatiTakip Ekibi';

  @override
  String get aboutContact => 'İletişim';

  @override
  String get aboutContactValue => 'info@patitakip.com';

  @override
  String get aboutWebsite => 'Web Sitesi';

  @override
  String get aboutWebsiteValue => 'www.patitakip.com';

  @override
  String get aboutFeatures => 'Özellikler';

  @override
  String get aboutFeaturesList => '• Evcil hayvan profili yönetimi\n• Aşı takip sistemi\n• Yapay zeka destekli sohbet\n• Sesli komut özelliği\n• Bildirim sistemi\n• Çoklu kullanıcı desteği\n• Bulut yedekleme';

  @override
  String get aboutTechnology => 'Teknolojiler';

  @override
  String get aboutTechnologyList => '• Flutter & Dart\n• Firebase\n• OpenAI API\n• Speech Recognition\n• Text-to-Speech';

  @override
  String get aboutPrivacy => 'Gizlilik';

  @override
  String get aboutPrivacyText => 'Verileriniz güvenle saklanır ve üçüncü taraflarla paylaşılmaz. Detaylı gizlilik politikamızı web sitemizde bulabilirsiniz.';

  @override
  String get aboutSupport => 'Destek';

  @override
  String get aboutSupportText => 'Sorularınız için destek ekibimizle iletişime geçebilirsiniz. Geri bildirimleriniz bizim için değerlidir.';

  @override
  String get aboutRateApp => 'Uygulamayı Değerlendir';

  @override
  String get aboutRateAppText => 'Deneyiminizi değerlendirin ve geliştirmemize yardımcı olun.';

  @override
  String get aboutShareApp => 'Uygulamayı Paylaş';

  @override
  String get aboutShareAppText => 'Arkadaşlarınızla PatiTakip\'i paylaşın.';

  @override
  String get aboutFollowUs => 'Bizi Takip Edin';

  @override
  String get aboutFollowUsText => 'Güncellemeler ve haberler için sosyal medyada bizi takip edin.';
}
