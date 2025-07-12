class Vaccine {
  final String name;
  final DateTime date;

  Vaccine({
    required this.name,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
    };
  }

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      name: json['name'],
      date: DateTime.parse(json['date']),
    );
  }
}
