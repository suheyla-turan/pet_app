import 'package:flutter/material.dart';
import 'package:pet_app/services/voice_google_service.dart';

class VoiceCommandWidget extends StatefulWidget {
  const VoiceCommandWidget({super.key});
  @override
  State<VoiceCommandWidget> createState() => _VoiceCommandWidgetState();
}

class _VoiceCommandWidgetState extends State<VoiceCommandWidget> {
  String? _recognizedText;
  String? _response;
  bool _isLoading = false;

  Future<void> _startGoogleSpeech() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _recognizedText = null;
      _response = null;
    });
    try {
      final base64Audio = await recordAndGetBase64(seconds: 5);
      if (base64Audio != null) {
        final metin = await googleSpeechToText(base64Audio);
        if (!mounted) return;
        setState(() {
          _recognizedText = metin ?? 'Hiçbir şey algılanamadı!';
          _isLoading = false;
        });
        // Burada asistan yanıtı üretme fonksiyonunu çağırabilirsin
        // Örnek: _response = await getAIResponse(metin);
      } else {
        if (!mounted) return;
        setState(() {
          _recognizedText = 'Kayıt başarısız!';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _recognizedText = 'Bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _isLoading ? null : _startGoogleSpeech,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.mic, color: Colors.white, size: 36),
                        SizedBox(height: 4),
                        // Text('Konuş', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Google ile Sesli Komut',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 32),
          if (_recognizedText != null) ...[
            Text('Algılanan metin:', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            const SizedBox(height: 4),
            Text(_recognizedText!, style: const TextStyle(fontSize: 16)),
          ],
          if (_response != null) ...[
            const SizedBox(height: 16),
            Text('Yanıt:', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            const SizedBox(height: 4),
            Text(_response!, style: const TextStyle(fontSize: 16, color: Colors.blue)),
          ],
        ],
      ),
    );
  }
} 