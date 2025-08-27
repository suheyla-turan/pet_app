import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'package:pati_takip/services/media_service.dart';
import 'package:pati_takip/services/voice_service.dart';
import 'package:pati_takip/services/chat_history_service.dart';
import 'package:pati_takip/features/pet/models/pet.dart';
import 'package:pati_takip/features/pet/models/chat_history.dart';
import 'package:pati_takip/features/pet/widgets/chat_history_overlay.dart';
import 'package:pati_takip/providers/auth_provider.dart';
import 'package:pati_takip/providers/theme_provider.dart';
import 'package:pati_takip/l10n/app_localizations.dart';
import 'package:pati_takip/secrets.dart';

class AIChatPage extends StatefulWidget {
  final Pet? pet;
  
  const AIChatPage({super.key, this.pet});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  
  // Firebase referansları
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _messageSubscription;
  
  // Servisler
  final MediaService _mediaService = MediaService();
  final VoiceService _voiceService = VoiceService();
  
  // Durum değişkenleri
  bool _isRecording = false;
  bool _isSpeaking = false;
  int _recordingDuration = 0;
  
  // Chat history overlay
  bool _showChatHistoryOverlay = false;
  ChatHistory? _currentChatHistory;

  // AI Configuration
  static const String _aiServiceUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _fallbackAiUrl = 'https://api.anthropic.com/v1/messages';
  bool _useFallbackAI = false;
  bool _isAIServiceAvailable = true;
  String _aiServiceStatus = 'AI Servisi Aktif';

  @override
  void initState() {
    super.initState();
    _initializeServices();
    
    // Initialize current chat history
    _currentChatHistory = ChatHistoryService.createNewChat(
      petId: widget.pet?.id,
      petName: widget.pet?.name,
    );
    
    // Add personalized welcome message
    _messages.add(ChatMessage(
      text: widget.pet != null 
          ? 'Merhaba! ${widget.pet!.name} hakkında size yardımcı olmaya geldim! 🐾\n\nEvcil hayvanınızın sağlığı, davranışı, beslenmesi ve bakımı hakkında kişiselleştirilmiş tavsiyeler verebilirim. Ne öğrenmek istiyorsunuz?'
          : 'Merhaba! Ben sizin AI evcil hayvan bakım asistanınızım. Size nasıl yardımcı olabilirim?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    
    // ScrollController'ı başlat
    _scrollController.addListener(() {
      // Scroll pozisyonunu takip et
    });
    
    // Firebase mesaj stream'ini başlat
    if (widget.pet != null) {
      _startFirebaseMessageStream();
    }
  }

  void _showChatHistory() {
    setState(() {
      _showChatHistoryOverlay = true;
    });
  }

  void _hideChatHistoryOverlay() {
    setState(() {
      _showChatHistoryOverlay = false;
    });
  }

  void _onChatSelected(ChatHistory chat) async {
    // Firebase stream'i durdur ve temizle
    await _stopFirebaseMessageStream();
    
    // Seçilen sohbeti yükle
    _currentChatHistory = chat;
    
    // Mesajları temizle ve hoş geldin mesajını ekle
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
        text: _getPersonalizedWelcomeMessage(),
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    
    _hideChatHistoryOverlay();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${chat.title} mesajlar yükleniyor...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onNewChat() {
    _startNewChat();
  }

  String _getPersonalizedWelcomeMessage() {
    if (widget.pet == null) {
      return AppLocalizations.of(context)!.aiChatInstructions;
    }

    final pet = widget.pet!;
    return AppLocalizations.of(context)!.aiChatInstructionsWithPet(pet.name);
  }

  Future<void> _initializeServices() async {
    try {
      // MediaService'i başlat
      await _mediaService.initialize();
      
      // VoiceService'i başlat
      await _voiceService.initialize();
      
      // Callback'leri ayarla
      _setupMediaServiceCallbacks();
      _setupVoiceServiceCallbacks();
      
      print('✅ AI Chat servisleri başlatıldı');
    } catch (e) {
      print('❌ AI Chat servisleri başlatılamadı: $e');
      // Kullanıcıya hata mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorOccurred}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _setupMediaServiceCallbacks() {
    _mediaService.onImageSelected = (String imagePath) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Görsel gönderildi",
          isUser: true,
          timestamp: DateTime.now(),
          imagePath: imagePath,
        ));
      });
      
      // AI yanıtı simüle et ve sesli okut
      final aiResponse = "Görselinizi aldım. Bu görsel hakkında size nasıl yardımcı olabilirim?";
      _simulateAIResponse(aiResponse);
      
      // Save chat history after adding image
      _saveChatHistory();
      
      // AI yanıtını sesli okut
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _speakAIResponse(aiResponse);
        }
      });
    };

    _mediaService.onVoiceRecorded = (String audioPath, int duration) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Sesli mesaj gönderildi (${_mediaService.formatDuration(duration)})",
          isUser: true,
          timestamp: DateTime.now(),
          audioPath: audioPath,
        ));
        _isRecording = false;
        _recordingDuration = 0;
      });
      
      // AI yanıtı simüle et ve sesli okut
      final aiResponse = "Sesli mesajınızı aldım. Size nasıl yardımcı olabilirim?";
      _simulateAIResponse(aiResponse);
      
      // Save chat history after adding voice message
      _saveChatHistory();
      
      // AI yanıtını sesli okut
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _speakAIResponse(aiResponse);
        }
      });
    };

    _mediaService.onRecordingStarted = () {
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });
    };

    _mediaService.onRecordingStopped = () {
      setState(() {
        _isRecording = false;
      });
    };

    _mediaService.onRecordingDurationChanged = (int duration) {
      setState(() {
        _recordingDuration = duration;
      });
    };

    _mediaService.onError = (String error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    };
  }

  void _setupVoiceServiceCallbacks() {
    _voiceService.onSpeakingStarted = () {
      setState(() {
        _isSpeaking = true;
      });
    };

    _voiceService.onSpeakingStopped = () {
      setState(() {
        _isSpeaking = false;
      });
    };
  }

  void _simulateAIResponse(String response) {
    setState(() {
      _isTyping = true;
    });

    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        
        // Save chat history after AI response
        _saveChatHistory();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _stopFirebaseMessageStream();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      // Kullanıcı mesajını Firebase'e gönder
      if (widget.pet?.id != null && _auth.currentUser != null) {
        await _firestore
            .collection('hayvanlar')
            .doc(widget.pet!.id)
            .collection('messages')
            .add({
          'text': text,
          'userId': _auth.currentUser!.uid,
          'userName': _auth.currentUser!.displayName ?? 'Anonim',
          'timestamp': Timestamp.now(),
          'type': 'text',
        });
        
        print('✅ Mesaj Firebase\'e gönderildi');
      }
      
      // Kullanıcı mesajını ekle (Firebase stream aktif olsa da olmasa da)
      final userMessage = ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(userMessage);
        _isTyping = true;
      });

      _messageController.clear();

      // Chat history'yi kaydet
      await _saveChatHistory();

      // AI yanıtını simüle et
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          try {
            final aiResponse = await _generateAIResponse(text);
            final aiMessage = ChatMessage(
              text: aiResponse,
              isUser: false,
              timestamp: DateTime.now(),
            );
            
            // AI yanıtını Firebase'e gönder
            if (widget.pet?.id != null) {
              await _firestore
                  .collection('hayvanlar')
                  .doc(widget.pet!.id)
                  .collection('messages')
                  .add({
                'text': aiResponse,
                'userId': 'ai_assistant',
                'userName': 'AI Asistan',
                'timestamp': Timestamp.now(),
                'type': 'ai_response',
              });
              
              print('✅ AI yanıtı Firebase\'e gönderildi');
            }
            
            setState(() {
              _isTyping = false;
              // AI mesajını ekle (Firebase stream aktif olsa da olmasa da)
              _messages.add(aiMessage);
            });
            
            // AI yanıtından sonra chat history'yi güncelle
            await _saveChatHistory();
            
            // Otomatik scroll
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          } catch (e) {
            print('❌ AI yanıtı oluşturulamadı: $e');
            setState(() {
              _isTyping = false;
            });
            
            // Hata mesajını göster
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppLocalizations.of(context)!.errorOccurred}: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      });
    } catch (e) {
      print('❌ Mesaj gönderme hatası: $e');
      setState(() {
        _isTyping = false;
      });
      
      // Hata mesajını göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorOccurred}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      print('💾 _saveChatHistory çağrıldı');
      print('📱 Mevcut mesaj sayısı: ${_messages.length}');
      print('🔑 Current chat history: ${_currentChatHistory?.title}');
      
      if (_currentChatHistory == null) {
        print('⚠️ _currentChatHistory null, yeni chat oluşturuluyor');
        _currentChatHistory = ChatHistoryService.createNewChat(
          petId: widget.pet?.id,
          petName: widget.pet?.name,
        );
        print('✅ Yeni chat oluşturuldu: ${_currentChatHistory!.title}');
      }
      
      final messages = _messages.map((msg) => {
        'text': msg.text,
        'isUser': msg.isUser,
        'timestamp': msg.timestamp.millisecondsSinceEpoch,
        'imagePath': msg.imagePath,
        'audioPath': msg.audioPath,
      }).toList();
      
      print('📝 Mesajlar map\'e dönüştürüldü: ${messages.length} mesaj');
      
      final updatedHistory = _currentChatHistory!.copyWith(
        messageCount: messages.length,
        lastMessage: messages.isNotEmpty ? messages.last['text'] as String? : null,
        lastModified: DateTime.now(),
      );
      
      print('🔄 Chat history güncellendi: ${updatedHistory.title} - ${updatedHistory.messageCount} mesaj');
      
      await ChatHistoryService.saveChatHistory(updatedHistory);
      _currentChatHistory = updatedHistory;
      
      print('✅ Chat history başarıyla kaydedildi');
    } catch (e) {
      print('❌ Chat geçmişi kaydedilemedi: $e');
      print('❌ Hata detayı: ${e.runtimeType}');
    }
  }

  Future<String> _generateAIResponse(String userMessage) async {
    if (widget.pet == null) {
      return "Evcil hayvanınız hakkında daha detaylı bilgi verebilmem için lütfen önce bir evcil hayvan ekleyin.";
    }

    try {
      // Gerçek AI servisi ile yanıt al
      final aiResponse = await _callAIService(userMessage);
      if (aiResponse.isNotEmpty) {
        return aiResponse;
      }
    } catch (e) {
      print('❌ AI servisi hatası: $e');
      // AI servisi çalışmazsa fallback yanıtları kullan
    }

    // Fallback: Basit keyword matching
    return _generateFallbackResponse(userMessage);
  }

  Future<String> _callAIService(String userMessage) async {
    try {
      final pet = widget.pet!;
      
      // Pet bilgilerini context olarak hazırla
      final petContext = _buildPetContext(pet);
      
      // AI prompt'unu hazırla
      final prompt = _buildAIPrompt(userMessage, petContext);
      
      // OpenAI API'yi çağır
      final response = await _callOpenAI(prompt);
      if (response.isNotEmpty) {
        _updateAIServiceStatus('OpenAI Aktif', true);
        return response;
      }
      
      // OpenAI çalışmazsa Anthropic'i dene
      final anthropicResponse = await _callAnthropic(prompt);
      if (anthropicResponse.isNotEmpty) {
        _updateAIServiceStatus('Claude Aktif', true);
        return anthropicResponse;
      }
      
      // Her iki servis de çalışmıyorsa
      _updateAIServiceStatus('AI Servisi Yok', false);
      
    } catch (e) {
      print('❌ AI servisi çağrısı hatası: $e');
      _updateAIServiceStatus('AI Servisi Hatası', false);
    }
    
    return '';
  }

  void _updateAIServiceStatus(String status, bool isAvailable) {
    if (mounted) {
      setState(() {
        _aiServiceStatus = status;
        _isAIServiceAvailable = isAvailable;
      });
    }
  }

  String _buildPetContext(Pet pet) {
    final age = pet.age;
    final type = _getLocalizedPetType(pet.type);
    final gender = pet.gender.toLowerCase() == 'male' || pet.gender.toLowerCase() == 'erkek' ? 'erkek' : 'dişi';
    final breed = pet.breed != null && pet.breed!.isNotEmpty ? pet.breed! : 'bilinmiyor';
    
    return '''
Evcil Hayvan Bilgileri:
- İsim: ${pet.name}
- Yaş: $age
- Tür: $type
- Cinsiyet: $gender
- Cins: $breed
- Doygunluk: ${pet.satiety}/10
- Mutluluk: ${pet.happiness}/10
- Enerji: ${pet.energy}/10
- Bakım: ${pet.care}/10
''';
  }

  String _buildAIPrompt(String userMessage, String petContext) {
    return '''
Sen bir evcil hayvan bakım uzmanısın. Aşağıdaki evcil hayvan bilgileri ve kullanıcının sorusu verilmiştir.

$petContext

Kullanıcı Sorusu: $userMessage

Lütfen evcil hayvanın özel durumunu göz önünde bulundurarak, kişiselleştirilmiş, detaylı ve faydalı bir yanıt ver. Yanıtın:
1. Evcil hayvanın adını kullan
2. Yaş ve türe özel öneriler içersin
3. Mevcut durumunu (doygunluk, mutluluk, enerji, bakım) dikkate alsın
4. Pratik ve uygulanabilir tavsiyeler versin
5. Türkçe olarak yazılsın
6. 200-400 kelime arasında olsun (daha detaylı ve kapsamlı)

Yanıt:
''';
  }

  Future<String> _callOpenAI(String prompt) async {
    try {
      if (Secrets.openaiApiKey.isEmpty) {
        print('⚠️ OpenAI API anahtarı bulunamadı');
        return '';
      }

      final response = await http.post(
        Uri.parse(_aiServiceUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Secrets.openaiApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Sen bir evcil hayvan bakım uzmanısın. Türkçe yanıt ver ve pratik tavsiyeler sun.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content.trim();
      } else {
        print('❌ OpenAI API hatası: ${response.statusCode} - ${response.body}');
        return '';
      }
    } catch (e) {
      print('❌ OpenAI API çağrısı hatası: $e');
      return '';
    }
  }

  Future<String> _callAnthropic(String prompt) async {
    try {
      if (Secrets.anthropicApiKey.isEmpty) {
        print('⚠️ Anthropic API anahtarı bulunamadı');
        return '';
      }

      final response = await http.post(
        Uri.parse(_fallbackAiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': Secrets.anthropicApiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-3-haiku-20240307',
          'max_tokens': 1000,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'];
        return content.trim();
      } else {
        print('❌ Anthropic API hatası: ${response.statusCode} - ${response.body}');
        return '';
      }
    } catch (e) {
      print('❌ Anthropic API çağrısı hatası: $e');
      return '';
    }
  }

  String _generateFallbackResponse(String userMessage) {
    final pet = widget.pet!;
    final lowerMessage = userMessage.toLowerCase();
    
    // Evcil hayvan bilgilerini kullanarak kişiselleştirilmiş yanıtlar
    if (lowerMessage.contains('yaş') || lowerMessage.contains('kaç yaş') || lowerMessage.contains('doğum')) {
      return "${pet.name} şu anda ${pet.age} yaşında. ${pet.age < 1 ? 'Henüz çok küçük bir yavru' : pet.age < 3 ? 'Genç bir evcil hayvan' : pet.age < 7 ? 'Yetişkin bir evcil hayvan' : 'Yaşlı bir evcil hayvan'}. Bu yaş grubunda ${_getAgeSpecificAdvice(pet.age, pet.type)}";
    }
    
    if (lowerMessage.contains('cins') || lowerMessage.contains('tür') || lowerMessage.contains('breed')) {
      final typeInfo = _getPetTypeInfo(pet.type);
      final breedInfo = pet.breed != null && pet.breed!.isNotEmpty ? "Cinsi: ${pet.breed!}. " : "";
      return "${pet.name} bir ${typeInfo}. ${breedInfo}${_getTypeSpecificAdvice(pet.type)}";
    }
    
    if (lowerMessage.contains('cinsiyet') || lowerMessage.contains('erkek') || lowerMessage.contains('dişi')) {
      final genderInfo = pet.gender.toLowerCase() == 'male' || pet.gender.toLowerCase() == 'erkek' ? 'erkek' : 'dişi';
      return "${pet.name} ${genderInfo} bir ${_getLocalizedPetType(pet.type)}. ${_getGenderSpecificAdvice(pet.gender, pet.type)}";
    }
    
    if (lowerMessage.contains('sağlık') || lowerMessage.contains('hastalık') || lowerMessage.contains('veteriner')) {
      return "${pet.name} için sağlık önerileri: ${_getHealthAdvice(pet)}";
    }
    
    if (lowerMessage.contains('beslenme') || lowerMessage.contains('yemek') || lowerMessage.contains('mama')) {
      return "${pet.name} için beslenme tavsiyeleri: ${_getFeedingAdvice(pet)}";
    }
    
    if (lowerMessage.contains('egzersiz') || lowerMessage.contains('oyun') || lowerMessage.contains('aktivite')) {
      return "${pet.name} için egzersiz önerileri: ${_getExerciseAdvice(pet)}";
    }
    
    if (lowerMessage.contains('bakım') || lowerMessage.contains('temizlik') || lowerMessage.contains('grooming')) {
      return "${pet.name} için bakım önerileri: ${_getCareAdvice(pet)}";
    }
    
    if (lowerMessage.contains('davranış') || lowerMessage.contains('karakter') || lowerMessage.contains('kişilik')) {
      return "${pet.name} hakkında davranış analizi: ${_getBehaviorAdvice(pet)}";
    }
    
    // Genel kişiselleştirilmiş yanıt
    return "${pet.name} (${pet.age} yaşında ${_getLocalizedPetType(pet.type)}) hakkında sorduğunuz konuda size yardımcı olabilirim. ${_getGeneralAdvice(pet)}";
  }

  String _getAgeSpecificAdvice(int age, String type) {
    if (age < 1) {
      return "yavru bakımı çok önemlidir. Düzenli veteriner kontrolleri ve özel beslenme programı gerekir.";
    } else if (age < 3) {
      return "enerjik ve öğrenmeye açıktır. Sosyalleşme ve temel eğitim için ideal dönemdir.";
    } else if (age < 7) {
      return "olgun ve dengeli bir dönemdedir. Rutin bakım ve düzenli egzersiz önemlidir.";
    } else {
      return "yaşlılık belirtileri başlayabilir. Daha sık veteriner kontrolleri ve özel bakım gerekebilir.";
    }
  }

  String _getPetTypeInfo(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
      case 'köpek':
        return 'köpek';
      case 'cat':
      case 'kedi':
        return 'kedi';
      case 'bird':
      case 'kuş':
        return 'kuş';
      case 'fish':
      case 'balık':
        return 'balık';
      case 'hamster':
        return 'hamster';
      case 'rabbit':
      case 'tavşan':
        return 'tavşan';
      default:
        return 'evcil hayvan';
    }
  }

  String _getLocalizedPetType(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
      case 'köpek':
        return 'köpek';
      case 'cat':
      case 'kedi':
        return 'kedi';
      case 'bird':
      case 'kuş':
        return 'kuş';
      case 'fish':
      case 'balık':
        return 'balık';
      case 'hamster':
        return 'hamster';
      case 'rabbit':
      case 'tavşan':
        return 'tavşan';
      default:
        return 'evcil hayvan';
    }
  }

  String _getTypeSpecificAdvice(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
      case 'köpek':
        return "Köpekler sosyal hayvanlardır ve düzenli egzersiz, eğitim ve sosyalleşme ihtiyacı duyarlar.";
      case 'cat':
      case 'kedi':
        return "Kediler bağımsız hayvanlardır ama yine de sevgi ve ilgiye ihtiyaç duyarlar. Tırmalama tahtası ve oyun alanları önemlidir.";
      case 'bird':
      case 'kuş':
        return "Kuşlar zeki hayvanlardır ve mental stimülasyona ihtiyaç duyarlar. Oyuncaklar ve sosyal etkileşim önemlidir.";
      case 'fish':
      case 'balık':
        return "Balıklar için su kalitesi ve uygun akvaryum ortamı çok önemlidir.";
      case 'hamster':
        return "Hamsterlar gece aktif hayvanlardır ve çok fazla uykuya ihtiyaç duyarlar.";
      case 'rabbit':
      case 'tavşan':
        return "Tavşanlar sosyal hayvanlardır ve çift olarak yaşamayı tercih ederler.";
      default:
        return "Her evcil hayvan türünün kendine özgü ihtiyaçları vardır.";
    }
  }

  String _getGenderSpecificAdvice(String gender, String type) {
    final isMale = gender.toLowerCase() == 'male' || gender.toLowerCase() == 'erkek';
    
    if (type.toLowerCase() == 'dog' || type.toLowerCase() == 'köpek') {
      return isMale ? "Erkek köpekler genellikle daha dominant olabilir ve daha fazla egzersiz ihtiyacı duyabilir." : "Dişi köpekler genellikle daha sakin ve eğitime daha yatkın olabilir.";
    } else if (type.toLowerCase() == 'cat' || type.toLowerCase() == 'kedi') {
      return isMale ? "Erkek kediler genellikle daha büyük olur ve daha fazla alan ihtiyacı duyabilir." : "Dişi kediler genellikle daha temiz ve düzenli olur.";
    }
    
    return "Cinsiyet, evcil hayvanın karakterini etkileyebilir ama her hayvanın kendine özgü kişiliği vardır.";
  }

  String _getHealthAdvice(Pet pet) {
    final age = pet.age;
    final type = pet.type.toLowerCase();
    
    if (age < 1) {
      return "Yavru dönemde aşı programı çok önemlidir. Düzenli veteriner kontrolleri ve parazit tedavisi gerekir.";
    } else if (age > 7) {
      return "Yaşlı dönemde daha sık veteriner kontrolleri, kan testleri ve özel beslenme programı önerilir.";
    }
    
    if (type == 'dog' || type == 'köpek') {
      return "Köpekler için düzenli aşı, parazit tedavisi ve diş bakımı önemlidir.";
    } else if (type == 'cat' || type == 'kedi') {
      return "Kediler için düzenli aşı, tırnak kesimi ve tüy bakımı önemlidir.";
    }
    
    return "Düzenli veteriner kontrolleri ve aşı programı tüm evcil hayvanlar için önemlidir.";
  }

  String _getFeedingAdvice(Pet pet) {
    final age = pet.age;
    final type = pet.type.toLowerCase();
    
    if (age < 1) {
      return "Yavru dönemde günde 3-4 kez küçük porsiyonlarla beslenmelidir. Yavru maması kullanılmalıdır.";
    } else if (age > 7) {
      return "Yaşlı dönemde daha az kalorili, yaşlı maması kullanılmalıdır. Günde 2 kez beslenme yeterlidir.";
    }
    
    if (type == 'dog' || type == 'köpek') {
      return "Köpekler için günde 2 kez beslenme önerilir. Su her zaman erişilebilir olmalıdır.";
    } else if (type == 'cat' || type == 'kedi') {
      return "Kediler için günde 2-3 kez beslenme önerilir. Kuru mama ve ıslak mama kombinasyonu idealdir.";
    }
    
    return "Yaşa ve türe uygun mama seçimi ve düzenli beslenme programı önemlidir.";
  }

  String _getExerciseAdvice(Pet pet) {
    final age = pet.age;
    final type = pet.type.toLowerCase();
    
    if (age < 1) {
      return "Yavru dönemde kısa süreli, nazik egzersizler yapılmalıdır. Aşırı yorulmamalıdır.";
    } else if (age > 7) {
      return "Yaşlı dönemde hafif egzersizler yapılmalıdır. Yürüyüş ve nazik oyunlar idealdir.";
    }
    
    if (type == 'dog' || type == 'köpek') {
      return "Köpekler için günde en az 30-60 dakika egzersiz önerilir. Yürüyüş, koşu ve oyunlar önemlidir.";
    } else if (type == 'cat' || type == 'kedi') {
      return "Kediler için günde 15-30 dakika aktif oyun önerilir. Tırmalama tahtası ve oyuncaklar önemlidir.";
    }
    
    return "Yaşa ve türe uygun egzersiz programı evcil hayvanın sağlığı için çok önemlidir.";
  }

  String _getCareAdvice(Pet pet) {
    final type = pet.type.toLowerCase();
    
    if (type == 'dog' || type == 'köpek') {
      return "Köpekler için düzenli tüy bakımı, tırnak kesimi ve banyo önemlidir. Kulak temizliği de düzenli yapılmalıdır.";
    } else if (type == 'cat' || type == 'kedi') {
      return "Kediler kendilerini temizler ama düzenli tüy bakımı ve tırnak kesimi gerekebilir.";
    } else if (type == 'bird' || type == 'kuş') {
      return "Kuşlar için kafes temizliği, su değişimi ve oyuncaklar önemlidir.";
    }
    
    return "Her evcil hayvan türü için uygun bakım rutini oluşturulmalıdır.";
  }

  String _getBehaviorAdvice(Pet pet) {
    final age = pet.age;
    final type = pet.type.toLowerCase();
    
    if (age < 1) {
      return "Yavru dönemde sosyalleşme çok önemlidir. Farklı insanlar ve hayvanlarla tanıştırılmalıdır.";
    } else if (age > 7) {
      return "Yaşlı dönemde daha sakin ve istikrarlı davranışlar sergiler. Değişikliklerden hoşlanmayabilir.";
    }
    
    if (type == 'dog' || type == 'köpek') {
      return "Köpekler pak hayvanlardır ve liderlik bekler. Tutarlı eğitim ve sınırlar önemlidir.";
    } else if (type == 'cat' || type == 'kedi') {
      return "Kediler bağımsızdır ama sevgi gösterir. Onların alanına saygı göstermek önemlidir.";
    }
    
    return "Her evcil hayvanın kendine özgü karakteri vardır. Sabır ve anlayışla yaklaşmak önemlidir.";
  }

  String _getGeneralAdvice(Pet pet) {
    final status = _getPetStatusSummary(pet);
    return "Mevcut durumu: $status. ${_getRecommendations(pet)}";
  }

  String _getPetStatusSummary(Pet pet) {
    final satiety = pet.satiety;
    final happiness = pet.happiness;
    final energy = pet.energy;
    final care = pet.care;
    
    if (satiety >= 7 && happiness >= 7 && energy >= 7 && care >= 7) {
      return "Mükemmel durumda";
    } else if (satiety >= 5 && happiness >= 5 && energy >= 5 && care >= 5) {
      return "İyi durumda";
    } else if (satiety >= 3 && happiness >= 3 && energy >= 3 && care >= 3) {
      return "Orta durumda";
    } else {
      return "Dikkat gerektiren durumda";
    }
  }

  String _getRecommendations(Pet pet) {
    final recommendations = <String>[];
    
    if (pet.satiety < 5) recommendations.add("beslenme");
    if (pet.happiness < 5) recommendations.add("oyun ve ilgi");
    if (pet.energy < 5) recommendations.add("dinlenme");
    if (pet.care < 5) recommendations.add("bakım");
    
    if (recommendations.isEmpty) {
      return "Şu anda herhangi bir özel ihtiyaç yok.";
    }
    
    return "Önerilen iyileştirmeler: ${recommendations.join(', ')}.";
  }

  Widget _buildPetInfoCard() {
    if (widget.pet == null) return const SizedBox.shrink();
    
    final pet = widget.pet!;
    final age = pet.age;
    final type = _getLocalizedPetType(pet.type);
    final gender = pet.gender.toLowerCase() == 'male' || pet.gender.toLowerCase() == 'erkek' ? 'erkek' : 'dişi';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1B69), // Daha koyu mor
            Color(0xFF4C1D95), // Orta ton mor
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.6),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.pets,
                  color: Color(0xFF8B5CF6),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      "$age yaşında $gender $type",
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (pet.breed != null && pet.breed!.isNotEmpty)
                      Text(
                        "Cins: ${pet.breed!}",
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Status indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusIndicator(
                icon: Icons.restaurant,
                label: "Tokluk",
                value: pet.satiety,
                color: const Color(0xFF10B981),
              ),
              _buildStatusIndicator(
                icon: Icons.favorite,
                label: "Mutluluk",
                value: pet.happiness,
                color: const Color(0xFFF472B6),
              ),
              _buildStatusIndicator(
                icon: Icons.flash_on,
                label: "Enerji",
                value: pet.energy,
                color: const Color(0xFFF59E0B),
              ),
              _buildStatusIndicator(
                icon: Icons.cleaning_services,
                label: "Bakım",
                value: pet.care,
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 35,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFF475569).withOpacity(0.4),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 10,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Görsel seçme
  Future<void> _pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final imagePath = await _mediaService.pickImage(source: source);
      if (imagePath != null) {
        print('✅ Görsel seçildi: $imagePath');
      }
    } catch (e) {
      print('❌ Görsel seçme hatası: $e');
    }
  }

  // Ses kayıt başlatma/durdurma
  Future<void> _toggleVoiceRecording() async {
    try {
      if (_isRecording) {
        await _mediaService.stopVoiceRecording();
      } else {
        await _mediaService.startVoiceRecording();
      }
    } catch (e) {
      print('❌ Ses kayıt hatası: $e');
    }
  }

  // AI yanıtını sesli okutma
  Future<void> _speakAIResponse(String text) async {
    try {
      await _voiceService.speak(text);
    } catch (e) {
      print('❌ Sesli okuma hatası: $e');
    }
  }





  bool _hasMeaningfulChat() {
    // Check if there are actual conversation messages (not just welcome message)
    return _messages.length > 1;
  }

  String _getChatStatusText() {
    if (_messages.isEmpty) {
      return AppLocalizations.of(context)!.noChatYet;
    } else if (_messages.length == 1) {
      return AppLocalizations.of(context)!.newChatStarted;
    } else {
      return AppLocalizations.of(context)!.messageCount(_messages.length - 1);
    }
  }

  void _startNewChat() async {
    // Firebase stream'i durdur ve temizle
    await _stopFirebaseMessageStream();
    
    if (_messages.length <= 1) {
      // If there's only the welcome message or no messages, just start fresh
      setState(() {
        _messages.clear();
        _messages.add(ChatMessage(
          text: _getPersonalizedWelcomeMessage(),
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      
      // Create new chat history
      _currentChatHistory = ChatHistoryService.createNewChat(
        petId: widget.pet?.id,
        petName: widget.pet?.name,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.startNewChat),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // If there are actual conversation messages, ask for confirmation
      // Store the original context to avoid shadowing issues
      final originalContext = context;
      
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.add_comment,
                  color: Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.newChatConfirmTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              AppLocalizations.of(context)!.newChatConfirmMessage,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  AppLocalizations.of(originalContext)!.cancel,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  
                  // Save current chat to history
                  if (_currentChatHistory != null) {
                    final messages = _messages.map((msg) => {
                      'text': msg.text,
                      'isUser': msg.isUser,
                      'timestamp': msg.timestamp.millisecondsSinceEpoch,
                      'imagePath': msg.imagePath,
                      'audioPath': msg.audioPath,
                    }).toList();
                    
                    final updatedHistory = _currentChatHistory!.copyWith(
                      messageCount: messages.length,
                      lastMessage: messages.isNotEmpty ? messages.last['text'] as String? : null,
                      lastModified: DateTime.now(),
                    );
                    
                    await ChatHistoryService.saveChatHistory(updatedHistory);
                  }
                  
                  // Create new chat
                  _currentChatHistory = ChatHistoryService.createNewChat(
                    petId: widget.pet?.id,
                    petName: widget.pet?.name,
                  );
                  
                  setState(() {
                    _messages.clear();
                    _messages.add(ChatMessage(
                      text: _getPersonalizedWelcomeMessage(),
                      isUser: false,
                      timestamp: DateTime.now(),
                    ));
                  });
                  
                  // Close the overlay
                  _hideChatHistoryOverlay();
                  
                  ScaffoldMessenger.of(originalContext).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(originalContext)!.startNewChat),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(originalContext)!.start,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _clearCurrentChat() {
    // Store the original context to avoid shadowing issues
    final originalContext = context;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(originalContext)!.clearCurrentChat,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Mevcut sohbet geçmişi kalıcı olarak silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                AppLocalizations.of(originalContext)!.cancel,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                
                // Firebase stream'i durdur ve temizle
                await _stopFirebaseMessageStream();
                
                // Create new chat history
                _currentChatHistory = ChatHistoryService.createNewChat(
                  petId: widget.pet?.id,
                  petName: widget.pet?.name,
                );
                
                setState(() {
                  _messages.clear();
                  _messages.add(ChatMessage(
                    text: _getPersonalizedWelcomeMessage(),
                    isUser: false,
                    timestamp: DateTime.now(),
                  ));
                });
                
                // Close the overlay
                _hideChatHistoryOverlay();
                
                ScaffoldMessenger.of(originalContext).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(originalContext)!.clearCurrentChat),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(originalContext)!.clearCurrentChat,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Sohbet silme fonksiyonu
  Future<void> _deleteChat(ChatHistory chat) async {
    try {
      print('🗑️ Sohbet silme işlemi başlatıldı: ${chat.title}');
      
      // Onay dialog'u göster
      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sohbeti Sil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              '"${chat.title}" sohbetini kalıcı olarak silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  'İptal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        print('✅ Kullanıcı onayladı, sohbet siliniyor...');
        
        // Sohbeti sil
        await ChatHistoryService.deleteChat(chat.id);
        print('✅ ChatHistoryService.deleteChat tamamlandı');
        
        // Eğer silinen sohbet mevcut sohbet ise, yeni sohbet başlat
        if (_currentChatHistory?.id == chat.id) {
          print('🔄 Mevcut sohbet silindi, yeni sohbet başlatılıyor...');
          
          // Firebase stream'i durdur ve temizle
          await _stopFirebaseMessageStream();
          
          _currentChatHistory = ChatHistoryService.createNewChat(
            petId: widget.pet?.id,
            petName: widget.pet?.name,
          );
          
          setState(() {
            _messages.clear();
            _messages.add(ChatMessage(
              text: _getPersonalizedWelcomeMessage(),
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
          print('✅ Yeni sohbet başlatıldı');
        }
        
        // Overlay'i kapat
        _hideChatHistoryOverlay();
        
        // Başarı mesajı göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${chat.title}" sohbeti başarıyla silindi'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        print('✅ Sohbet silme işlemi başarıyla tamamlandı');
      } else {
        print('❌ Kullanıcı iptal etti');
      }
    } catch (e) {
      print('❌ Sohbet silinirken hata oluştu: $e');
      print('❌ Hata detayı: ${e.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sohbet silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;

    if (currentUser == null || (widget.pet != null && !widget.pet!.owners.contains(currentUser.uid))) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return Stack(
        children: [
          // Background container - Ana menü tarzı
          Container(
            decoration: themeProvider.getBackgroundDecoration(Theme.of(context).brightness == Brightness.dark),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildEnhancedAppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.youAreNotOwner,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.youAreNotOwner,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final themeProvider = Provider.of<ThemeProvider>(context);
    return Stack(
      children: [
        // Background container - Ana menü tarzı
        Container(
          decoration: BoxDecoration(
            gradient: themeProvider.getBackgroundGradient(Theme.of(context).brightness == Brightness.dark),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          // Klavye açılırken performans optimizasyonu
          resizeToAvoidBottomInset: false,
          appBar: _buildEnhancedAppBar(),
          // FloatingActionButton kaldırıldı
          body: SafeArea(
            bottom: false, // Alt kısmı SafeArea'dan çıkar çünkü kendi padding'imizi ekleyeceğiz
            child: Column(
              children: [
                // Main content area with robot icon
                Expanded(
                  child: _messages.isEmpty
                      ? _buildWelcomeSection()
                      : _buildChatSection(),
                ),
                // Input section
                _buildInputSection(),
              ],
            ),
          ),
        ),
        
        // Chat History Overlay
        if (_showChatHistoryOverlay)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: ChatHistoryOverlay(
              petId: widget.pet?.id,
              petName: widget.pet?.name,
              onNewChat: _onNewChat,
              onChatSelected: _onChatSelected,
              onClose: _hideChatHistoryOverlay,
              onClearCurrentChat: _clearCurrentChat,
              onDeleteChat: _deleteChat,
            ),
          ),
      ],
    );
  }

  // FloatingActionButton ve _showQuickActions metodu kaldırıldı

  // _buildQuickActionTile metodu kaldırıldı

  PreferredSizeWidget _buildEnhancedAppBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Tema rengine göre metin rengini belirle
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subtitleColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF6B7280);
    
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: textColor,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.2,
      ),
      iconTheme: IconThemeData(
        color: textColor,
        size: 24,
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(isDark ? 0.3 : 0.2),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(isDark ? 0.3 : 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.pet != null ? "${widget.pet!.name} için AI Asistan" : "AI Asistan",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getChatStatusText(),
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(isDark ? 0.3 : 0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.history, color: textColor, size: 22),
            onPressed: _showChatHistory,
            tooltip: 'Sohbet Geçmişi',
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24,
      ),
      child: Column(
        children: [
          // Pet info card if pet exists
          if (widget.pet != null) ...[
            _buildPetInfoCard(),
            const SizedBox(height: 24),
          ],
          const SizedBox(height: 40),
          // Hero section with animated robot
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          
          // Welcome text
          Text(
            widget.pet != null 
                ? "${widget.pet!.name} için AI Asistan"
                : "AI Asistan'a Hoş Geldiniz!",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            widget.pet != null
                ? "${widget.pet!.name} hakkında herhangi bir soru sorabilirsiniz"
                : "Evcil hayvanınız hakkında herhangi bir soru sorabilirsiniz",
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 16,
              height: 1.6,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Quick action cards
          _buildQuickActionCard(
            icon: Icons.health_and_safety,
            title: widget.pet != null ? "${widget.pet!.name} için Sağlık Önerileri" : "Sağlık Önerileri",
            subtitle: widget.pet != null 
                ? "${widget.pet!.name} (${widget.pet!.age} yaşında ${_getLocalizedPetType(widget.pet!.type)}) için sağlık ipuçları"
                : "Evcil hayvanınızın sağlığı için ipuçları",
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),
          _buildQuickActionCard(
            icon: Icons.pets,
            title: widget.pet != null ? "${widget.pet!.name} için Davranış Analizi" : "Davranış Analizi",
            subtitle: widget.pet != null 
                ? "${widget.pet!.name} (${widget.pet!.gender.toLowerCase() == 'male' || widget.pet!.gender.toLowerCase() == 'erkek' ? 'erkek' : 'dişi'} ${_getLocalizedPetType(widget.pet!.type)}) davranışları"
                : "Evcil hayvanınızın davranışlarını anlayın",
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 16),
          _buildQuickActionCard(
            icon: Icons.restaurant,
            title: widget.pet != null ? "${widget.pet!.name} için Beslenme Tavsiyeleri" : "Beslenme Tavsiyeleri",
            subtitle: widget.pet != null 
                ? "${widget.pet!.name} (${widget.pet!.age} yaşında) için beslenme önerileri"
                : "Doğru beslenme için öneriler",
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 40),
          
          // Start chat button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                if (widget.pet != null) {
                  _askGeneralQuestion();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    widget.pet != null ? "${widget.pet!.name} ile Sohbete Başla" : "Sohbete Başla",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Hata durumunda yardım butonu
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => _showHelpDialog(),
            icon: const Icon(Icons.help_outline, color: Color(0xFF60A5FA)),
                        label: Text(
              AppLocalizations.of(context)!.support,
              style: TextStyle(
                color: Color(0xFF60A5FA),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          
        ],
      ),
    );
  }

  void _showHelpDialog() {
    // Store the original context to avoid shadowing issues
    final originalContext = context;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.help, color: Color(0xFF3B82F6), size: 28),
              ),
              const SizedBox(width: 12),
                              Text(
                  '${AppLocalizations.of(context)!.aiChat} ${AppLocalizations.of(context)!.support}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.aiChat} ${AppLocalizations.of(context)!.support}',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                                  _buildHelpItem(
                    icon: Icons.error_outline,
                    title: '${AppLocalizations.of(context)!.errorOccurred}',
                    description: AppLocalizations.of(context)!.youAreNotOwner,
                  ),
                const SizedBox(height: 8),
                                  _buildHelpItem(
                    icon: Icons.wifi_off,
                    title: '${AppLocalizations.of(context)!.errorOccurred}',
                    description: '${AppLocalizations.of(context)!.errorOccurred}',
                  ),
                const SizedBox(height: 8),
                                  _buildHelpItem(
                    icon: Icons.refresh,
                    title: '${AppLocalizations.of(context)!.errorOccurred}',
                    description: '${AppLocalizations.of(context)!.errorOccurred}',
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.warning, color: Color(0xFFEF4444), size: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${AppLocalizations.of(context)!.errorOccurred}',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${AppLocalizations.of(context)!.errorOccurred}',
                        style: TextStyle(
                          color: Color(0xFFFCA5A5),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF374151)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.errorOccurred}',
                              style: const TextStyle(
                                color: Color(0xFFFCA5A5),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${AppLocalizations.of(context)!.errorOccurred}',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF374151).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
                              child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeServices(); // Servisleri yeniden başlat
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF3B82F6).withOpacity(0.3),
              ),
                              child: Text(
                  '${AppLocalizations.of(context)!.errorOccurred}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF374151).withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4B5563).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _handleQuickActionTap(title),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: color.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF64748B),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickActionTap(String title) {
    if (widget.pet == null) return;
    
    final pet = widget.pet!;
    String question = "";
    
    if (title.contains("Sağlık")) {
      question = "${pet.name} için sağlık önerileri nelerdir?";
    } else if (title.contains("Davranış")) {
      question = "${pet.name} için davranış analizi yapabilir misin?";
    } else if (title.contains("Beslenme")) {
      question = "${pet.name} için beslenme tavsiyeleri nelerdir?";
    }
    
    if (question.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: question,
          isUser: true,
          timestamp: DateTime.now(),
        ));
        _isTyping = true;
      });
      
      // AI yanıtını simüle et
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          final aiResponse = await _generateAIResponse(question);
          setState(() {
            _isTyping = false;
            _messages.add(ChatMessage(
              text: aiResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
          
          // Save chat history after AI response
          _saveChatHistory();
        }
      });
    }
  }

  void _askGeneralQuestion() {
    if (widget.pet == null) return;
    
    final pet = widget.pet!;
    final age = pet.age;
    final type = _getLocalizedPetType(pet.type);
    
    String question = "";
    if (age < 1) {
      question = "${pet.name} yavru bir $type. Yavru bakımında nelere dikkat etmeliyim?";
    } else if (age > 7) {
      question = "${pet.name} yaşlı bir $type. Yaşlı evcil hayvan bakımında nelere dikkat etmeliyim?";
    } else {
      question = "${pet.name} yetişkin bir $type. Genel bakım ve sağlık konularında önerileriniz nelerdir?";
    }
    
    setState(() {
      _messages.add(ChatMessage(
        text: question,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    
          // AI yanıtını simüle et
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          final aiResponse = await _generateAIResponse(question);
          setState(() {
            _isTyping = false;
            _messages.add(ChatMessage(
              text: aiResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
          
          // Save chat history after AI response
          _saveChatHistory();
        }
      });
  }

  Widget _buildChatSection() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16, // Alt padding'i azalttım çünkü input section'da zaten var
      ),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? const Color(0xFF8B5CF6) 
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: message.isUser 
                      ? const Color(0xFF8B5CF6).withOpacity(0.3)
                      : const Color(0xFF334155).withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser 
                        ? const Color(0xFF8B5CF6).withOpacity(0.2)
                        : const Color(0xFF1E293B).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Görsel varsa göster
                  if (message.imagePath != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(message.imagePath!),
                          width: 200,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 150,
                              decoration: BoxDecoration(
                                color: const Color(0xFF475569),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Color(0xFF94A3B8),
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  
                  // Ses dosyası varsa göster
                  if (message.audioPath != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _mediaService.playVoiceFile(message.audioPath!),
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                          ),
                          const Text(
                            "Sesli mesaj",
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Metin ve sesli okuma butonu
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing: 0.2,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      // AI yanıtları için sesli okuma butonu
                      if (!message.isUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            onPressed: _isSpeaking ? null : () => _speakAIResponse(message.text),
                            icon: Icon(
                              _isSpeaking ? Icons.volume_off : Icons.volume_up,
                              color: _isSpeaking ? const Color(0xFF94A3B8) : const Color(0xFF8B5CF6),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF334155).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    // Ekran boyutlarını al
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final viewInsets = mediaQuery.viewInsets.bottom;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    // Telefon boyutuna göre padding ve boyutları ayarla
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final buttonSize = isSmallScreen ? 45.0 : 50.0;
    final inputHeight = isSmallScreen ? 45.0 : 50.0;
    
    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 16,
        bottom: 16 + bottomPadding + viewInsets, // Alt padding + güvenli alan + klavye yüksekliği
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          top: BorderSide(
            color: Color(0xFF334155),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Kamera butonu - küçük ekranlarda gizle
          if (!isSmallScreen) ...[
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(buttonSize / 2),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: PopupMenuButton<ImageSource>(
                icon: const Icon(Icons.camera_alt, color: Color(0xFF8B5CF6), size: 20),
                onSelected: (ImageSource source) => _pickImage(source: source),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: ImageSource.camera,
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt, color: Color(0xFF8B5CF6)),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.camera),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ImageSource.gallery,
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, color: Color(0xFF8B5CF6)),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.gallery),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
          ],
          
          // Mikrofon butonu
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: _isRecording 
                  ? const Color(0xFFEF4444).withOpacity(0.3) 
                  : const Color(0xFF8B5CF6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(buttonSize / 2),
              border: Border.all(
                color: _isRecording 
                    ? const Color(0xFFEF4444).withOpacity(0.5)
                    : const Color(0xFF8B5CF6).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                IconButton(
                  onPressed: _toggleVoiceRecording,
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6),
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                // Kayıt süresi göstergesi
                if (_isRecording)
                  Positioned(
                    right: isSmallScreen ? 4 : 8,
                    top: isSmallScreen ? 4 : 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 4 : 6, 
                        vertical: isSmallScreen ? 1 : 2
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        _mediaService.formatDuration(_recordingDuration),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 8 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(width: isSmallScreen ? 6 : 8),
          
          // Mesaj giriş alanı
          Expanded(
            child: Container(
              height: inputHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(inputHeight / 2),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isSmallScreen ? 14 : 16,
                  letterSpacing: 0.2,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.writeMessage,
                  hintStyle: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20, 
                    vertical: isSmallScreen ? 12 : 15
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          
          SizedBox(width: isSmallScreen ? 6 : 8),
          
          // Gönder butonu
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
              ),
              borderRadius: BorderRadius.circular(buttonSize / 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(
                Icons.send, 
                color: Colors.white, 
                size: isSmallScreen ? 20 : 24
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _stopFirebaseMessageStream() async {
    if (_messageSubscription != null) {
      print('🛑 Firebase mesaj stream durduruluyor');
      await _messageSubscription!.cancel();
      _messageSubscription = null;
      print('✅ Firebase mesaj stream durduruldu');
    }
  }

  void _startFirebaseMessageStream() {
    if (widget.pet?.id == null) return;
    
    print('🔄 Firebase mesaj stream başlatılıyor - Pet ID: ${widget.pet!.id}');
    print('👤 Kullanıcı ID: ${_auth.currentUser?.uid}');
    print('📧 Kullanıcı e-posta doğrulandı mı: ${_auth.currentUser?.emailVerified}');
    
    try {
      _messageSubscription = _firestore
          .collection('hayvanlar')
          .doc(widget.pet!.id)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((snapshot) {
        print('📨 Firebase\'den ${snapshot.docs.length} mesaj alındı');
        
        if (snapshot.docs.isNotEmpty) {
          print('📝 İlk mesaj örneği: ${snapshot.docs.first.data()}');
        }
        
        final messages = snapshot.docs.map((doc) {
          final data = doc.data();
          print('🔍 Mesaj verisi: $data');
          return ChatMessage(
            text: data['text'] ?? '',
            isUser: data['userId'] == _auth.currentUser?.uid,
            timestamp: (data['timestamp'] as Timestamp).toDate(),
            imagePath: data['imagePath'],
            audioPath: data['audioPath'],
          );
        }).toList();
        
        print('✅ ${messages.length} mesaj işlendi');
        
        // Sadece Firebase'den gelen mesajları ekle, hoş geldin mesajını koru
        if (_messages.length <= 1) {
          // Eğer sadece hoş geldin mesajı varsa, Firebase mesajlarını ekle
          setState(() {
            _messages.addAll(messages);
          });
        } else {
          // Eğer zaten sohbet varsa, Firebase mesajlarını güncelle
          setState(() {
            // Hoş geldin mesajını koru
            final welcomeMessage = _messages.first;
            _messages.clear();
            _messages.add(welcomeMessage);
            _messages.addAll(messages);
          });
        }
        
        print('📱 UI güncellendi, toplam mesaj sayısı: ${_messages.length}');
        
        // Yeni mesajlar geldiğinde en alta kaydır
        if (messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
            });
          }
        }, onError: (error) {
          print('❌ Firebase mesaj stream hatası: $error');
          print('🔍 Hata detayı: ${error.toString()}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.errorOccurred}: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        });
      } catch (e) {
        print('❌ Firebase stream başlatılamadı: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorOccurred}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imagePath;
  final String? audioPath;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imagePath,
    this.audioPath,
  });
}
