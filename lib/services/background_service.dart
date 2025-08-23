import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notification_service.dart';

class BackgroundService {
  static const String _taskName = 'petValuesUpdate';
  static const String _periodicTaskName = 'periodicPetCheck';
  
  /// Background service'i başlat
  static Future<void> initialize() async {
    // Periyodik görev başlat (15 dakikada bir)
    await Workmanager().registerPeriodicTask(
      _periodicTaskName,
      _periodicTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  /// Manuel olarak background task başlat
  static Future<void> startBackgroundTask() async {
    await Workmanager().registerOneOffTask(
      _taskName,
      _taskName,
      initialDelay: const Duration(minutes: 1),
    );
  }

  /// Background task'ı durdur
  static Future<void> stop() async {
    await Workmanager().cancelAll();
  }
}

/// Background callback fonksiyonu
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Firebase.initializeApp();
      
      switch (task) {
        case 'petValuesUpdate':
          await _updatePetValues();
          break;
        case 'periodicPetCheck':
          await _periodicPetCheck();
          break;
      }
      return true;
    } catch (e) {
      print('Background task error: $e');
      return false;
    }
  });
}

/// Evcil hayvan değerlerini güncelle
@pragma('vm:entry-point')
Future<void> _updatePetValues() async {
  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) return;

    final firestore = FirebaseFirestore.instance;
    final petsSnapshot = await firestore
        .collection('pets')
        .where('owners', arrayContains: auth.currentUser!.uid)
        .get();

    for (final doc in petsSnapshot.docs) {
      final petData = doc.data();
      final lastUpdate = DateTime.parse(petData['lastUpdate']);
      final now = DateTime.now();
      final difference = now.difference(lastUpdate).inMinutes;

      // Değerleri güncelle
      int satiety = petData['satiety'] ?? 5;
      int happiness = petData['happiness'] ?? 5;
      int energy = petData['energy'] ?? 5;
      int care = petData['care'] ?? 5;

      final satietyInterval = petData['satietyInterval'] ?? 60;
      final happinessInterval = petData['happinessInterval'] ?? 60;
      final energyInterval = petData['energyInterval'] ?? 60;
      final careInterval = petData['careInterval'] ?? 1440;

      bool valuesChanged = false;

      if (difference >= satietyInterval) {
        satiety = (satiety - 1).clamp(0, 10);
        valuesChanged = true;
      }
      if (difference >= happinessInterval) {
        happiness = (happiness - 1).clamp(0, 10);
        valuesChanged = true;
      }
      if (difference >= energyInterval) {
        energy = (energy - 1).clamp(0, 10);
        valuesChanged = true;
      }
      if (difference >= careInterval) {
        care = (care - 1).clamp(0, 10);
        valuesChanged = true;
      }

      if (valuesChanged) {
        // Firestore'da güncelle
        await doc.reference.update({
          'satiety': satiety,
          'happiness': happiness,
          'energy': energy,
          'care': care,
          'lastUpdate': now.toIso8601String(),
        });

        // Kritik değer kontrolü ve bildirim
        final petName = petData['name'] ?? 'Evcil Hayvan';
        
        if (satiety <= 2) {
          await NotificationService.showCriticalStatusNotification(
            petName, 'tokluk', customSound: 'critical_alert'
          );
        } else if (satiety <= 4) {
          await NotificationService.showLowValueNotification(
            petName, 'tokluk'
          );
        }

        if (happiness <= 2) {
          await NotificationService.showCriticalStatusNotification(
            petName, 'mutluluk', customSound: 'critical_alert'
          );
        } else if (happiness <= 4) {
          await NotificationService.showLowValueNotification(
            petName, 'mutluluk'
          );
        }

        if (energy <= 2) {
          await NotificationService.showCriticalStatusNotification(
            petName, 'enerji', customSound: 'critical_alert'
          );
        } else if (energy <= 4) {
          await NotificationService.showLowValueNotification(
            petName, 'enerji'
          );
        }

        if (care <= 2) {
          await NotificationService.showCriticalStatusNotification(
            petName, 'bakım', customSound: 'critical_alert'
          );
        } else if (care <= 4) {
          await NotificationService.showLowValueNotification(
            petName, 'bakım'
          );
        }
      }
    }
  } catch (e) {
    print('Error updating pet values: $e');
  }
}

/// Periyodik kontrol
@pragma('vm:entry-point')
Future<void> _periodicPetCheck() async {
  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) return;

    final firestore = FirebaseFirestore.instance;
    final petsSnapshot = await firestore
        .collection('pets')
        .where('owners', arrayContains: auth.currentUser!.uid)
        .get();

    for (final doc in petsSnapshot.docs) {
      final petData = doc.data();
      final now = DateTime.now();
      
      // Doğum günü kontrolü
      final birthDate = DateTime.parse(petData['birthDate']);
      if (now.month == birthDate.month && now.day == birthDate.day) {
        final lastCheck = await NotificationService.getLastBirthdayCheck(doc.id);
        if (lastCheck == null || lastCheck.day != now.day) {
          await NotificationService.showBirthdayNotification(
            petData['name'] ?? 'Evcil Hayvan'
          );
          await NotificationService.saveLastBirthdayCheck(doc.id, now);
        }
      }

      // Aşı kontrolü
      final vaccines = petData['vaccines'] as List? ?? [];
      for (final vaccine in vaccines) {
        final vaccineDate = DateTime.parse(vaccine['date']);
        final daysUntilDue = vaccineDate.difference(now).inDays;
        
        if (daysUntilDue <= 7 && daysUntilDue > 0) {
          final lastCheck = await NotificationService.getLastVaccineCheck('${doc.id}_${vaccine['name']}');
          if (lastCheck == null || lastCheck.day != now.day) {
            await NotificationService.showVaccineDueNotification(
              petData['name'] ?? 'Evcil Hayvan',
              vaccine['name'] ?? 'Aşı'
            );
            await NotificationService.saveLastVaccineCheck('${doc.id}_${vaccine['name']}', now);
          }
        }
      }
    }
  } catch (e) {
    print('Error in periodic pet check: $e');
  }
}
