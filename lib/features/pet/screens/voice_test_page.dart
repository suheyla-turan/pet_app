import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/ai_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/whisper_service.dart';
import '../models/pet.dart';

class VoiceTestPage extends StatefulWidget {
  final Pet? pet; // Pet bilgisini al
  const VoiceTestPage({super.key, this.pet});

  @override
  State<VoiceTestPage> createState() => _VoiceTestPageState();
}

class _VoiceTestPageState extends State<VoiceTestPage> {
  @override
  void initState() {
    super.initState();
    // AI Provider'ı başlat
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final aiProvider = Provider.of<AIProvider>(context, listen: false);
      await aiProvider.initializeVoiceService();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ses Tanıma Testi'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AIProvider>(
        builder: (context, aiProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Durum kartı
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          aiProvider.isContinuousListening ? Icons.mic : Icons.mic_off,
                          size: 48,
                          color: aiProvider.isContinuousListening ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          aiProvider.isContinuousListening ? 'Dinleniyor...' : 'Dinleme Durdu',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: aiProvider.isContinuousListening ? Colors.green : Colors.grey,
                          ),
                        ),
                        if (aiProvider.isLoading) ...[
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(),
                          const SizedBox(height: 8),
                          const Text('İşleniyor...'),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Ana mikrofon butonu
                GestureDetector(
                  onTap: () async {
                                            try {
                          if (aiProvider.isContinuousListening) {
                            await aiProvider.stopContinuousListening(currentPet: widget.pet);
                          } else {
                            await aiProvider.startContinuousListening();
                          }
                        } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hata: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: aiProvider.isContinuousListening ? Colors.red : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (aiProvider.isContinuousListening ? Colors.red : theme.colorScheme.primary).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      aiProvider.isContinuousListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Anlık transkripsiyon
                if (aiProvider.isContinuousListening && aiProvider.currentTranscription.isNotEmpty) ...[
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mic, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Anlık Transkripsiyon:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            aiProvider.currentTranscription,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Final transkripsiyon
                if (aiProvider.recognizedText != null && aiProvider.recognizedText!.isNotEmpty && !aiProvider.isContinuousListening) ...[
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Tanınan Metin:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            aiProvider.recognizedText!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Status mesajı
                if (aiProvider.statusMessage.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: aiProvider.statusMessage.contains('limit') ? Colors.red.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: aiProvider.statusMessage.contains('limit') ? Colors.red.shade200 : Colors.blue.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          aiProvider.statusMessage.contains('limit') ? Icons.timer : Icons.info,
                          color: aiProvider.statusMessage.contains('limit') ? Colors.red : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            aiProvider.statusMessage,
                            style: TextStyle(
                              color: aiProvider.statusMessage.contains('limit') ? Colors.red.shade700 : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // AI Mesajları
                if (aiProvider.activeMessages.isNotEmpty) ...[
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.smart_toy, color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'AI Yanıtları:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ...aiProvider.activeMessages
                              .where((msg) => msg.sender == 'ai')
                              .map((msg) => Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green.shade200),
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                
                // Kontrol butonları
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => aiProvider.clearRecognizedText(),
                        icon: const Icon(Icons.clear),
                        label: const Text('Temizle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => aiProvider.clearCurrentTranscription(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Yenile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Test butonları
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final result = await WhisperService.testApiKey();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result ? '✅ API Key geçerli!' : '❌ API Key geçersiz!'),
                                  backgroundColor: result ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ API Test hatası: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.api),
                        label: const Text('API Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final result = await WhisperService.testSimpleRecording();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result ?? '❌ Ses kayıt testi başarısız!'),
                                  backgroundColor: result != null ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ Ses kayıt testi hatası: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.mic),
                        label: const Text('Ses Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Bilgi kartı
                Card(
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kullanım Talimatları:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('1. Mikrofon butonuna basın'),
                        const Text('2. Konuşmaya başlayın'),
                        const Text('3. Anlık transkripsiyonu görün'),
                        const Text('4. Tekrar butona basarak durdurun'),
                        const Text('5. Final transkripsiyonu görün'),
                        const SizedBox(height: 8),
                        Text(
                          'Not: OpenAI API key\'inizin doğru olduğundan emin olun!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 