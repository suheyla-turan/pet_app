import 'package:flutter/material.dart';
import '../models/pet.dart';
import 'package:pet_app/services/notification_service.dart';
import 'package:pet_app/l10n/app_localizations.dart';

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
          title: AppLocalizations.of(context)!.vaccineTime,
          body: '${vaccine.name} ${AppLocalizations.of(context)!.vaccineTime} geldi!',
          scheduledTime: vaccine.date,
        );
      }
    });
    // Sayfa kapanmasın, Navigator.pop kaldırıldı
  }

  void _showAddDialog() {
    String name = '';
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.showDone ? AppLocalizations.of(context)!.doneVaccineAdd : AppLocalizations.of(context)!.vaccineAdd),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.vaccineName),
              onChanged: (value) => name = value,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(widget.showDone ? Duration.zero : const Duration(days: 1)),
                  firstDate: widget.showDone ? DateTime(2000) : DateTime.now().add(const Duration(days: 1)),
                  lastDate: widget.showDone ? DateTime.now() : DateTime(2100),
                );
                if (picked != null) {
                  selectedDate = picked;
                }
              },
              child: Text(AppLocalizations.of(context)!.selectDate),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty && selectedDate != null) {
                _addVaccine(name, selectedDate!);
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrelenmiş listeyi göster
    List<Vaccine> filteredVaccines = widget.vaccines.where((v) => v.isDone == widget.showDone).toList();
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.vaccines); // Geri tuşuna basınca güncel listeyi döndür
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Patizeka'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, widget.vaccines); // AppBar geri butonunda da güncel listeyi döndür
            },
          ),
        ),
        body: filteredVaccines.isEmpty
            ? Center(child: Text(AppLocalizations.of(context)!.noVaccines(widget.showDone.toString())))
            : ListView.builder(
                itemCount: filteredVaccines.length,
                itemBuilder: (context, index) {
                  final vaccine = filteredVaccines[index];
                  return ListTile(
                    leading: Icon(widget.showDone ? Icons.check : Icons.vaccines, color: widget.showDone ? Colors.green : Colors.orange),
                    title: Text(vaccine.name),
                    subtitle: Text(AppLocalizations.of(context)!.date(vaccine.date.toString())),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!widget.showDone)
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            tooltip: 'Mark as Done',
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
      ),
    );
  }
}
