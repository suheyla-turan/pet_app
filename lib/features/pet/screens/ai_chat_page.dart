import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pati_takip/services/media_service.dart';
import 'package:pati_takip/services/voice_service.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

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
    
    // Add welcome message
    _messages.add(ChatMessage(
      text: "Merhaba! Evcil hayvanınız hakkında sorularınızı sorabilirsiniz. Size nasıl yardımcı olabilirim?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
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
    final responses = [
      "Bu konuda size yardımcı olabilirim. Evcil hayvanınızın yaşı ve cinsine göre önerilerim var.",
      "Bu soru çok iyi! Evcil hayvanların sağlığı için bu bilgi önemli.",
      "Deneyimlerime göre, bu durumda şunları yapmanızı öneririm...",
      "Evcil hayvanınızın davranışı normal görünüyor. Endişelenmenize gerek yok.",
      "Bu konuda veteriner hekiminize danışmanızı öneririm.",
    ];
    
    return responses[userMessage.length % responses.length];
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
        _buildPopupMenuItem(
          icon: Icons.history,
          title: "Sohbet Geçmişi",
          onTap: () {
            Navigator.pop(context);
            // TODO: Implement chat history
          },
        ),
        _buildPopupMenuItem(
          icon: Icons.add_comment,
          title: "Yeni Sohbet",
          onTap: () {
            Navigator.pop(context);
            setState(() {
              _messages.clear();
              _messages.add(ChatMessage(
                text: "Merhaba! Evcil hayvanınız hakkında sorularınızı sorabilirsiniz. Size nasıl yardımcı olabilirim?",
                isUser: false,
                timestamp: DateTime.now(),
              ));
            });
          },
        ),
        _buildPopupMenuItem(
          icon: Icons.clear,
          title: "Mevcut Sohbeti Temizle",
          onTap: () {
            Navigator.pop(context);
            setState(() {
              _messages.clear();
              _messages.add(ChatMessage(
                text: "Sohbet temizlendi. Yeni bir konuşma başlatabilirsiniz.",
                isUser: false,
                timestamp: DateTime.now(),
              ));
            });
          },
        ),
      ],
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

  PopupMenuItem _buildPopupMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _buildEnhancedAppBar(),
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

  PreferredSizeWidget _buildEnhancedAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
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
      title: Row(
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "AI Asistan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Çevrimiçi",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
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
          child: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showMenu,
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
        bottom: 24, // Alt padding'i azalttım çünkü input section'da zaten var
      ),
      child: Column(
        children: [
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
          const Text(
            "AI Asistan'a Hoş Geldiniz!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "Evcil hayvanınız hakkında herhangi bir soru sorabilirsiniz",
            style: TextStyle(
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
            title: "Sağlık Önerileri",
            subtitle: "Evcil hayvanınızın sağlığı için ipuçları",
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),
          _buildQuickActionCard(
            icon: Icons.pets,
            title: "Davranış Analizi",
            subtitle: "Evcil hayvanınızın davranışlarını anlayın",
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 16),
          _buildQuickActionCard(
            icon: Icons.restaurant,
            title: "Beslenme Tavsiyeleri",
            subtitle: "Doğru beslenme için öneriler",
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
                // This will automatically show when user types
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "Sohbete Başla",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
    return Container(
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
    );
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
