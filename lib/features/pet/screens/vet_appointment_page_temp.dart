import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:pati_takip/features/pet/models/pet.dart';
import 'package:pati_takip/providers/pet_provider.dart';
import 'package:pati_takip/providers/theme_provider.dart';
import 'package:pati_takip/services/notification_service.dart';
import 'package:pati_takip/services/firestore_service.dart';
import 'package:pati_takip/l10n/app_localizations.dart';

class VetAppointmentPage extends StatefulWidget {
  final Pet pet;

  const VetAppointmentPage({super.key, required this.pet});

  @override
  State<VetAppointmentPage> createState() => _VetAppointmentPageState();
}

class _VetAppointmentPageState extends State<VetAppointmentPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mevcut randevu varsa yÃ¼kle
    if (widget.pet.vetAppointment != null) {
      _selectedDate = widget.pet.vetAppointment;
      _selectedTime = TimeOfDay.fromDateTime(widget.pet.vetAppointment!);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectDateAndTime),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Randevu tarihini oluÅŸtur
      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Pet'i gÃ¼ncelle
      final updatedPet = Pet(
        name: widget.pet.name,
        gender: widget.pet.gender,
        birthDate: widget.pet.birthDate,
        satiety: widget.pet.satiety,
        happiness: widget.pet.happiness,
        energy: widget.pet.energy,
        care: widget.pet.care,
        satietyInterval: widget.pet.satietyInterval,
        happinessInterval: widget.pet.happinessInterval,
        energyInterval: widget.pet.energyInterval,
        careInterval: widget.pet.careInterval,
        vaccines: widget.pet.vaccines,
        type: widget.pet.type,
        breed: widget.pet.breed,
        imagePath: widget.pet.imagePath,
        lastUpdate: widget.pet.lastUpdate,
        owners: widget.pet.owners,
        id: widget.pet.id,
        creator: widget.pet.creator,
        vetAppointment: appointmentDateTime,
      );

      // Firestore'da gÃ¼ncelle
      if (widget.pet.id != null) {
        await FirestoreService.hayvanGuncelle(widget.pet.id!, updatedPet);
      }

      // Bildirimleri zamanla
      if (widget.pet.id != null) {
        await NotificationService.scheduleVetAppointmentNotifications(
          widget.pet.id!,
          widget.pet.name,
          appointmentDateTime,
        );
      }

      // Provider'Ä± gÃ¼ncelle
      if (mounted) {
        context.read<PetProvider>().updatePet(widget.pet.name, updatedPet);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.appointmentSaved(widget.pet.name)),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorOccurred(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelAppointment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Pet'i gÃ¼ncelle
      final updatedPet = Pet(
        name: widget.pet.name,
        gender: widget.pet.gender,
        birthDate: widget.pet.birthDate,
        satiety: widget.pet.satiety,
        happiness: widget.pet.happiness,
        energy: widget.pet.energy,
        care: widget.pet.care,
        satietyInterval: widget.pet.satietyInterval,
        happinessInterval: widget.pet.happinessInterval,
        energyInterval: widget.pet.energyInterval,
        careInterval: widget.pet.careInterval,
        vaccines: widget.pet.vaccines,
        type: widget.pet.type,
        breed: widget.pet.breed,
        imagePath: widget.pet.imagePath,
        lastUpdate: widget.pet.lastUpdate,
        owners: widget.pet.owners,
        id: widget.pet.id,
        creator: widget.pet.creator,
        vetAppointment: null,
      );

      // Firestore'da gÃ¼ncelle
      if (widget.pet.id != null) {
        await FirestoreService.hayvanGuncelle(widget.pet.id!, updatedPet);
      }

      // Bildirimleri iptal et
      if (widget.pet.id != null) {
        await NotificationService.cancelVetAppointmentNotifications(widget.pet.id!);
      }

      // Provider'Ä± gÃ¼ncelle
      if (mounted) {
        context.read<PetProvider>().updatePet(widget.pet.name, updatedPet);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.appointmentCancelled(widget.pet.name)),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorOccurred(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAppointment = widget.pet.vetAppointment != null;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      color: themeProvider.getPrimaryTextColor(isDark),
                    ),
                    Expanded(
                      child: Text(
                        '${widget.pet.name} - ${AppLocalizations.of(context)!.vetAppointmentTitle}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: themeProvider.getPrimaryTextColor(isDark),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Mevcut randevu bilgisi
                      if (hasAppointment) ...[
                        Card(
                          color: themeProvider.getReadableCardBackgroundColor(isDark),
                          shadowColor: themeProvider.getShadowColor(isDark),
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.existingAppointment,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy', 'tr_TR').format(widget.pet.vetAppointment!),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: themeProvider.getPrimaryTextColor(isDark),
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm').format(widget.pet.vetAppointment!),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: themeProvider.getSecondaryTextColor(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Tarih seÃ§ici
                      Card(
                        color: themeProvider.getReadableCardBackgroundColor(isDark),
                        shadowColor: themeProvider.getShadowColor(isDark),
                        elevation: 8,
                        child: ListTile(
                          leading: Icon(
                            Icons.calendar_today, 
                            color: Theme.of(context).colorScheme.primary
                          ),
                          title: Text(
                            _selectedDate != null 
                              ? DateFormat('EEEE, d MMMM yyyy', 'tr_TR').format(_selectedDate!)
                              : AppLocalizations.of(context)!.selectDate,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.getPrimaryTextColor(isDark),
                            ),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.appointmentDate,
                            style: TextStyle(
                              color: themeProvider.getSecondaryTextColor(isDark),
                              fontSize: 14,
                            ),
                          ),
                          onTap: () => _selectDate(context),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: themeProvider.getSecondaryTextColor(isDark),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Saat seÃ§ici
                      Card(
                        color: themeProvider.getReadableCardBackgroundColor(isDark),
                        shadowColor: themeProvider.getShadowColor(isDark),
                        elevation: 8,
                        child: ListTile(
                          leading: Icon(
                            Icons.access_time, 
                            color: Theme.of(context).colorScheme.primary
                          ),
                          title: Text(
                            _selectedTime != null 
                              ? _selectedTime!.format(context)
                              : AppLocalizations.of(context)!.selectTime,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.getPrimaryTextColor(isDark),
                            ),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.appointmentTime,
                            style: TextStyle(
                              color: themeProvider.getSecondaryTextColor(isDark),
                              fontSize: 14,
                            ),
                          ),
                          onTap: () => _selectTime(context),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: themeProvider.getSecondaryTextColor(isDark),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Notlar
                      Card(
                        color: themeProvider.getReadableCardBackgroundColor(isDark),
                        shadowColor: themeProvider.getShadowColor(isDark),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.notes,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.getPrimaryTextColor(isDark),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _notesController,
                                maxLines: 3,
                                style: TextStyle(
                                  color: themeProvider.getPrimaryTextColor(isDark),
                                ),
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.appointmentNotesHint,
                                  hintStyle: TextStyle(
                                    color: themeProvider.getSecondaryTextColor(isDark),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  filled: true,
                                  fillColor: isDark 
                                    ? Colors.grey.shade800 
                                    : Colors.grey.shade50,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Butonlar
                      if (hasAppointment) ...[
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _cancelAppointment,
                          icon: const Icon(Icons.cancel),
                          label: Text(AppLocalizations.of(context)!.cancelAppointment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveAppointment,
                        icon: Icon(hasAppointment ? Icons.edit : Icons.save),
                        label: Text(hasAppointment ? AppLocalizations.of(context)!.updateAppointment : AppLocalizations.of(context)!.saveAppointment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      
                      // Alt navigasyon Ã§ubuÄŸu iÃ§in ekstra boÅŸluk
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
