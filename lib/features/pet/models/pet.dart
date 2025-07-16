class Vaccine {
  String name;
  DateTime date;
  bool isDone;

  Vaccine({required this.name, required this.date, this.isDone = false});

  Map<String, dynamic> toMap() => {
    'name': name,
    'date': date.toIso8601String(),
    'isDone': isDone,
  };

  factory Vaccine.fromMap(Map map) => Vaccine(
    name: map['name'] ?? '',
    date: DateTime.parse(map['date']),
    isDone: map['isDone'] ?? false,
  );
}

class Pet {
  String name;
  String gender;
  DateTime birthDate;
  int satiety; // tokluk
  int happiness;
  int energy;
  int care;
  int satietyInterval;
  int happinessInterval;
  int energyInterval;
  int careInterval;
  List<Vaccine> vaccines;
  String type;
  String? imagePath;
  DateTime lastUpdate;
  String? breed;
  List<String> owners;
  String? id;
  String? creator;

  Pet({
    required this.name,
    required this.gender,
    required this.birthDate,
    this.satiety = 5,
    this.happiness = 5,
    this.energy = 5,
    this.care = 5,
    this.satietyInterval = 60,
    this.happinessInterval = 60,
    this.energyInterval = 60,
    this.careInterval = 1440,
    List<Vaccine>? vaccines,
    this.type = 'Köpek',
    this.breed,
    this.imagePath,
    DateTime? lastUpdate,
    List<String>? owners,
    this.id,
    this.creator,
  }) : 
    vaccines = vaccines ?? [],
    lastUpdate = lastUpdate ?? DateTime.now(),
    owners = owners ?? [];

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
    
    if (difference >= satietyInterval) {
      satiety = (satiety - 1).clamp(0, 10); // Tokluk azalır
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
      'satiety': satiety,
      'happiness': happiness,
      'energy': energy,
      'care': care,
      'satietyInterval': satietyInterval,
      'happinessInterval': happinessInterval,
      'energyInterval': energyInterval,
      'careInterval': careInterval,
      'vaccines': vaccines.map((v) => v.toMap()).toList(),
      'type': type,
      'breed': breed,
      'imagePath': imagePath,
      'lastUpdate': lastUpdate.toIso8601String(),
      'owners': owners,
      if (id != null) 'id': id,
      if (creator != null) 'creator': creator,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      birthDate: DateTime.parse(map['birthDate']),
      satiety: map['satiety'] ?? 5,
      happiness: map['happiness'] ?? 5,
      energy: map['energy'] ?? 5,
      care: map['care'] ?? 5,
      satietyInterval: map['satietyInterval'] ?? 60,
      happinessInterval: map['happinessInterval'] ?? 60,
      energyInterval: map['energyInterval'] ?? 60,
      careInterval: map['careInterval'] ?? 1440,
      vaccines: (map['vaccines'] as List? ?? []).map((v) => Vaccine.fromMap(v)).toList(),
      type: map['type'] ?? 'Köpek',
      breed: map['breed'],
      imagePath: map['imagePath'],
      lastUpdate: map['lastUpdate'] != null ? DateTime.parse(map['lastUpdate']) : DateTime.now(),
      owners: (map['owners'] as List? ?? []).map((e) => e.toString()).toList(),
      id: map['id'],
      creator: map['creator'],
    );
  }
}
