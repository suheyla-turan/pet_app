import 'package:flutter/foundation.dart';
import 'dart:async';
import '../features/pet/models/pet.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];
  bool _isLoading = false;
  Timer? _timer;

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;

  PetProvider() {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updatePetValues();
      _checkLowValues();
    });
  }

  void _updatePetValues() {
    bool hasChanges = false;
    for (final pet in _pets) {
      final oldValues = {
        'hunger': pet.hunger,
        'happiness': pet.happiness,
        'energy': pet.energy,
        'care': pet.care,
      };
      
      pet.updateValues();
      
      if (oldValues['hunger'] != pet.hunger ||
          oldValues['happiness'] != pet.happiness ||
          oldValues['energy'] != pet.energy ||
          oldValues['care'] != pet.care) {
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      notifyListeners();
    }
  }

  void _checkLowValues() {
    for (final pet in _pets) {
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

  Future<void> loadPets() async {
    _setLoading(true);
    
    try {
      final loadedPets = await FirestoreService.hayvanlariGetir();
      _pets = loadedPets;
      
      // Doğum günü kontrolü
      for (final pet in _pets) {
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
    } catch (e) {
      print('❌ HATA - Hayvanlar yüklenemedi: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addPet(Pet pet) async {
    try {
      await FirestoreService.hayvanEkle(pet);
      _pets.add(pet);
      notifyListeners();
    } catch (e) {
      print('❌ HATA - Hayvan eklenemedi: $e');
      rethrow;
    }
  }

  Future<void> updatePet(String oldName, Pet updatedPet) async {
    try {
      // Firestore'da isim ile arama yap
      final querySnapshot = await FirebaseFirestore.instance
          .collection('hayvanlar')
          .where('name', isEqualTo: oldName)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await FirestoreService.hayvanGuncelle(docId, updatedPet);
        
        // Local listeyi güncelle
        final index = _pets.indexWhere((p) => p.name == oldName);
        if (index != -1) {
          _pets[index] = updatedPet;
          notifyListeners();
        }
      }
    } catch (e) {
      print('❌ HATA - Hayvan güncellenemedi: $e');
      rethrow;
    }
  }

  Future<void> removePet(String petName) async {
    try {
      // Firestore'da isim ile arama yap
      final querySnapshot = await FirebaseFirestore.instance
          .collection('hayvanlar')
          .where('name', isEqualTo: petName)
          .get();
      
      for (var doc in querySnapshot.docs) {
        await FirestoreService.hayvanSil(doc.id);
      }
      
      _pets.removeWhere((pet) => pet.name == petName);
      notifyListeners();
    } catch (e) {
      print('❌ HATA - Hayvan silinemedi: $e');
      rethrow;
    }
  }

  void updatePetValues(Pet pet) {
    final index = _pets.indexWhere((p) => p.name == pet.name);
    if (index != -1) {
      _pets[index] = pet;
      notifyListeners();
    }
  }

  Pet? getPetByName(String name) {
    try {
      return _pets.firstWhere((pet) => pet.name == name);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 