class Vaccine {
  String name;
  DateTime date;

  Vaccine({required this.name, required this.date});
}

class Pet {
  String name;
  String gender;
  DateTime birthDate;
  int hunger;
  int happiness;
  int energy;
  int care;
  int hungerInterval;
  int happinessInterval;
  int energyInterval;
  int careInterval;
  List<Vaccine> vaccines;
  String type;
  String? imagePath;
  DateTime lastUpdate;
  String? breed;

  Pet({
    required this.name,
    required this.gender,
    required this.birthDate,
    this.hunger = 5,
    this.happiness = 5,
    this.energy = 5,
    this.care = 5,
    this.hungerInterval = 60,
    this.happinessInterval = 60,
    this.energyInterval = 60,
    this.careInterval = 1440,
    List<Vaccine>? vaccines,
    this.type = 'Köpek',
    this.breed,
    this.imagePath,
    DateTime? lastUpdate,
  }) : 
    vaccines = vaccines ?? [],
    lastUpdate = lastUpdate ?? DateTime.now();

  int get age {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  bool get isBirthday {
    final now = DateTime.now();
    return now.month == birthDate.month && now.day == birthDate.day;
  }

  void updateValues() {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate).inMinutes;
    
    if (difference >= hungerInterval) {
      hunger = (hunger + 1).clamp(0, 10);
    }
    if (difference >= happinessInterval) {
      happiness = (happiness - 1).clamp(0, 10);
    }
    if (difference >= energyInterval) {
      energy = (energy - 1).clamp(0, 10);
    }
    if (difference >= careInterval) {
      care = (care - 1).clamp(0, 10);
    }
    
    lastUpdate = now;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'hunger': hunger,
      'happiness': happiness,
      'energy': energy,
      'care': care,
      'hungerInterval': hungerInterval,
      'happinessInterval': happinessInterval,
      'energyInterval': energyInterval,
      'careInterval': careInterval,
      'vaccines': vaccines.map((v) => {'name': v.name, 'date': v.date.toIso8601String()}).toList(),
      'type': type,
      'breed': breed,
      'imagePath': imagePath,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      name: map['name'],
      gender: map['gender'],
      birthDate: DateTime.parse(map['birthDate']),
      hunger: map['hunger'] ?? 5,
      happiness: map['happiness'] ?? 5,
      energy: map['energy'] ?? 5,
      care: map['care'] ?? 5,
      hungerInterval: map['hungerInterval'] ?? 60,
      happinessInterval: map['happinessInterval'] ?? 60,
      energyInterval: map['energyInterval'] ?? 60,
      careInterval: map['careInterval'] ?? 1440,
      vaccines: (map['vaccines'] as List?)?.map((v) => Vaccine(name: v['name'], date: DateTime.parse(v['date']))).toList() ?? [],
      type: map['type'] ?? 'Köpek',
      breed: map['breed'],
      imagePath: map['imagePath'],
      lastUpdate: map['lastUpdate'] != null ? DateTime.parse(map['lastUpdate']) : null,
    );
  }
}
