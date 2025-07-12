import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import 'package:pet_app/features/pet/models/pet.dart';
import 'package:pet_app/features/pet/widgets/progress_indicator.dart';
import 'package:pet_app/features/pet/screens/vaccine_page.dart';
import 'package:pet_app/features/pet/screens/pet_form_page.dart';
import 'package:pet_app/providers/ai_provider.dart';
import 'package:pet_app/providers/pet_provider.dart';
import 'package:pet_app/services/notification_service.dart';

class PetDetailPage extends StatefulWidget {
  final Pet pet;

  const PetDetailPage({super.key, required this.pet});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  late Pet _pet;
  final FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
    _checkBirthday();
    // Doğum günü ise otomatik seslendir
    if (_pet.isBirthday) {
      Future.delayed(const Duration(milliseconds: 500), () {
        speak('Doğum günün kutlu olsun!');
      });
    }
  }

  void _checkBirthday() async {
    if (_pet.isBirthday) {
      final lastCheck = await NotificationService.getLastBirthdayCheck(_pet.name);
      final today = DateTime.now();
      
      if (lastCheck == null || 
          lastCheck.day != today.day || 
          lastCheck.month != today.month || 
          lastCheck.year != today.year) {
        await NotificationService.showBirthdayNotification(_pet.name);
        await NotificationService.saveLastBirthdayCheck(_pet.name, today);
      }
    }
  }

  void besle() {
    setState(() {
      _pet.hunger = (_pet.hunger > 0) ? _pet.hunger - 1 : 0;
    });
    context.read<PetProvider>().updatePetValues(_pet);
    speak('Afiyet olsun!');
  }

  void sev() {
    setState(() {
      _pet.happiness = (_pet.happiness < 10) ? _pet.happiness + 1 : 10;
    });
    context.read<PetProvider>().updatePetValues(_pet);
    speak('Sen harika bir dostsun!');
  }

  void dinlendir() {
    setState(() {
      _pet.energy = (_pet.energy < 10) ? _pet.energy + 1 : 10;
    });
    context.read<PetProvider>().updatePetValues(_pet);
    speak('İyi uykular!');
  }

  void bakim() {
    setState(() {
      _pet.care = (_pet.care < 10) ? _pet.care + 1 : 10;
    });
    context.read<PetProvider>().updatePetValues(_pet);
    speak('Bakım zamanı, aferin!');
  }

  Future<void> soruSorDialog() async {
    final controller = TextEditingController();
    final aiProvider = context.read<AIProvider>();
    
    // AI Provider'ı başlat
    await aiProvider.initializeVoiceService();
    
    return showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Yapay Zekaya Soru Sor'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tanınan metin gösterimi
                if (aiProvider.recognizedText != null && aiProvider.recognizedText!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 12),
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
                
                // Metin girişi
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Sorunuzu yazın veya sesli sorun...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  autofocus: true,
                ),
                
                const SizedBox(height: 12),
                
                // Sesli konuşma butonu
                Row(
                  children: [
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
                                setDialogState(() {});
                              },
                        icon: Icon(
                          aiProvider.isListening ? Icons.stop : Icons.mic,
                          color: aiProvider.isListening ? Colors.white : null,
                        ),
                        label: Text(
                          aiProvider.isListening ? 'Dinlemeyi Durdur' : 'Sesli Sor',
                          style: TextStyle(
                            color: aiProvider.isListening ? Colors.white : null,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: aiProvider.isListening ? Colors.red : null,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Yükleme göstergesi
                if (aiProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  aiProvider.stopVoiceInput();
                  Navigator.pop(context);
                },
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String question = controller.text.trim();
                  
                  // Eğer sesli tanınan metin varsa onu kullan
                  if (aiProvider.recognizedText != null && aiProvider.recognizedText!.isNotEmpty) {
                    question = aiProvider.recognizedText!;
                  }
                  
                  if (question.isNotEmpty) {
                    aiProvider.stopVoiceInput();
                    Navigator.pop(context);
                    await aiProvider.getSuggestion(question);
                  }
                },
                child: const Text('Sor'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_pet.name} Detayları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PetFormPage(pet: _pet),
                ),
              );
              if (result != null) {
                setState(() {
                  _pet = result;
                });
                context.read<PetProvider>().updatePetValues(_pet);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Doğum günü mesajı
              if (_pet.isBirthday)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pink, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.cake, color: Colors.white, size: 32),
                      SizedBox(height: 8),
                      Text(
                        '🎉 Doğum Günün Kutlu Olsun! 🎉',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (_pet.imagePath != null)
                Image.file(
                  File(_pet.imagePath!),
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 10),
              Text('Adı: ${_pet.name}'),
              Text('Cinsiyet: ${_pet.gender}'),
              Text('Doğum Tarihi: ${_pet.birthDate.day}.${_pet.birthDate.month}.${_pet.birthDate.year}'),
              Text('Yaş: ${_pet.age} yaşında'),
              const SizedBox(height: 10),
              StatusIndicator(icon: Icons.restaurant, value: _pet.hunger),
              StatusIndicator(icon: Icons.favorite, value: _pet.happiness),
              StatusIndicator(icon: Icons.battery_charging_full, value: _pet.energy),
              StatusIndicator(icon: Icons.healing, value: _pet.care),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(onPressed: besle, child: const Text('Besle')),
                  ElevatedButton(onPressed: sev, child: const Text('Sev')),
                  ElevatedButton(onPressed: dinlendir, child: const Text('Dinlendir')),
                  ElevatedButton(onPressed: bakim, child: const Text('Bakım')),
                  ElevatedButton.icon(
                    onPressed: () => context.read<AIProvider>().getMamaOnerisi(_pet.name, _pet.type),
                    icon: const Icon(Icons.restaurant),
                    label: const Text('Mama Önerisi'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.read<AIProvider>().getOyunOnerisi(_pet.name, _pet.type),
                    icon: const Icon(Icons.sports_esports),
                    label: const Text('Oyun Önerisi'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.read<AIProvider>().getBakimOnerisi(_pet.name, _pet.type),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Bakım Önerisi'),
                  ),
                  ElevatedButton.icon(
                    onPressed: soruSorDialog,
                    icon: const Icon(Icons.question_answer),
                    label: const Text('Soru Sor'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Consumer<AIProvider>(
                builder: (context, aiProvider, child) {
                  if (aiProvider.isLoading) {
                    return const CircularProgressIndicator();
                  } else if (aiProvider.currentResponse != null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade100,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.psychology,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'AI Yanıtı',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              const Spacer(),
                              // Sesli okuma durumu göstergesi
                              if (aiProvider.isSpeaking)
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Sesli okuyor...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            aiProvider.currentResponse!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Sesli okuma kontrol butonları
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: aiProvider.isSpeaking
                                      ? () => aiProvider.stopSpeaking()
                                      : () async {
                                          print('🎤 PetDetailPage: Sesli Dinle butonuna basıldı');
                                          print('🎤 Mevcut yanıt: ${aiProvider.currentResponse}');
                                          if (aiProvider.currentResponse != null && aiProvider.currentResponse!.isNotEmpty) {
                                            await aiProvider.speakResponse(aiProvider.currentResponse);
                                          } else {
                                            print('❌ Boş yanıt, sesli okuma yapılamıyor');
                                          }
                                        },
                                  icon: Icon(
                                    aiProvider.isSpeaking ? Icons.stop : Icons.volume_up,
                                    size: 18,
                                  ),
                                  label: Text(
                                    aiProvider.isSpeaking ? 'Durdur' : 'Sesli Dinle',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: aiProvider.isSpeaking 
                                        ? Colors.red.shade100 
                                        : Colors.green.shade100,
                                    foregroundColor: aiProvider.isSpeaking 
                                        ? Colors.red.shade700 
                                        : Colors.green.shade700,
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => aiProvider.clearResponse(),
                                icon: const Icon(Icons.clear, size: 20),
                                tooltip: 'Temizle',
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.vaccines),
        label: const Text("Aşıları Görüntüle"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VaccinePage(vaccines: _pet.vaccines),
            ),
          );
        },
      ),
    );
  }
}
