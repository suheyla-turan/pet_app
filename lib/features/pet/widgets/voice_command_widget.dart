import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pet_app/services/realtime_service.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../screens/pet_detail_page.dart';
import '../../../providers/pet_provider.dart';

class VoiceCommandWidget extends StatefulWidget {
  const VoiceCommandWidget({super.key});
  @override
  State<VoiceCommandWidget> createState() => _VoiceCommandWidgetState();
}

class _VoiceCommandWidgetState extends State<VoiceCommandWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _command = '';
  final realtimeService = RealtimeService();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onError: (error) {
          if (error.errorMsg == 'error_speech_timeout') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Konuşma algılanamadı, lütfen tekrar deneyin.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sesli tanıma hatası: \\${error.errorMsg}')),
            );
          }
          setState(() => _isListening = false);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            setState(() {
              _command = val.recognizedWords;
            });
            if (val.hasConfidenceRating && val.confidence > 0) {
              _speech.stop();
              setState(() => _isListening = false);
              await handleVoiceCommand(context, _command);
            }
          },
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Komut: $_command'),
        IconButton(
          icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
          onPressed: _listen,
        ),
      ],
    );
  }

  Future<void> handleVoiceCommand(BuildContext context, String command) async {
    final intentData = await getIntentFromAI(command);
    final petProvider = context.read<PetProvider>();
    Pet? pet;
    // intentData['petId'] ile PetProvider'dan bul
    if (intentData['petId'] != null) {
      try {
        pet = petProvider.pets.firstWhere(
          (p) => p.id == intentData['petId'] || p.name == intentData['petId'],
        );
      } catch (e) {
        pet = null;
      }
    }
    switch (intentData['intent']) {
      case 'feed':
        if (pet != null) {
          await realtimeService.setFeedingTime(pet.id ?? pet.name, DateTime.now());
          await realtimeService.updatePetStatus(pet.id ?? pet.name, satiety: 100);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pet.name} beslendi!')),
          );
        }
        break;
      case 'sleep':
        if (pet != null) {
          await realtimeService.updatePetStatus(pet.id ?? pet.name, energy: 100);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pet.name} uyutuldu!')),
          );
        }
        break;
      case 'care':
        if (pet != null) {
          await realtimeService.updatePetStatus(pet.id ?? pet.name, happiness: 100);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pet.name} bakımı yapıldı!')),
          );
        }
        break;
      case 'go_to_profile':
        if (pet != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PetDetailPage(pet: pet!),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hayvan bulunamadı!')),
          );
        }
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Komut anlaşılamadı: $command')),
        );
        break;
    }
  }
} 