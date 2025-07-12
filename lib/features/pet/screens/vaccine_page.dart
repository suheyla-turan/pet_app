import 'package:flutter/material.dart';
import '../models/pet.dart';

class VaccinePage extends StatefulWidget {
  final List<Vaccine> vaccines;

  const VaccinePage({super.key, required this.vaccines});

  @override
  State<VaccinePage> createState() => _VaccinePageState();
}

class _VaccinePageState extends State<VaccinePage> {
  void _addVaccine(String name, DateTime date) {
    setState(() {
      widget.vaccines.add(Vaccine(name: name, date: date));
    });
  }

  void _showAddDialog() {
    String name = '';
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aşı Ekle'),
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
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
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
      appBar: AppBar(title: const Text('Aşı Takvimi')),
      body: widget.vaccines.isEmpty
          ? const Center(child: Text('Henüz aşı girilmedi.'))
          : ListView.builder(
              itemCount: widget.vaccines.length,
              itemBuilder: (context, index) {
                final vaccine = widget.vaccines[index];
                return ListTile(
                  leading: const Icon(Icons.vaccines),
                  title: Text(vaccine.name),
                  subtitle: Text('Tarih: ${vaccine.date.toLocal().toString().split(' ')[0]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        widget.vaccines.removeAt(index);
                      });
                    },
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
