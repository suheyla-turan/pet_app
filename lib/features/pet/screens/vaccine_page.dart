import 'package:flutter/material.dart';
import '../models/pet.dart';
import 'package:pet_app/services/notification_service.dart';

class VaccinePage extends StatefulWidget {
  final List<Vaccine> vaccines;
  final bool showDone; // true: yapılmış, false: yapılacak

  const VaccinePage({super.key, required this.vaccines, required this.showDone});

  @override
  State<VaccinePage> createState() => _VaccinePageState();
}

class _VaccinePageState extends State<VaccinePage> {
  void _addVaccine(String name, DateTime date) {
    setState(() {
      final vaccine = Vaccine(name: name, date: date, isDone: widget.showDone);
      widget.vaccines.add(vaccine);
      // Eğer yapılacak ve tarihi bugünden sonraysa bildirim planla
      if (!vaccine.isDone && vaccine.date.isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          id: vaccine.name.hashCode ^ vaccine.date.hashCode,
          title: 'Aşı Zamanı',
          body: '${vaccine.name} aşısı için randevu zamanı geldi!',
          scheduledTime: vaccine.date,
        );
      }
    });
  }

  void _showAddDialog() {
    String name = '';
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.showDone ? 'Yapılmış Aşı Ekle' : 'Yapılacak Aşı Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Aşı Adı'),
              onChanged: (value) => name = value,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(widget.showDone ? Duration.zero : const Duration(days: 1)),
                  firstDate: widget.showDone ? DateTime(2000) : DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  selectedDate = picked;
                }
              },
              child: const Text('Tarih Seç'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty && selectedDate != null) {
                _addVaccine(name, selectedDate!);
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.showDone ? 'Yapılmış Aşılar' : 'Yapılacak Aşılar')),
      body: widget.vaccines.isEmpty
          ? Center(child: Text(widget.showDone ? 'Henüz yapılmış aşı yok.' : 'Henüz yapılacak aşı yok.'))
          : ListView.builder(
              itemCount: widget.vaccines.length,
              itemBuilder: (context, index) {
                final vaccine = widget.vaccines[index];
                return ListTile(
                  leading: Icon(widget.showDone ? Icons.check : Icons.vaccines, color: widget.showDone ? Colors.green : Colors.orange),
                  title: Text(vaccine.name),
                  subtitle: Text('Tarih: ${vaccine.date.toLocal().toString().split(' ')[0]}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!widget.showDone)
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          tooltip: 'Yapıldı olarak işaretle',
                          onPressed: () async {
                            setState(() {
                              vaccine.isDone = true;
                            });
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            widget.vaccines.remove(vaccine);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
