import 'package:flutter/foundation.dart';
import '../services/gemini_service.dart';
import '../services/voice_service.dart';
import '../providers/settings_provider.dart';
import '../features/pet/models/pet.dart';

class AIProvider with ChangeNotifier {
  final Map<String, String> _petResponses = {};
  String? getCurrentResponseForPet(String petKey) => _petResponses[petKey];
  void clearResponseForPet(String petKey) {
    _petResponses.remove(petKey);
    notifyListeners();
  }
  bool _isLoading = false;
  SettingsProvider? _settingsProvider;
  final VoiceService _voiceService = VoiceService();
  
  // Sesli konuşma durumları
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _recognizedText;

  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String? get recognizedText => _recognizedText;

  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
  }

  Future<void> initializeVoiceService() async {
    await _voiceService.initialize();
    
    // Callback'leri ayarla
    _voiceService.onSpeechResult = (text) {
      _recognizedText = text;
      notifyListeners();
      // Otomatik olarak AI'ya sorma - kullanıcı manuel olarak soracak
    };
    
    _voiceService.onListeningStarted = () {
      _isListening = true;
      notifyListeners();
    };
    
    _voiceService.onListeningStopped = () {
      _isListening = false;
      notifyListeners();
    };
    
    _voiceService.onSpeakingStarted = () {
      _isSpeaking = true;
      notifyListeners();
    };
    
    _voiceService.onSpeakingStopped = () {
      _isSpeaking = false;
      notifyListeners();
    };
    
    _voiceService.onSpeechError = (error) {
      print('❌ Sesli konuşma hatası: $error');
      _isListening = false;
      notifyListeners();
    };
  }

  String _petInfoPrompt(Pet pet) {
    return '''Aşağıda evcil hayvanımın bilgileri var:
- Adı: ${pet.name}
- Türü: ${pet.type}
- Cinsiyet: ${pet.gender}
- Yaş: ${pet.age}
- Doğum Tarihi: ${pet.birthDate.day}.${pet.birthDate.month}.${pet.birthDate.year}
- Açlık: ${pet.hunger}/10
- Mutluluk: ${pet.happiness}/10
- Enerji: ${pet.energy}/10
- Bakım: ${pet.care}/10
''';
  }

  Future<void> getSuggestion(String prompt, {required Pet pet}) async {
    _setLoading(true);
    notifyListeners();
    try {
      final conversationStyle = _settingsProvider?.conversationStyle ?? ConversationStyle.friendly;
      String fullPrompt = _petInfoPrompt(pet) + '\nSoru: ' + prompt;
      final response = await GeminiService.getSuggestion(fullPrompt, style: conversationStyle);
      _petResponses[pet.name] = response;
      // Eğer sesli yanıt etkinse, cevabı sesli oku
      if (_settingsProvider?.voiceResponseEnabled ?? false) {
        await _voiceService.speak(
          response,
          voice: _settingsProvider?.ttsVoice,
          rate: _settingsProvider?.ttsRate,
          pitch: _settingsProvider?.ttsPitch,
        );
      }
    } catch (e) {
      _petResponses[pet.name] = 'Hata: $e';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> getMamaOnerisi(Pet pet) async {
    await getSuggestion('Mama önerisi verir misin?', pet: pet);
  }

  Future<void> getOyunOnerisi(Pet pet) async {
    await getSuggestion('Oyun önerisi verir misin?', pet: pet);
  }

  Future<void> getBakimOnerisi(Pet pet) async {
    await getSuggestion('Bakım önerisi verir misin?', pet: pet);
  }

  // Sesli konuşma metodları
  Future<void> startVoiceInput() async {
    if (!_voiceService.speechEnabled) {
      await initializeVoiceService();
    }
    await _voiceService.startListening();
  }

  Future<void> stopVoiceInput() async {
    await _voiceService.stopListening();
  }

  Future<void> speakResponse(String? text) async {
    print('🎤 AIProvider: Sesli okuma isteği alındı');
    print('🎤 Metin: $text');
    
    if (text != null && text.isNotEmpty) {
      try {
        print('🎤 VoiceService.speak çağrılıyor...');
        await _voiceService.speak(
          text,
          voice: _settingsProvider?.ttsVoice,
          rate: _settingsProvider?.ttsRate,
          pitch: _settingsProvider?.ttsPitch,
        );
        print('🎤 VoiceService.speak tamamlandı');
      } catch (e) {
        print('❌ AIProvider speakResponse hatası: $e'); 
      }
    } else {
      print('❌ Boş veya null metin, sesli okuma yapılmıyor');
    }
  }

  Future<void> stopSpeaking() async {
    await _voiceService.stopSpeaking();
  }

  void clearResponse() {
    // _currentResponse = null; // Removed
    _recognizedText = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
} 