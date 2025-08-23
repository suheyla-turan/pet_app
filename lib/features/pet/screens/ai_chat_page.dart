import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pati_takip/services/media_service.dart';
import 'package:pati_takip/services/voice_service.dart';
import 'package:pati_takip/features/pet/models/pet.dart';
import 'package:pati_takip/providers/auth_provider.dart';

class AIChatPage extends StatefulWidget {
  final Pet? pet;
  
  const AIChatPage({super.key, this.pet});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  
  // Servisler
  final MediaService _mediaService = MediaService();
  final VoiceService _voiceService = VoiceService();
  
  // Durum değişkenleri
  bool _isRecording = false;
  bool _isSpeaking = false;
  int _recordingDuration = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    
    // Add personalized welcome message
    _messages.add(ChatMessage(
      text: _getPersonalizedWelcomeMessage(),
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _showChatHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sohbet geçmişi yakında eklenecek!'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getPersonalizedWelcomeMessage() {
    if (widget.pet == null) {
      return "Merhaba! Evcil hayvanınız hakkında sorularınızı sorabilirsiniz. Size nasıl yardımcı olabilirim?";
    }

    final pet = widget.pet!;
    final age = pet.age;
    final type = _getLocalizedPetType(pet.type);
    final gender = pet.gender.toLowerCase() == 'male' || pet.gender.toLowerCase() == 'erkek' ? 'erkek' : 'dişi';
    
    String ageDescription;
    if (age < 1) {
      ageDescription = 'yavru';
    } else if (age < 3) {
      ageDescription = 'genç';
    } else if (age < 7) {
      ageDescription = 'yetişkin';
    } else {
      ageDescription = 'yaşlı';
    }

    return "Merhaba! ${pet.name} hakkında size yardımcı olmaya geldim! 🐾\n\n"
           "${pet.name} ${age} yaşında ${ageDescription} bir ${gender} ${type}. "
           "Sağlık, beslenme, egzersiz, bakım veya davranış konularında sorularınızı yanıtlayabilirim.\n\n"
           "Örnek sorular:\n"
           "• ${pet.name} için hangi mama türü uygun?\n"
           "• ${age < 1 ? 'Yavru' : age > 7 ? 'Yaşlı' : 'Yetişkin'} ${type} bakımında nelere dikkat etmeliyim?\n"
           "• ${pet.name} için egzersiz programı nasıl olmalı?\n\n"
           "Nasıl yardımcı olabilirim?";
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
            content: Text('Servisler başlatılamadı: $e'),
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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: _generateAIResponse(text),
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    });
  }

  String _generateAIResponse(String userMessage) {
    if (widget.pet == null) {
      // Pet bilgisi yoksa genel yanıt
      return "Evcil hayvanınız hakkında daha detaylı bilgi verebilmem için lütfen önce bir evcil hayvan ekleyin.";
    }

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
            Color(0xFF1A1A1A),
            Color(0xFF2C2C2C),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
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
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.pets,
                  color: Colors.purple,
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$age yaşında $gender $type",
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    if (pet.breed != null && pet.breed!.isNotEmpty)
                      Text(
                        "Cins: ${pet.breed!}",
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Status indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusIndicator(
                icon: Icons.restaurant,
                label: "Tokluk",
                value: pet.satiety,
                color: Colors.green,
              ),
              _buildStatusIndicator(
                icon: Icons.favorite,
                label: "Mutluluk",
                value: pet.happiness,
                color: Colors.pink,
              ),
              _buildStatusIndicator(
                icon: Icons.flash_on,
                label: "Enerji",
                value: pet.energy,
                color: Colors.orange,
              ),
              _buildStatusIndicator(
                icon: Icons.cleaning_services,
                label: "Bakım",
                value: pet.care,
                color: Colors.blue,
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
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 30,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 10,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
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

  void _showMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 50,
        100,
        20,
        0,
      ),
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      items: [
        PopupMenuItem(
          value: 'history',
          child: _buildPopupMenuItem(
            icon: Icons.history,
            title: "Sohbet Geçmişi",
          ),
        ),
        PopupMenuItem(
          value: 'new_chat',
          child: _buildPopupMenuItem(
            icon: Icons.add_comment,
            title: "Yeni Sohbet",
          ),
        ),
        PopupMenuItem(
          value: 'clear_chat',
          child: _buildPopupMenuItem(
            icon: Icons.clear,
            title: "Mevcut Sohbeti Temizle",
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleMenuAction(value);
      }
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'history':
        // TODO: Implement chat history
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sohbet geçmişi yakında eklenecek!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'new_chat':
        _startNewChat();
        break;
      case 'clear_chat':
        _clearCurrentChat();
        break;
    }
  }

  bool _hasMeaningfulChat() {
    // Check if there are actual conversation messages (not just welcome message)
    return _messages.length > 1;
  }

  String _getChatStatusText() {
    if (_messages.isEmpty) {
      return "Henüz sohbet yok";
    } else if (_messages.length == 1) {
      return "Yeni sohbet başlatıldı";
    } else {
      return "${_messages.length - 1} mesaj";
    }
  }

  void _startNewChat() {
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeni sohbet başlatıldı!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // If there are actual conversation messages, ask for confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
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
                const Text(
                  'Yeni Sohbet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Mevcut sohbet geçmişi kaydedilecek ve yeni bir sohbet başlatılacak. Devam etmek istiyor musunuz?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'İptal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _messages.clear();
                    _messages.add(ChatMessage(
                      text: _getPersonalizedWelcomeMessage(),
                      isUser: false,
                      timestamp: DateTime.now(),
                    ));
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Yeni sohbet başlatıldı!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Başlat',
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              const Text(
                'Sohbeti Temizle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Mevcut sohbet geçmişi kalıcı olarak silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'İptal',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _messages.clear();
                  _messages.add(ChatMessage(
                    text: _getPersonalizedWelcomeMessage(),
                    isUser: false,
                    timestamp: DateTime.now(),
                  ));
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mevcut sohbet temizlendi!'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Temizle',
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildPopupMenuItem({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;

    if (currentUser == null || (widget.pet != null && !widget.pet!.owners.contains(currentUser.uid))) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildEnhancedAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 80, color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 20),
              Text(
                "Bu evcil hayvanın sahibi değilsiniz.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Bu sayfayı görüntülemek için evcil hayvanınızın sahibi olmalısınız.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
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
    );
  }

  // FloatingActionButton ve _showQuickActions metodu kaldırıldı

  // _buildQuickActionTile metodu kaldırıldı

  PreferredSizeWidget _buildEnhancedAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D1B69),
              Color(0xFF1A1A1A),
            ],
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
                title: Column(
            children: [
              const Text(
                'PatiTakip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.pet != null ? "${widget.pet!.name} için AI Asistan" : "AI Asistan",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getChatStatusText(),
                        style: TextStyle(
                          color: _hasMeaningfulChat() ? Colors.blue : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'new_chat':
                  _startNewChat();
                  break;
                case 'chat_history':
                  _showChatHistory();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'new_chat',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.purple),
                    SizedBox(width: 12),
                    Text('Yeni Sohbet'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'chat_history',
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Sohbet Geçmişi'),
                  ],
                ),
              ),
            ],
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
            const SizedBox(height: 20),
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
                  color: const Color(0xFF8B5CF6).withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
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
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            widget.pet != null
                ? "${widget.pet!.name} hakkında herhangi bir soru sorabilirsiniz"
                : "Evcil hayvanınız hakkında herhangi bir soru sorabilirsiniz",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              height: 1.5,
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
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
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
                  Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    widget.pet != null ? "${widget.pet!.name} ile Sohbete Başla" : "Sohbete Başla",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
            icon: const Icon(Icons.help_outline, color: Colors.blue),
            label: const Text(
              'Yardım al',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          
          // Firebase bağlantı durumu
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Firebase Bağlantı Uyarısı',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Veritabanı erişim izinleri kontrol ediliyor. Lütfen Firebase Console\'da güvenlik kurallarını güncelleyin.',
                        style: TextStyle(
                          color: Colors.orange.withOpacity(0.8),
                          fontSize: 12,
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
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.help, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              const Text(
                'AI Chat Yardım',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Chat özelliğini kullanırken karşılaşabileceğiniz sorunlar:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.error_outline,
                  title: 'Erişim Hatası',
                  description: 'Evcil hayvanınızın sahibi olduğunuzdan emin olun',
                ),
                const SizedBox(height: 8),
                _buildHelpItem(
                  icon: Icons.wifi_off,
                  title: 'Bağlantı Sorunu',
                  description: 'İnternet bağlantınızı kontrol edin',
                ),
                const SizedBox(height: 8),
                _buildHelpItem(
                  icon: Icons.refresh,
                  title: 'Yeniden Deneme',
                  description: 'Sayfayı yeniden yükleyin veya uygulamayı kapatıp açın',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Firebase Güvenlik Kuralları',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Eğer "Permission denied" hatası alıyorsanız, Firebase Console\'da güvenlik kurallarını güncellemeniz gerekiyor.',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Firebase Console\'a gidin\n2. Realtime Database → Rules\n3. Geçici olarak tüm erişime izin verin',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.8),
                          fontSize: 11,
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
              child: const Text(
                'Kapat',
                style: TextStyle(
                  color: Colors.grey,
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
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Yeniden Dene',
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

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
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
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
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
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
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
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
            _messages.add(ChatMessage(
              text: _generateAIResponse(question),
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
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
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: _generateAIResponse(question),
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    });
  }

  Widget _buildChatSection() {
    return ListView.builder(
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
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple,
              child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.purple : const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(20),
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
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
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
                            style: TextStyle(color: Colors.white, fontSize: 14),
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
                          ),
                        ),
                      ),
                      // AI yanıtları için sesli okuma butonu
                      if (!message.isUser) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _isSpeaking ? null : () => _speakAIResponse(message.text),
                          icon: Icon(
                            _isSpeaking ? Icons.volume_off : Icons.volume_up,
                            color: _isSpeaking ? Colors.grey : Colors.white,
                            size: 20,
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
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
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
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.purple,
            child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(20),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildInputSection() {
    // Ekran boyutlarını al
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final viewInsets = mediaQuery.viewInsets.bottom;
    
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + bottomPadding + viewInsets, // Alt padding + güvenli alan + klavye yüksekliği
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(
            color: Color(0xFF2C2C2C),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Mesajınızı yazın...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red.withOpacity(0.3) : Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              children: [
                IconButton(
                  onPressed: _toggleVoiceRecording,
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? Colors.red : Colors.purple,
                    size: 24,
                  ),
                ),
                // Kayıt süresi göstergesi
                if (_isRecording)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _mediaService.formatDuration(_recordingDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: PopupMenuButton<ImageSource>(
              icon: const Icon(Icons.camera_alt, color: Colors.purple, size: 24),
              onSelected: (ImageSource source) => _pickImage(source: source),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ImageSource.camera,
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Kamera'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ImageSource.gallery,
                  child: Row(
                    children: [
                      Icon(Icons.photo_library, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Galeri'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
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
