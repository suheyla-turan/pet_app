import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

import 'package:pet_app/features/pet/models/pet.dart';
import 'package:pet_app/features/pet/models/vaccine.dart';
import 'package:pet_app/features/pet/widgets/progress_indicator.dart';
import 'package:pet_app/features/pet/screens/vaccine_page.dart';
import 'package:pet_app/features/pet/screens/pet_form_page.dart';
import 'package:pet_app/services/gemini_service.dart';
import 'package:pet_app/services/notification_service.dart';


class PetDetailPage extends StatefulWidget {
  final Pet pet;

  const PetDetailPage({super.key, required this.pet});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  String? aiResponse;
  bool isLoading = false;
  Timer? _timer;
  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
    _checkBirthday();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _pet.updateValues();
      });
      _checkLowValues();
    });
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

  void _checkLowValues() {
    if (_pet.hunger >= 8) {
      NotificationService.showLowValueNotification(_pet.name, 'açlık');
    }
    if (_pet.happiness <= 2) {
      NotificationService.showLowValueNotification(_pet.name, 'mutluluk');
    }
    if (_pet.energy <= 2) {
      NotificationService.showLowValueNotification(_pet.name, 'enerji');
    }
    if (_pet.care <= 2) {
      NotificationService.showLowValueNotification(_pet.name, 'bakım');
    }
  }

  void besle() {
    setState(() {
      _pet.hunger = (_pet.hunger > 0) ? _pet.hunger - 1 : 0;
    });
  }

  void sev() {
    setState(() {
      _pet.happiness = (_pet.happiness < 10) ? _pet.happiness + 1 : 10;
    });
  }

  void dinlendir() {
    setState(() {
      _pet.energy = (_pet.energy < 10) ? _pet.energy + 1 : 10;
    });
  }

  void bakim() {
    setState(() {
      _pet.care = (_pet.care < 10) ? _pet.care + 1 : 10;
    });
  }

  Future<void> aiOneriGetir() async {
    setState(() {
      isLoading = true;
    });

    final suggestion = await GeminiService.getSuggestion(
        '${_pet.name} adlı ${_pet.type} türündeki evcil hayvan için bakım önerisi verir misin?');

    setState(() {
      aiResponse = suggestion;
      isLoading = false;
    });
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
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              children: [
                ElevatedButton(onPressed: besle, child: const Text('Besle')),
                ElevatedButton(onPressed: sev, child: const Text('Sev')),
                ElevatedButton(onPressed: dinlendir, child: const Text('Dinlendir')),
                ElevatedButton(onPressed: bakim, child: const Text('Bakım')),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: aiOneriGetir,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI Bakım Önerisi'),
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const CircularProgressIndicator()
            else if (aiResponse != null)
              Text(
                aiResponse!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
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
