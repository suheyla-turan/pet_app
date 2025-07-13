import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/ai_provider.dart';
import '../models/pet.dart';

class VoiceChatWidget extends StatelessWidget {
  final Pet pet;
  const VoiceChatWidget({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context);
    final aiResponse = aiProvider.getCurrentResponseForPet(pet.name);

    return Consumer<AIProvider>(
      builder: (context, aiProvider, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mic,
                      color: aiProvider.isListening ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Sesli Soru Sor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mikrofon butonuna basarak sesli soru sorabilirsiniz',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tanınan metin gösterimi
                if (aiProvider.recognizedText != null && aiProvider.recognizedText!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanınan Metin:',
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
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // AI yanıtı gösterimi
                if (aiResponse != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'AI Yanıtı:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                            const Spacer(),
                            if (aiProvider.isSpeaking)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          aiResponse,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Kontrol butonları
                Row(
                  children: [
                    // Mikrofon butonu
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: aiProvider.isLoading
                            ? null
                            : () {
                                if (aiProvider.isListening) {
                                  aiProvider.stopVoiceInput();
                                } else {
                                  aiProvider.startVoiceInput();
                                }
                              },
                        icon: Icon(
                          aiProvider.isListening ? Icons.stop : Icons.mic,
                          color: aiProvider.isListening ? Colors.white : null,
                        ),
                        label: Text(
                          aiProvider.isListening ? 'Dinlemeyi Durdur' : 'Soru Sor',
                          style: TextStyle(
                            color: aiProvider.isListening ? Colors.white : null,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: aiProvider.isListening ? Colors.red : null,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Sesli oku butonu
                    if (aiResponse != null && !aiProvider.isSpeaking)
                      IconButton(
                        onPressed: () => aiProvider.speakResponse(aiResponse),
                        icon: const Icon(Icons.volume_up),
                        tooltip: 'Sesli Oku',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                        ),
                      ),
                    
                    // Konuşmayı durdur butonu
                    if (aiProvider.isSpeaking)
                      IconButton(
                        onPressed: () => aiProvider.stopSpeaking(),
                        icon: const Icon(Icons.stop),
                        tooltip: 'Konuşmayı Durdur',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                        ),
                      ),
                  ],
                ),
                
                // Yükleme göstergesi
                if (aiProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('AI düşünüyor...'),
                      ],
                    ),
                  ),
                
                // Temizle butonu
                if (aiResponse != null || aiProvider.recognizedText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () => aiProvider.clearResponse(),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Temizle'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
} 