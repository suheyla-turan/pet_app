import 'package:flutter/foundation.dart';
import 'dart:async';
import '../features/pet/models/pet.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/settings_provider.dart';
import '../services/realtime_service.dart';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];
  bool _isLoading = false;
  Timer? _timer;
  SettingsProvider? _settingsProvider;
  final RealtimeService _realtimeService = RealtimeService();

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;

  PetProvider() {
    _startTimer();
  }

  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
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
        'satiety': pet.satiety,
        'happiness': pet.happiness,
        'energy': pet.energy,
        'care': pet.care,
      };
      
      pet.updateValues();
      
      if (oldValues['satiety'] != pet.satiety ||
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
      if (pet.satiety <= 2) {
        NotificationService.showLowValueNotification(
          pet.name, 
          'tokluk',
          customSound: _settingsProvider?.notificationSound,
        );
      }
      if (pet.happiness <= 2) {
        NotificationService.showLowValueNotification(
          pet.name, 
          'mutluluk',
          customSound: _settingsProvider?.notificationSound,
        );
      }
      if (pet.energy <= 2) {
        NotificationService.showLowValueNotification(
          pet.name, 
          'enerji',
          customSound: _settingsProvider?.notificationSound,
        );
      }
      if (pet.care <= 2) {
        NotificationService.showLowValueNotification(
          pet.name, 
          'bakım',
          customSound: _settingsProvider?.notificationSound,
        );
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
            await NotificationService.showBirthdayNotification(
              pet.name,
              customSound: _settingsProvider?.notificationSound,
            );
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
      await loadPets(); // Sadece Firestore'dan güncel listeyi çek
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

  Future<void> setPetFeedingTime(String petId, DateTime feedingTime) async {
    await _realtimeService.setFeedingTime(petId, feedingTime);
    // Her gün o saatte bildirim planla
    await NotificationService.scheduleNotification(
      id: petId.hashCode,
      title: '🐾 Beslenme Zamanı',
      body: '$petId için beslenme zamanı geldi!',
      scheduledTime: feedingTime,
    );
    notifyListeners();
  }

  Future<DateTime?> getPetFeedingTime(String petId) async {
    return await _realtimeService.getFeedingTime(petId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 