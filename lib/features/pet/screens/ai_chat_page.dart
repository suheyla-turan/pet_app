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
import '../../../services/whisper_service.dart'; // Added import for WhisperService
import 'dart:async'; // Added import for Timer

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
      });
    };
    _mediaService.onRecordingStopped = () {
      setState(() {
        _isRecording = false;
      });
    };
    _mediaService.onRecordingDurationChanged = (duration) {
      print('📱 AI Chat: Kayıt süresi güncellendi: ${duration}s');
      setState(() {
        // UI'ı güncelle (MediaService'teki süre otomatik olarak güncelleniyor)
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
                  Expanded(
                    child: Text(
                      'Sürekli Dinleniyor... Anlık Transkripsiyon Aktif',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await aiProvider.stopContinuousListening(currentPet: widget.pet);
                    },
                    child: Text('Durdur'),
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
                  Expanded(
                    child: Text(
                      'Ses Kaydı: ${_mediaService.formatDuration(_mediaService.recordingDuration)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                  Expanded(
                    child: Text(
                      'Sesli Komut Dinleniyor...',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => aiProvider.stopVoiceInput(),
                    child: Text('Durdur'),
                  ),
                ],
              ),
            ),
          // Global ses servisi durumu gösterimi
          if (WhisperService.isAnyVoiceServiceActive && !_isRecording && !aiProvider.isListening && !aiProvider.isContinuousListening)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.purple.shade100,
              child: Row(
                children: [
                  Icon(Icons.mic, color: Colors.purple),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ses Servisi Aktif: ${WhisperService.activeServiceName ?? "Bilinmeyen"}'),
                        Text(
                          WhisperService.getVoiceLockStatus(),
                          style: TextStyle(fontSize: 12, color: Colors.purple.shade700),
                        ),
                        Text(
                          'Bu durum ses kayıt işlemlerini engelleyebilir',
                          style: TextStyle(fontSize: 10, color: Colors.purple.shade600),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      WhisperService.releaseVoiceLock();
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ses kilidi temizlendi'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text('Temizle'),
                  ),
                  TextButton(
                    onPressed: () {
                      WhisperService.forceReleaseAllVoiceLocks();
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tüm ses servisleri zorla durduruldu'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text('Zorla Durdur'),
                  ),
                ],
              ),
            ),
          // Mesaj yazma alanı - Yukarı taşındı ve optimize edildi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[900] 
                  : Colors.grey[50],
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Sürekli dinleme butonu (AI asistan için)
                  IconButton(
                    icon: Icon(aiProvider.isContinuousListening ? Icons.stop : Icons.hearing),
                    tooltip: aiProvider.isContinuousListening ? 'Dinlemeyi Durdur' : 'AI Asistan Dinleme',
                    onPressed: (aiProvider.isLoading || _isRecording || aiProvider.isListening)
                        ? null
                        : () async {
                            try {
                              if (aiProvider.isContinuousListening) {
                                await aiProvider.stopContinuousListening(currentPet: widget.pet);
                              } else {
                                // Voice service'i başlat (eğer başlatılmamışsa)
                                await aiProvider.initializeVoiceService();
                                
                                // Diğer kayıtları durdur
                                if (_isRecording) {
                                  _mediaService.stopVoiceRecording();
                                }
                                if (aiProvider.isListening) {
                                  aiProvider.stopVoiceInput();
                                }
                                
                                // Ses kilidi kontrolü - daha güçlü kontrol
                                if (WhisperService.isAnyVoiceServiceActive) {
                                  final activeService = WhisperService.activeServiceName ?? 'Bilinmeyen';
                                  final status = WhisperService.getVoiceLockStatus();
                                  
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Ses Servisi Meşgul'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Aktif servis: $activeService'),
                                          SizedBox(height: 8),
                                          Text(status, style: TextStyle(fontSize: 12)),
                                          SizedBox(height: 16),
                                          Text('Ne yapmak istiyorsunuz?'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('İptal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            WhisperService.releaseVoiceLock();
                                            Navigator.pop(context);
                                            setState(() {});
                                            // Tekrar dene
                                            Future.delayed(Duration(milliseconds: 500), () {
                                              aiProvider.startContinuousListening();
                                            });
                                          },
                                          child: Text('Temizle ve Dene'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            WhisperService.forceReleaseAllVoiceLocks();
                                            Navigator.pop(context);
                                            setState(() {});
                                            // Tekrar dene
                                            Future.delayed(Duration(milliseconds: 500), () {
                                              aiProvider.startContinuousListening();
                                            });
                                          },
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: Text('Zorla Durdur'),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                                
                                await aiProvider.startContinuousListening();
                              }
                            } catch (e) {
                              print('❌ Sürekli dinleme hatası: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Ses dinleme hatası: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                  ),
                  // Ses kayıt butonu (chat için) - Mikrofon ikonu ile
                  IconButton(
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
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
                              
                              // Ses kilidi kontrolü - daha güçlü kontrol
                              if (WhisperService.isAnyVoiceServiceActive) {
                                final activeService = WhisperService.activeServiceName ?? 'Bilinmeyen';
                                final status = WhisperService.getVoiceLockStatus();
                                
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Ses Servisi Meşgul'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Aktif servis: $activeService'),
                                        SizedBox(height: 8),
                                        Text(status, style: TextStyle(fontSize: 12)),
                                        SizedBox(height: 16),
                                        Text('Ne yapmak istiyorsunuz?'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('İptal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          WhisperService.releaseVoiceLock();
                                          Navigator.pop(context);
                                          setState(() {});
                                          // Tekrar dene
                                          Future.delayed(Duration(milliseconds: 500), () {
                                            _mediaService.startVoiceRecording();
                                          });
                                        },
                                        child: Text('Temizle ve Dene'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          WhisperService.forceReleaseAllVoiceLocks();
                                          Navigator.pop(context);
                                          setState(() {});
                                          // Tekrar dene
                                          Future.delayed(Duration(milliseconds: 500), () {
                                            _mediaService.startVoiceRecording();
                                          });
                                        },
                                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        child: Text('Zorla Durdur'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
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
                  // Mesaj yazma alanı - Optimize edildi
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 40,
                        maxHeight: 120, // Maksimum yükseklik sınırı
                      ),
                      child: TextField(
                        controller: _chatController,
                        enabled: !aiProvider.isLoading && !aiProvider.isListening && !aiProvider.isContinuousListening,
                        maxLines: null,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(fontSize: 16),
                        // Performans optimizasyonları
                        enableInteractiveSelection: true,
                        autocorrect: false, // Otomatik düzeltmeyi kapat
                        enableSuggestions: false, // Önerileri kapat
                        textCapitalization: TextCapitalization.sentences, // Cümle başı büyük harf
                        // Debounce ile gereksiz rebuild'leri önle
                        onChanged: (value) {
                          // _debounceTimer?.cancel(); // Removed
                          // _debounceTimer = Timer(Duration(milliseconds: 300), () { // Removed
                          //   if (mounted) { // Removed
                          //     setState(() {}); // Removed
                          //   } // Removed
                          // }); // Removed
                        },
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
                          isDense: true, // Daha kompakt görünüm
                          // Performans için ek optimizasyonlar
                          counterText: '', // Karakter sayacını kapat
                          suffixIcon: null, // Suffix icon'u kapat
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
                        // Klavye açılırken performans iyileştirmesi
                        onTap: () {
                          // Klavye açılırken gereksiz rebuild'leri önle
                          // Future.delayed(Duration(milliseconds: 100), () { // Removed
                          //   if (mounted) { // Removed
                          //     setState(() {}); // Removed
                          //   } // Removed
                          // }); // Removed
                        },
                      ),
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
            ),
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