import 'package:flutter/foundation.dart';
import '../services/gemini_service.dart';
import '../services/voice_service.dart';
import '../providers/settings_provider.dart';

class AIProvider with ChangeNotifier {
  String? _currentResponse;
  bool _isLoading = false;
  SettingsProvider? _settingsProvider;
  final VoiceService _voiceService = VoiceService();
  
  // Sesli konuşma durumları
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _recognizedText;

  String? get currentResponse => _currentResponse;
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

  Future<void> getSuggestion(String prompt) async {
    _setLoading(true);
    _currentResponse = null;
    notifyListeners();

    try {
      final conversationStyle = _settingsProvider?.conversationStyle ?? ConversationStyle.friendly;
      final response = await GeminiService.getSuggestion(prompt, style: conversationStyle);
      _currentResponse = response;
      
      // Eğer sesli yanıt etkinse, cevabı sesli oku
      if (_settingsProvider?.voiceResponseEnabled ?? false) {
        await _voiceService.speak(response);
      }
    } catch (e) {
      _currentResponse = 'Hata: $e';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> getMamaOnerisi(String petName, String petType) async {
    await getSuggestion('$petName adlı $petType için mama önerisi verir misin?');
  }

  Future<void> getOyunOnerisi(String petName, String petType) async {
    await getSuggestion('$petName adlı $petType için oyun önerisi verir misin?');
  }

  Future<void> getBakimOnerisi(String petName, String petType) async {
    await getSuggestion('$petName adlı $petType için bakım önerisi verir misin?');
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
        await _voiceService.speak(text);
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
    _currentResponse = null;
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