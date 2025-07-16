import 'package:flutter/foundation.dart';
import '../services/gemini_service.dart';
import '../services/voice_service.dart';
import '../providers/settings_provider.dart';
import '../features/pet/models/pet.dart';
import 'package:pet_app/features/pet/models/ai_chat_message.dart';
import '../services/realtime_service.dart';

class AIProvider with ChangeNotifier {
  // --- YENİ: Çoklu mesajlı AI sohbeti için ---
  String? _activeChatId;
  List<AIChatMessage> _activeMessages = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _recognizedText;
  SettingsProvider? _settingsProvider;
  final VoiceService _voiceService = VoiceService();
  final RealtimeService _realtimeService = RealtimeService();

  String? get activeChatId => _activeChatId;
  List<AIChatMessage> get activeMessages => _activeMessages;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String? get recognizedText => _recognizedText;

  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
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
    final userMsg = AIChatMessage(sender: 'user', text: message, timestamp: DateTime.now().millisecondsSinceEpoch);
    await _realtimeService.addAIChatMessage(petId, chatId, userMsg);
    _isLoading = true;
    notifyListeners();
    try {
      // Sohbet geçmişini Gemini'ye gönder
      final conversationStyle = _settingsProvider?.conversationStyle ?? ConversationStyle.friendly;
      final history = List<AIChatMessage>.from(_activeMessages)..add(userMsg);
      final responseText = await GeminiService.getMultiTurnSuggestion(
        pet: pet,
        history: history,
        style: conversationStyle,
      );
      final aiMsg = AIChatMessage(sender: 'ai', text: responseText, timestamp: DateTime.now().millisecondsSinceEpoch);
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
      final aiMsg = AIChatMessage(sender: 'ai', text: 'Hata: $e', timestamp: DateTime.now().millisecondsSinceEpoch);
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

  // Sesli konuşma metodları (değişmedi)
  Future<void> initializeVoiceService() async {
    await _voiceService.initialize();
    _voiceService.onSpeechResult = (text) {
      _recognizedText = text;
      notifyListeners();
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

  void clearActiveChat() {
    _activeChatId = null;
    _activeMessages = [];
    notifyListeners();
  }

  void clearRecognizedText() {
    _recognizedText = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
} 