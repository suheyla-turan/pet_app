import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pati_takip/providers/ai_provider.dart';
import '../models/pet.dart';

class VoiceCommandWidget extends StatefulWidget {
  final Pet? pet; // Pet bilgisini al
  const VoiceCommandWidget({super.key, this.pet});
  @override
  State<VoiceCommandWidget> createState() => _VoiceCommandWidgetState();
}

class _VoiceCommandWidgetState extends State<VoiceCommandWidget> {
  @override
  void initState() {
    super.initState();
    // AI Provider'ı başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final aiProvider = Provider.of<AIProvider>(context, listen: false);
      aiProvider.initializeVoiceService();
    });
  }

  Future<void> _startContinuousListening() async {
    if (!mounted) return;
    
    try {
      print('🎤 Sürekli dinleme başlatılıyor...');
      final aiProvider = Provider.of<AIProvider>(context, listen: false);
      
      // Voice service'i başlat (eğer başlatılmamışsa)
      await aiProvider.initializeVoiceService();
      
      await aiProvider.startContinuousListening();
      print('✅ Sürekli dinleme başlatıldı');
    } catch (e) {
      print('❌ Sürekli dinleme başlatma hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ses dinleme başlatılamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopContinuousListening() async {
    if (!mounted) return;
    
    print('🛑 Sürekli dinleme durduruluyor...');
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    
    // Pet bilgisini geçir (varsa)
    await aiProvider.stopContinuousListening(currentPet: widget.pet);
    print('✅ Sürekli dinleme durduruldu');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AIProvider>(
      builder: (context, aiProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: aiProvider.isContinuousListening ? _stopContinuousListening : _startContinuousListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: aiProvider.isContinuousListening 
                        ? theme.colorScheme.error 
                        : theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (aiProvider.isContinuousListening 
                            ? theme.colorScheme.error 
                            : theme.colorScheme.primary).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: aiProvider.isLoading || aiProvider.isContinuousListening
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.mic, color: Colors.white, size: 36),
                            SizedBox(height: 4),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                aiProvider.isContinuousListening ? 'Sürekli Dinleniyor...' : 'Sürekli Sesli Komut',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: aiProvider.isContinuousListening 
                      ? theme.colorScheme.error 
                      : theme.colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                aiProvider.isContinuousListening 
                    ? 'Durdurmak için tekrar dokunun' 
                    : 'Başlatmak için dokunun',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              // Status mesajı
              if (aiProvider.statusMessage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: aiProvider.statusMessage.contains('limit') 
                        ? Colors.red.shade50 
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: aiProvider.statusMessage.contains('limit') 
                          ? Colors.red.shade200 
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        aiProvider.statusMessage.contains('limit') 
                            ? Icons.timer 
                            : Icons.info,
                        color: aiProvider.statusMessage.contains('limit') 
                            ? Colors.red 
                            : Colors.blue,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          aiProvider.statusMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: aiProvider.statusMessage.contains('limit') 
                                ? Colors.red.shade700 
                                : Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Anlık transkripsiyon gösterimi
              if (aiProvider.isContinuousListening && aiProvider.currentTranscription.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
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
                const SizedBox(height: 16),
              ],
              // Final transkripsiyon gösterimi
              if (aiProvider.recognizedText != null && aiProvider.recognizedText!.isNotEmpty && !aiProvider.isContinuousListening) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
              ],
            ],
          ),
        );
      },
    );
  }
} 