import 'package:flutter/foundation.dart';
import '../services/openai_service.dart';
import '../services/voice_service.dart';
import '../providers/settings_provider.dart';
import '../providers/pet_provider.dart';
import '../features/pet/models/pet.dart';
import '../features/pet/models/ai_chat_message.dart';
import '../services/realtime_service.dart';

class AIProvider with ChangeNotifier {
  // --- YENİ: Çoklu mesajlı AI sohbeti için ---
  String? _activeChatId;
  List<AIChatMessage> _activeMessages = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isContinuousListening = false; // Yeni: sürekli dinleme durumu
  String? _recognizedText;
  String _currentTranscription = ''; // Yeni: anlık transkripsiyon
  String _statusMessage = ''; // Yeni: durum mesajı
  SettingsProvider? _settingsProvider;
  PetProvider? _petProvider;
  final VoiceService _voiceService = VoiceService();
  final RealtimeService _realtimeService = RealtimeService();

  String? get activeChatId => _activeChatId;
  List<AIChatMessage> get activeMessages => _activeMessages;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isContinuousListening => _isContinuousListening; // Yeni
  String? get recognizedText => _recognizedText;
  String get currentTranscription => _currentTranscription; // Yeni
  String get statusMessage => _statusMessage; // Yeni

  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
  }

  void setPetProvider(PetProvider petProvider) {
    _petProvider = petProvider;
  }

  // Yeni bir AI sohbeti başlat
  Future<void> startNewChat(String petId) async {
    _isLoading = true;
    notifyListeners();
    _activeChatId = await _realtimeService.startNewAIChat(petId);
    _activeMessages = [];
    _isLoading = false;
    notifyListeners();
  }

  // Var olan bir sohbeti yükle (geçmişi göster)
  void listenToChat(String petId, String chatId) {
    _activeChatId = chatId;
    _realtimeService.getAIChatMessagesStream(petId, chatId).listen((messages) {
      _activeMessages = messages;
      notifyListeners();
    });
  }

  // Kullanıcı mesajı gönder ve AI'dan yanıt al
  Future<void> sendMessageAndGetAIResponse({
    required String petId,
    required Pet pet,
    required String message,
  }) async {
    if (_activeChatId == null) {
      await startNewChat(petId);
    }
    final chatId = _activeChatId!;
    final userMsg = AIChatMessage.text(
      sender: 'user', 
      text: message, 
      timestamp: DateTime.now().millisecondsSinceEpoch
    );
    await _realtimeService.addAIChatMessage(petId, chatId, userMsg);
    _isLoading = true;
    notifyListeners();
    try {
      // Sohbet geçmişini OpenAI'ya gönder
      final conversationStyle = _settingsProvider?.conversationStyle ?? ConversationStyle.friendly;
      final history = List<AIChatMessage>.from(_activeMessages)..add(userMsg);
      final responseText = await OpenAIService.getMultiTurnSuggestion(
        pet: pet,
        history: history,
        style: conversationStyle,
      );
      final aiMsg = AIChatMessage.text(
        sender: 'ai', 
        text: responseText, 
        timestamp: DateTime.now().millisecondsSinceEpoch
      );
      await _realtimeService.addAIChatMessage(petId, chatId, aiMsg);
      // Sesli yanıt
      if (_settingsProvider?.voiceResponseEnabled ?? false) {
        await _voiceService.speak(
          responseText,
          voice: _settingsProvider?.ttsVoice,
          rate: _settingsProvider?.ttsRate,
          pitch: _settingsProvider?.ttsPitch,
        );
      }
    } catch (e) {
      final aiMsg = AIChatMessage.text(
        sender: 'ai', 
        text: 'Hata: $e', 
        timestamp: DateTime.now().millisecondsSinceEpoch
      );
      await _realtimeService.addAIChatMessage(petId, chatId, aiMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ses mesajı gönder
  Future<void> sendVoiceMessage({
    required String petId,
    required Pet pet,
    required String voicePath,
    required int duration,
  }) async {
    if (_activeChatId == null) {
      await startNewChat(petId);
    }
    final chatId = _activeChatId!;
    final userMsg = AIChatMessage.voice(
      sender: 'user',
      text: 'Ses mesajı',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      mediaUrl: voicePath,
      voiceDuration: duration,
    );
    await _realtimeService.addAIChatMessage(petId, chatId, userMsg);
    _isLoading = true;
    notifyListeners();
    try {
      // Ses mesajı için AI yanıtı
      final conversationStyle = _settingsProvider?.conversationStyle ?? ConversationStyle.friendly;
      final history = List<AIChatMessage>.from(_activeMessages)..add(userMsg);
      final responseText = await OpenAIService.getMultiTurnSuggestion(
        pet: pet,
        history: history,
        style: conversationStyle,
      );
      final aiMsg = AIChatMessage.text(
        sender: 'ai',
        text: responseText,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await _realtimeService.addAIChatMessage(petId, chatId, aiMsg);
      // Sesli yanıt
      if (_settingsProvider?.voiceResponseEnabled ?? false) {
        await _voiceService.speak(
          responseText,
          voice: _settingsProvider?.ttsVoice,
          rate: _settingsProvider?.ttsRate,
          pitch: _settingsProvider?.ttsPitch,
        );
      }
    } catch (e) {
      final aiMsg = AIChatMessage.text(
        sender: 'ai',
        text: 'Hata: $e',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await _realtimeService.addAIChatMessage(petId, chatId, aiMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resim mesajı gönder
  Future<void> sendImageMessage({
    required String petId,
    required Pet pet,
    required String imagePath,
  }) async {
    if (_activeChatId == null) {
      await startNewChat(petId);
    }
    final chatId = _activeChatId!;
    
    // Resim mesajı oluştur
    final userMsg = AIChatMessage.image(
      sender: 'user',
      text: '📷 Resim gönderildi',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      mediaUrl: imagePath,
    );
    
    await _realtimeService.addAIChatMessage(petId, chatId, userMsg);
    _isLoading = true;
    notifyListeners();
    
    try {
      // AI'dan resim hakkında yorum al
      final conversationStyle = _settingsProvider?.conversationStyle ?? ConversationStyle.friendly;
      final history = List<AIChatMessage>.from(_activeMessages)..add(userMsg);
      final responseText = await OpenAIService.getMultiTurnSuggestion(
        pet: pet,
        history: history,
        style: conversationStyle,
      );
      
      final aiMsg = AIChatMessage.text(
        sender: 'ai',
        text: responseText,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await _realtimeService.addAIChatMessage(petId, chatId, aiMsg);
      
      // Sesli yanıt
      if (_settingsProvider?.voiceResponseEnabled ?? false) {
        await _voiceService.speak(
          responseText,
          voice: _settingsProvider?.ttsVoice,
          rate: _settingsProvider?.ttsRate,
          pitch: _settingsProvider?.ttsPitch,
        );
      }
    } catch (e) {
      final aiMsg = AIChatMessage.text(
        sender: 'ai',
        text: 'Hata: $e',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await _realtimeService.addAIChatMessage(petId, chatId, aiMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  // Sohbet geçmişi listesi (her pet için)
  Future<List<Map<String, dynamic>>> getChatHistoryList(String petId) async {
    return await _realtimeService.getAIChatList(petId);
  }

  // initializeVoiceService fonksiyonunda TTS ve Whisper callbacklerini ayarla
  Future<void> initializeVoiceService() async {
    await _voiceService.initialize();
    
    // TTS callbacks
    _voiceService.onSpeakingStarted = () {
      _isSpeaking = true;
      notifyListeners();
    };
    _voiceService.onSpeakingStopped = () {
      _isSpeaking = false;
      notifyListeners();
    };
    
    // Whisper callbacks
    _voiceService.onSpeechResult = (text) {
      _recognizedText = text;
      notifyListeners();
      print('🎤 Tanınan metin: $text');
    };
    _voiceService.onListeningStarted = () {
      _isListening = true;
      notifyListeners();
    };
    _voiceService.onListeningStopped = () {
      _isListening = false;
      notifyListeners();
    };
    _voiceService.onSpeechError = (error) {
      print('❌ Sesli konuşma hatası: $error');
      _isListening = false;
      notifyListeners();
    };
    
    // Yeni: Sürekli dinleme callbacks
    _voiceService.onContinuousListeningStarted = () {
      _isContinuousListening = true;
      _currentTranscription = '';
      notifyListeners();
      print('🎤 Sürekli dinleme başladı');
    };
    _voiceService.onContinuousListeningStopped = () {
      _isContinuousListening = false;
      notifyListeners();
      print('🎤 Sürekli dinleme durdu');
    };
    _voiceService.onContinuousTranscription = (text) {
      _currentTranscription = text;
      notifyListeners();
      print('🎤 Anlık transkripsiyon güncellendi: $text');
    };
  }

  // startVoiceInput ve stopVoiceInput fonksiyonlarını kaldır

  Future<void> speakResponse(String? text) async {
    if (text != null && text.isNotEmpty) {
      try {
        await _voiceService.speak(
          text,
          voice: _settingsProvider?.ttsVoice,
          rate: _settingsProvider?.ttsRate,
          pitch: _settingsProvider?.ttsPitch,
        );
      } catch (e) {
        print('❌ AIProvider speakResponse hatası: $e');
      }
    }
  }

  Future<void> stopSpeaking() async {
    await _voiceService.stopSpeaking();
  }

  // Whisper ile ses dinleme fonksiyonları
  Future<void> startVoiceInput({int seconds = 5}) async {
    // Eğer başka bir ses servisi çalışıyorsa, başlatma
    if (isLoading) {
      print('⚠️ AI işlemi devam ediyor, ses dinleme başlatılamıyor');
      return;
    }
    
    await _voiceService.startVoiceInput(seconds: seconds);
  }

  Future<void> stopVoiceInput() async {
    await _voiceService.stopVoiceInput();
  }

  // Yeni: Sürekli ses dinleme fonksiyonları
  Future<void> startContinuousListening() async {
    _statusMessage = '';
    _isContinuousListening = true;
    notifyListeners();
    await _voiceService.startContinuousListening();
  }

  Future<void> stopContinuousListening({Pet? currentPet}) async {
    print('🛑 AI Provider: Sürekli dinleme durduruluyor...');
    _isContinuousListening = false;
    notifyListeners();
    
    final result = await _voiceService.stopContinuousListening();
    if (result != null && result.isNotEmpty) {
      _recognizedText = result;
      _statusMessage = 'Ses tanıma tamamlandı, işleniyor...';
      notifyListeners();
      
      // Otomatik olarak AI yanıtı al (sadece pet varsa)
      if (_activeChatId != null && currentPet != null) {
        try {
          await sendMessageAndGetAIResponse(
            petId: currentPet.id ?? currentPet.name,
            pet: currentPet,
            message: result,
          );
          _statusMessage = '';
        } catch (e) {
          if (e.toString().contains('rate limit') || e.toString().contains('429')) {
            _statusMessage = 'API limit aşıldı, lütfen birkaç dakika bekleyin...';
          } else {
            _statusMessage = 'Bir hata oluştu: ${e.toString()}';
          }
        }
        notifyListeners();
      } else {
        // Pet yoksa sadece tanınan metni göster
        _statusMessage = 'Ses tanıma tamamlandı';
        notifyListeners();
      }
    } else {
      _statusMessage = '';
      notifyListeners();
    }
    print('✅ AI Provider: Sürekli dinleme durduruldu');
  }

  void clearStatusMessage() {
    _statusMessage = '';
    notifyListeners();
  }

  void clearCurrentTranscription() {
    _voiceService.clearCurrentTranscription();
  }

  void clearActiveChat() {
    _activeChatId = null;
    _activeMessages = [];
    notifyListeners();
  }

  void clearRecognizedText() {
    _recognizedText = null;
    notifyListeners();
  }

  // Sesli komutları işle ve uygun aksiyonları gerçekleştir
  Future<void> processVoiceCommand(String command, Pet currentPet) async {
    print('🎤 Sesli komut işleniyor: $command');
    
    final lowerCommand = command.toLowerCase();
    
    // Besleme komutları
    if (lowerCommand.contains('besle') || lowerCommand.contains('yemek') || lowerCommand.contains('mama')) {
      await _feedPet(currentPet);
      return;
    }
    
    // Oyun komutları
    if (lowerCommand.contains('oyna') || lowerCommand.contains('oyun') || lowerCommand.contains('eğlendir')) {
      await _playWithPet(currentPet);
      return;
    }
    
    // Bakım komutları
    if (lowerCommand.contains('bakım') || lowerCommand.contains('temizle') || lowerCommand.contains('tara')) {
      await _groomPet(currentPet);
      return;
    }
    
    // Aşı komutları
    if (lowerCommand.contains('aşı') || lowerCommand.contains('vaccine')) {
      await _processVaccineCommand(command, currentPet);
      return;
    }
    
    // Enerji komutları
    if (lowerCommand.contains('enerji') || lowerCommand.contains('dinlendir') || lowerCommand.contains('uyku')) {
      await _restPet(currentPet);
      return;
    }
    
    // Genel durum sorgulama
    if (lowerCommand.contains('durum') || lowerCommand.contains('nasıl') || lowerCommand.contains('değer')) {
      await _checkPetStatus(currentPet);
      return;
    }
    
    // Eğer hiçbir komut eşleşmezse, normal AI yanıtı al
    await sendMessageAndGetAIResponse(
      petId: currentPet.id ?? currentPet.name,
      pet: currentPet,
      message: command,
    );
  }

  // Tanınan metni sesli komut olarak işle (sadece komut modunda)
  Future<void> processRecognizedTextAsCommand(Pet currentPet) async {
    if (_recognizedText != null && _recognizedText!.isNotEmpty) {
      await processVoiceCommand(_recognizedText!, currentPet);
      clearRecognizedText(); // İşlem tamamlandıktan sonra temizle
    }
  }

  // Pet besleme fonksiyonu
  Future<void> _feedPet(Pet pet) async {
    if (_petProvider == null) return;
    
    try {
      // Tokluk değerini artır
      pet.satiety = (pet.satiety + 3).clamp(0, 10);
      pet.lastUpdate = DateTime.now();
      
      // Pet'i güncelle
      await _petProvider!.updatePet(pet.name, pet);
      
      // Başarı mesajı gönder
      final response = '${pet.name} başarıyla beslendi! 🍖 Tokluk seviyesi: ${pet.satiety}/10';
      await _sendAIResponse(pet, response);
      
      print('✅ ${pet.name} beslendi');
    } catch (e) {
      print('❌ Besleme hatası: $e');
      await _sendAIResponse(pet, 'Besleme sırasında bir hata oluştu: $e');
    }
  }

  // Pet ile oyun oynama fonksiyonu
  Future<void> _playWithPet(Pet pet) async {
    if (_petProvider == null) return;
    
    try {
      // Mutluluk ve enerji değerlerini artır
      pet.happiness = (pet.happiness + 2).clamp(0, 10);
      pet.energy = (pet.energy - 1).clamp(0, 10); // Oyun enerji tüketir
      pet.lastUpdate = DateTime.now();
      
      // Pet'i güncelle
      await _petProvider!.updatePet(pet.name, pet);
      
      // Başarı mesajı gönder
      final response = '${pet.name} ile harika bir oyun oynadınız! 🎾 Mutluluk: ${pet.happiness}/10, Enerji: ${pet.energy}/10';
      await _sendAIResponse(pet, response);
      
      print('✅ ${pet.name} ile oyun oynandı');
    } catch (e) {
      print('❌ Oyun hatası: $e');
      await _sendAIResponse(pet, 'Oyun sırasında bir hata oluştu: $e');
    }
  }

  // Pet bakım fonksiyonu
  Future<void> _groomPet(Pet pet) async {
    if (_petProvider == null) return;
    
    try {
      // Bakım değerini artır
      pet.care = (pet.care + 3).clamp(0, 10);
      pet.lastUpdate = DateTime.now();
      
      // Pet'i güncelle
      await _petProvider!.updatePet(pet.name, pet);
      
      // Başarı mesajı gönder
      final response = '${pet.name} için bakım yapıldı! 🛁 Bakım seviyesi: ${pet.care}/10';
      await _sendAIResponse(pet, response);
      
      print('✅ ${pet.name} bakımı yapıldı');
    } catch (e) {
      print('❌ Bakım hatası: $e');
      await _sendAIResponse(pet, 'Bakım sırasında bir hata oluştu: $e');
    }
  }

  // Pet dinlendirme fonksiyonu
  Future<void> _restPet(Pet pet) async {
    if (_petProvider == null) return;
    
    try {
      // Enerji değerini artır
      pet.energy = (pet.energy + 3).clamp(0, 10);
      pet.lastUpdate = DateTime.now();
      
      // Pet'i güncelle
      await _petProvider!.updatePet(pet.name, pet);
      
      // Başarı mesajı gönder
      final response = '${pet.name} dinlendi ve enerji topladı! 😴 Enerji seviyesi: ${pet.energy}/10';
      await _sendAIResponse(pet, response);
      
      print('✅ ${pet.name} dinlendirildi');
    } catch (e) {
      print('❌ Dinlendirme hatası: $e');
      await _sendAIResponse(pet, 'Dinlendirme sırasında bir hata oluştu: $e');
    }
  }

  // Aşı komutlarını işleme
  Future<void> _processVaccineCommand(String command, Pet pet) async {
    if (_petProvider == null) return;
    
    final lowerCommand = command.toLowerCase();
    
    // Aşı ekleme komutları
    if (lowerCommand.contains('ekle') || lowerCommand.contains('yaptır') || lowerCommand.contains('yaptırdım')) {
      await _addVaccine(command, pet);
      return;
    }
    
    // Aşı listesi görüntüleme
    if (lowerCommand.contains('liste') || lowerCommand.contains('göster') || lowerCommand.contains('ne zaman')) {
      await _showVaccineList(pet);
      return;
    }
    
    // Aşı tamamlama
    if (lowerCommand.contains('tamamla') || lowerCommand.contains('yapıldı')) {
      await _completeVaccine(command, pet);
      return;
    }
  }

  // Aşı ekleme
  Future<void> _addVaccine(String command, Pet pet) async {
    try {
      // Komuttan aşı adını ve tarihini çıkar
      String vaccineName = '';
      DateTime vaccineDate = DateTime.now();
      
      // Basit aşı adı çıkarma
      if (command.contains('kuduz')) {
        vaccineName = 'Kuduz Aşısı';
      } else if (command.contains('karma')) {
        vaccineName = 'Karma Aşı';
      } else if (command.contains('parazit')) {
        vaccineName = 'Parazit Aşısı';
      } else if (command.contains('corona')) {
        vaccineName = 'Corona Aşısı';
      } else {
        vaccineName = 'Aşı';
      }
      
      // Tarih çıkarma
      if (command.contains('bugün')) {
        vaccineDate = DateTime.now();
      } else if (command.contains('yarın')) {
        vaccineDate = DateTime.now().add(Duration(days: 1));
      } else if (command.contains('haftaya')) {
        vaccineDate = DateTime.now().add(Duration(days: 7));
      } else if (command.contains('ay sonra')) {
        vaccineDate = DateTime.now().add(Duration(days: 30));
      }
      
      // Gün sayısı çıkarma (örn: "5 gün sonra")
      final dayMatch = RegExp(r'(\d+)\s*gün\s*sonra').firstMatch(command);
      if (dayMatch != null) {
        final days = int.parse(dayMatch.group(1)!);
        vaccineDate = DateTime.now().add(Duration(days: days));
      }
      
      // Aşıyı ekle
      final vaccine = Vaccine(
        name: vaccineName,
        date: vaccineDate,
        isDone: command.contains('yaptırdım') || command.contains('yapıldı'),
      );
      
      pet.vaccines.add(vaccine);
      await _petProvider!.updatePet(pet.name, pet);
      
      final status = vaccine.isDone ? 'yapıldı' : 'planlandı';
      final response = '${pet.name} için $vaccineName $status! 📅 Tarih: ${vaccineDate.day}/${vaccineDate.month}/${vaccineDate.year}';
      await _sendAIResponse(pet, response);
      
      print('✅ Aşı eklendi: $vaccineName');
    } catch (e) {
      print('❌ Aşı ekleme hatası: $e');
      await _sendAIResponse(pet, 'Aşı ekleme sırasında bir hata oluştu: $e');
    }
  }

  // Aşı listesi gösterme
  Future<void> _showVaccineList(Pet pet) async {
    try {
      if (pet.vaccines.isEmpty) {
        await _sendAIResponse(pet, '${pet.name} için henüz aşı kaydı bulunmuyor.');
        return;
      }
      
      String response = '${pet.name} için aşı listesi:\n';
      for (final vaccine in pet.vaccines) {
        final status = vaccine.isDone ? '✅' : '📅';
        final date = '${vaccine.date.day}/${vaccine.date.month}/${vaccine.date.year}';
        response += '$status ${vaccine.name} - $date\n';
      }
      
      await _sendAIResponse(pet, response);
    } catch (e) {
      print('❌ Aşı listesi hatası: $e');
      await _sendAIResponse(pet, 'Aşı listesi görüntülenirken hata oluştu: $e');
    }
  }

  // Aşı tamamlama
  Future<void> _completeVaccine(String command, Pet pet) async {
    try {
      // Komuttan aşı adını çıkar
      String vaccineName = '';
      if (command.contains('kuduz')) {
        vaccineName = 'Kuduz Aşısı';
      } else if (command.contains('karma')) {
        vaccineName = 'Karma Aşı';
      } else if (command.contains('parazit')) {
        vaccineName = 'Parazit Aşısı';
      } else if (command.contains('corona')) {
        vaccineName = 'Corona Aşısı';
      }
      
      // Aşıyı bul ve tamamla
      final vaccine = pet.vaccines.firstWhere(
        (v) => v.name.toLowerCase().contains(vaccineName.toLowerCase()),
        orElse: () => Vaccine(name: '', date: DateTime.now()),
      );
      
      if (vaccine.name.isNotEmpty) {
        vaccine.isDone = true;
        vaccine.date = DateTime.now();
        await _petProvider!.updatePet(pet.name, pet);
        
        await _sendAIResponse(pet, '${pet.name} için $vaccineName tamamlandı! ✅');
        print('✅ Aşı tamamlandı: $vaccineName');
      } else {
        await _sendAIResponse(pet, 'Belirtilen aşı bulunamadı.');
      }
    } catch (e) {
      print('❌ Aşı tamamlama hatası: $e');
      await _sendAIResponse(pet, 'Aşı tamamlama sırasında hata oluştu: $e');
    }
  }

  // Pet durumu kontrol etme
  Future<void> _checkPetStatus(Pet pet) async {
    try {
      final response = '''${pet.name} durumu:
🍖 Tokluk: ${pet.satiety}/10
😊 Mutluluk: ${pet.happiness}/10
⚡ Enerji: ${pet.energy}/10
🛁 Bakım: ${pet.care}/10

${pet.age} yaşında ${pet.gender} ${pet.type}''';
      
      await _sendAIResponse(pet, response);
    } catch (e) {
      print('❌ Durum kontrolü hatası: $e');
      await _sendAIResponse(pet, 'Durum kontrolü sırasında hata oluştu: $e');
    }
  }

  // AI yanıtı gönderme yardımcı fonksiyonu
  Future<void> _sendAIResponse(Pet pet, String response) async {
    if (_activeChatId == null) {
      await startNewChat(pet.id ?? pet.name);
    }
    
    final chatId = _activeChatId!;
    final aiMsg = AIChatMessage(
      sender: 'ai', 
      text: response, 
      timestamp: DateTime.now().millisecondsSinceEpoch
    );
    
    await _realtimeService.addAIChatMessage(pet.id ?? pet.name, chatId, aiMsg);
    
    // Sesli yanıt
    if (_settingsProvider?.voiceResponseEnabled ?? false) {
      await _voiceService.speak(
        response,
        voice: _settingsProvider?.ttsVoice,
        rate: _settingsProvider?.ttsRate,
        pitch: _settingsProvider?.ttsPitch,
      );
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
} 