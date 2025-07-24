import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../../../providers/ai_provider.dart';
import '../../../services/media_service.dart';
import '../widgets/chat_message_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_chat_history_page.dart';
import '../../../l10n/app_localizations.dart';
import 'dart:io';

class AIChatPage extends StatefulWidget {
  final Pet pet;
  final String? chatId;
  const AIChatPage({super.key, required this.pet, this.chatId});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _chatController = TextEditingController();
  final MediaService _mediaService = MediaService();
  bool _isRecording = false;
  bool _isContinuousListening = false; // Yeni: sürekli dinleme durumu
  int _recordingDuration = 0;

  @override
  void initState() {
    super.initState();
    _initializeMediaService();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final aiProvider = context.read<AIProvider>();
      final petId = widget.pet.id ?? widget.pet.name;
      if (widget.chatId != null) {
        aiProvider.listenToChat(petId, widget.chatId!);
      } else {
        await aiProvider.startNewChat(petId);
        if (aiProvider.activeChatId != null) {
          aiProvider.listenToChat(petId, aiProvider.activeChatId!);
        }
      }
    });
  }

  Future<void> _initializeMediaService() async {
    await _mediaService.initialize();
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
    _mediaService.onRecordingDurationChanged = (duration) {
      setState(() {
        _recordingDuration = duration;
      });
    };
    _mediaService.onVoiceRecorded = (path, duration) {
      _sendVoiceMessage(path, duration);
    };
    _mediaService.onImageSelected = (path) {
      _sendImageMessage(path);
    };
    _mediaService.onError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    };
  }

  @override
  void dispose() {
    _mediaService.dispose();
    super.dispose();
  }

  Future<void> _sendVoiceMessage(String path, int duration) async {
    final aiProvider = context.read<AIProvider>();
    final petId = widget.pet.id ?? widget.pet.name;
    
    // Ses mesajını AI provider'a gönder
    await aiProvider.sendVoiceMessage(
      petId: petId,
      pet: widget.pet,
      voicePath: path,
      duration: duration,
    );
  }

  Future<void> _sendImageMessage(String path) async {
    final aiProvider = context.read<AIProvider>();
    final petId = widget.pet.id ?? widget.pet.name;
    
    // Resim mesajını AI provider'a gönder
    await aiProvider.sendImageMessage(
      petId: petId,
      pet: widget.pet,
      imagePath: path,
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                          ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.pop(context);
                  _mediaService.pickImage(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Fotoğraf Çek'),
                onTap: () {
                  Navigator.pop(context);
                  _mediaService.pickImage(source: ImageSource.camera);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PatiTakip'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final aiProvider = context.read<AIProvider>();
              final petId = widget.pet.id ?? widget.pet.name;
              if (value == 'new') {
                await aiProvider.startNewChat(petId);
                if (aiProvider.activeChatId != null) {
                  aiProvider.listenToChat(petId, aiProvider.activeChatId!);
                }
              } else if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIChatHistoryPage(pet: widget.pet),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'new', child: Text(AppLocalizations.of(context)!.newChat)),
              PopupMenuItem(value: 'history', child: Text(AppLocalizations.of(context)!.chatHistory)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: aiProvider.activeMessages.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.noMessages))
                : ListView.builder(
                    itemCount: aiProvider.activeMessages.length,
                    itemBuilder: (context, i) {
                      final msg = aiProvider.activeMessages[i];
                      final isUser = msg.sender == 'user';
                      return ChatMessageWidget(
                        message: msg,
                        isUser: isUser,
                        onVoicePlay: () {
                          if (msg.mediaUrl != null) {
                            _mediaService.playVoiceFile(msg.mediaUrl!);
                          }
                        },
                        onImageTap: () {
                          if (msg.mediaUrl != null) {
                            _showImageDialog(msg.mediaUrl!);
                          }
                        },
                      );
                    },
                  ),
          ),
          if (aiProvider.isLoading)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.aiThinking),
                ],
              ),
            ),
          // Anlık transkripsiyon gösterimi (sürekli dinleme sırasında)
          if (aiProvider.isContinuousListening && aiProvider.currentTranscription.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mic, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Anlık Transkripsiyon...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    aiProvider.currentTranscription,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          // Tanınan metin gösterimi (dinleme durduktan sonra)
          if (aiProvider.recognizedText != null && aiProvider.recognizedText!.isNotEmpty && !aiProvider.isContinuousListening)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.recognizedText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    aiProvider.recognizedText!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Mesaj olarak kullan butonu
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _chatController.text = aiProvider.recognizedText!;
                            aiProvider.clearRecognizedText();
                          },
                          child: const Text('Bu Metni Kullan'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Komut olarak işle butonu
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await aiProvider.processRecognizedTextAsCommand(widget.pet);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Komut Olarak İşle'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Kapat butonu
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => aiProvider.clearRecognizedText(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Sürekli dinleme durumu gösterimi
          if (aiProvider.isContinuousListening)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.mic, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Sürekli Dinleniyor... Anlık Transkripsiyon Aktif'),
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      await aiProvider.stopContinuousListening(currentPet: widget.pet);
                    },
                    child: Text('Durdur ve Yanıt Al'),
                  ),
                ],
              ),
            ),
          // Kayıt durumu gösterimi
          if (_isRecording)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  Icon(Icons.mic, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Ses Kaydı: ${_mediaService.formatDuration(_recordingDuration)}'),
                  Spacer(),
                  TextButton(
                    onPressed: () => _mediaService.stopVoiceRecording(),
                    child: Text('Durdur'),
                  ),
                ],
              ),
            ),
          // Sesli komut dinleme durumu gösterimi
          if (aiProvider.isListening && !aiProvider.isContinuousListening)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade100,
              child: Row(
                children: [
                  Icon(Icons.hearing, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Sesli Komut Dinleniyor...'),
                  Spacer(),
                  TextButton(
                    onPressed: () => aiProvider.stopVoiceInput(),
                    child: Text('Durdur'),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              // Sürekli dinleme butonu (AI asistan için)
              IconButton(
                icon: Icon(aiProvider.isContinuousListening ? Icons.stop : Icons.hearing),
                tooltip: aiProvider.isContinuousListening ? 'Dinlemeyi Durdur' : 'AI Asistan Dinleme',
                onPressed: (aiProvider.isLoading || _isRecording || aiProvider.isListening)
                    ? null
                    : () async {
                        if (aiProvider.isContinuousListening) {
                          await aiProvider.stopContinuousListening(currentPet: widget.pet);
                        } else {
                          // Diğer kayıtları durdur
                          if (_isRecording) {
                            _mediaService.stopVoiceRecording();
                          }
                          if (aiProvider.isListening) {
                            aiProvider.stopVoiceInput();
                          }
                          await aiProvider.startContinuousListening();
                        }
                      },
              ),
              // Ses kayıt butonu (chat için)
              IconButton(
                icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
                tooltip: _isRecording ? 'Kaydı Durdur' : 'Ses Mesajı Kaydet',
                onPressed: (aiProvider.isLoading || aiProvider.isListening || aiProvider.isContinuousListening)
                    ? null
                    : () {
                        if (_isRecording) {
                          _mediaService.stopVoiceRecording();
                        } else {
                          // Voice service'i durdur (eğer çalışıyorsa)
                          if (aiProvider.isListening) {
                            aiProvider.stopVoiceInput();
                          }
                          if (aiProvider.isContinuousListening) {
                            aiProvider.stopContinuousListening();
                          }
                          _mediaService.startVoiceRecording();
                        }
                      },
              ),
              // Resim butonu
              IconButton(
                icon: const Icon(Icons.image),
                tooltip: 'Resim Gönder',
                onPressed: (aiProvider.isLoading || aiProvider.isListening || aiProvider.isContinuousListening)
                    ? null
                    : () => _showImageSourceDialog(),
              ),
              // Mesaj yazma alanı
              Expanded(
                child: TextField(
                  controller: _chatController,
                  enabled: !aiProvider.isLoading && !aiProvider.isListening && !aiProvider.isContinuousListening,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.chatHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800] 
                        : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (val) async {
                    if (val.trim().isNotEmpty && !aiProvider.isLoading && !aiProvider.isListening && !aiProvider.isContinuousListening) {
                      await aiProvider.sendMessageAndGetAIResponse(
                        petId: widget.pet.id ?? widget.pet.name,
                        pet: widget.pet,
                        message: val.trim(),
                      );
                      _chatController.clear();
                    }
                  },
                ),
              ),
              // Gönder butonu
              IconButton(
                icon: const Icon(Icons.send),
                tooltip: 'Mesaj Gönder',
                onPressed: (aiProvider.isLoading || aiProvider.isListening || aiProvider.isContinuousListening)
                    ? null
                    : () async {
                        final val = _chatController.text.trim();
                        if (val.isNotEmpty) {
                          await aiProvider.sendMessageAndGetAIResponse(
                            petId: widget.pet.id ?? widget.pet.name,
                            pet: widget.pet,
                            message: val,
                          );
                          _chatController.clear();
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 300,
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 64),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 