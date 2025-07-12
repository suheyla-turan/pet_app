import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import '../models/pet.dart';
import 'pet_detail_page.dart';
import 'pet_form_page.dart';
import '../../../services/firestore_service.dart';
import '../../../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  List<Pet> pets = [];
  Timer? _timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPets() async {
    setState(() {
      isLoading = true;
    });
    
    final loadedPets = await FirestoreService.hayvanlariGetir();
    setState(() {
      pets = loadedPets;
      isLoading = false;
    });
    
    // Doğum günü kontrolü
    for (final pet in pets) {
      if (pet.isBirthday) {
        final lastCheck = await NotificationService.getLastBirthdayCheck(pet.name);
        final today = DateTime.now();
        
        if (lastCheck == null || 
            lastCheck.day != today.day || 
            lastCheck.month != today.month || 
            lastCheck.year != today.year) {
          await NotificationService.showBirthdayNotification(pet.name);
          await NotificationService.saveLastBirthdayCheck(pet.name, today);
        }
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        for (final pet in pets) {
          pet.updateValues();
        }
      });
      _checkLowValues();
    });
  }

  void _checkLowValues() {
    for (final pet in pets) {
      if (pet.hunger >= 8) {
        NotificationService.showLowValueNotification(pet.name, 'açlık');
      }
      if (pet.happiness <= 2) {
        NotificationService.showLowValueNotification(pet.name, 'mutluluk');
      }
      if (pet.energy <= 2) {
        NotificationService.showLowValueNotification(pet.name, 'enerji');
      }
      if (pet.care <= 2) {
        NotificationService.showLowValueNotification(pet.name, 'bakım');
      }
    }
  }

  void addPet(Pet pet) {
    setState(() {
      pets.add(pet);
    });
  }

  void removePet(int index) async {
    final pet = pets[index];
    // ID yoksa isim ile silmeyi dene
    try {
      if (pet.name.isNotEmpty) {
        // Firestore'da isim ile arama yap
        final querySnapshot = await FirebaseFirestore.instance
            .collection('hayvanlar')
            .where('name', isEqualTo: pet.name)
            .get();
        
        for (var doc in querySnapshot.docs) {
          await FirestoreService.hayvanSil(doc.id);
        }
      }
    } catch (e) {
      print('❌ HATA - Hayvan silinemedi: $e');
    }
    
    setState(() {
      pets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evcil Hayvanlarım'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPets,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pets.isEmpty
              ? const Center(child: Text('Henüz evcil hayvan eklemediniz.'))
              : ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: pet.imagePath != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(File(pet.imagePath!)), 
                                radius: 24,
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.teal.shade100,
                                child: const Icon(Icons.pets, color: Colors.teal),
                                radius: 24,
                              ),
                        title: Row(
                          children: [
                            Text(pet.name),
                            if (pet.isBirthday)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.cake, color: Colors.pink, size: 20),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tür: ${pet.type} | Yaş: ${pet.age}, Cinsiyet: ${pet.gender}'),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.restaurant, size: 16, color: pet.hunger > 7 ? Colors.red : Colors.green),
                                    Text(' ${pet.hunger}/10'),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.favorite, size: 16, color: pet.happiness < 3 ? Colors.red : Colors.green),
                                    Text(' ${pet.happiness}/10'),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.battery_charging_full, size: 16, color: pet.energy < 3 ? Colors.red : Colors.green),
                                    Text(' ${pet.energy}/10'),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.healing, size: 16, color: pet.care < 3 ? Colors.red : Colors.green),
                                    Text(' ${pet.care}/10'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removePet(index),
                        ),
                        onTap: () async {
                          final updatedPet = await Navigator.push<Pet>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PetDetailPage(pet: pet),
                            ),
                          );
                          if (updatedPet != null) {
                            setState(() {
                              pets[index] = updatedPet;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPet = await Navigator.push<Pet>(
            context,
            MaterialPageRoute(builder: (context) => const PetFormPage()),
          );
          if (newPet != null) {
            addPet(newPet);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
