import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import 'package:pati_takip/services/notification_service.dart';
import 'package:pati_takip/l10n/app_localizations.dart';
import '../../../providers/theme_provider.dart';
import 'package:flutter/services.dart';

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
          body: '${vaccine.name} aşı zamanı geldi!',
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
        title: Text(
          widget.showDone ? AppLocalizations.of(context)!.doneVaccineAdd : AppLocalizations.of(context)!.vaccineAdd,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.vaccineName,
                labelStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                ),
              ),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              ),
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
              child: Text(
                AppLocalizations.of(context)!.selectDate,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty && selectedDate != null) {
                _addVaccine(name, selectedDate!);
                Navigator.pop(context);
              }
            },
            child: Text(
              AppLocalizations.of(context)!.add,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrelenmiş listeyi göster
    List<Vaccine> filteredVaccines = widget.vaccines.where((v) => v.isDone == widget.showDone).toList();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, widget.vaccines); // Geri tuşuna basınca güncel listeyi döndür
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
            statusBarBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.dark : Brightness.light,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, widget.vaccines),
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
          title: Text(
            widget.showDone ? AppLocalizations.of(context)!.completedVaccines : AppLocalizations.of(context)!.vaccinesToBeTaken,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.white.withOpacity(0.9),
          elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 2,
          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: Provider.of<ThemeProvider>(context).getBackgroundGradient(
              Theme.of(context).brightness == Brightness.dark
            ),
          ),
          child: Column(
            children: [
              // Content
              Expanded(
                child: filteredVaccines.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.vaccines_outlined,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                                                 widget.showDone ? AppLocalizations.of(context)!.completedVaccines : AppLocalizations.of(context)!.vaccinesToBeTaken,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredVaccines.length,
                        itemBuilder: (context, index) {
                          final vaccine = filteredVaccines[index];
                          return ListTile(
                            leading: Icon(widget.showDone ? Icons.check : Icons.vaccines, color: widget.showDone ? Colors.green : Colors.orange),
                            title: Text(
                              vaccine.name,
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              AppLocalizations.of(context)!.date(vaccine.date.toString()),
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.black87,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!widget.showDone)
                                  IconButton(
                                    icon: const Icon(Icons.check_circle, color: Colors.green),
                                                                         tooltip: AppLocalizations.of(context)!.markAsDone,
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
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
