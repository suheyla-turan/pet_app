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
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yapay Zekaya Soru Sor'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Sorunuzu yazın...'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Sor')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      await context.read<AIProvider>().getSuggestion(result);
    }
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
                    return Text(
                      aiProvider.currentResponse!,
                      style: const TextStyle(fontStyle: FontStyle.italic),
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
