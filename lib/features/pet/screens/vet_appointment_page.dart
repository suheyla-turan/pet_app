import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:pati_takip/features/pet/models/pet.dart';
import 'package:pati_takip/providers/pet_provider.dart';
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
    // Mevcut randevu varsa yükle
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
        const SnackBar(
          content: Text('Lütfen tarih ve saat seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Randevu tarihini oluştur
      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Pet'i güncelle
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

      // Firestore'da güncelle
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

      // Provider'ı güncelle
      if (mounted) {
        context.read<PetProvider>().updatePet(widget.pet.name, updatedPet);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.pet.name} için veteriner randevusu kaydedildi'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata oluştu: $e'),
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
      // Pet'i güncelle
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

      // Firestore'da güncelle
      if (widget.pet.id != null) {
        await FirestoreService.hayvanGuncelle(widget.pet.id!, updatedPet);
      }

      // Bildirimleri iptal et
      if (widget.pet.id != null) {
        await NotificationService.cancelVetAppointmentNotifications(widget.pet.id!);
      }

      // Provider'ı güncelle
      if (mounted) {
        context.read<PetProvider>().updatePet(widget.pet.name, updatedPet);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.pet.name} için veteriner randevusu iptal edildi'),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata oluştu: $e'),
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
    final localizations = AppLocalizations.of(context);
    final hasAppointment = widget.pet.vetAppointment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pet.name} - Veteriner Randevusu'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F1419),
              const Color(0xFF1A202C), 
              const Color(0xFF2D3748),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mevcut randevu bilgisi
                if (hasAppointment) ...[
                  Card(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF8B5CF6),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Mevcut Randevu',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF8B5CF6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'tr_TR').format(widget.pet.vetAppointment!),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            DateFormat('HH:mm').format(widget.pet.vetAppointment!),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Tarih seçici
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: Color(0xFF8B5CF6)),
                    title: Text(_selectedDate != null 
                      ? DateFormat('EEEE, d MMMM yyyy', 'tr_TR').format(_selectedDate!)
                      : 'Tarih Seçin'),
                    subtitle: const Text('Randevu tarihi'),
                    onTap: () => _selectDate(context),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ),

                const SizedBox(height: 16),

                // Saat seçici
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time, color: Color(0xFF8B5CF6)),
                    title: Text(_selectedTime != null 
                      ? _selectedTime!.format(context)
                      : 'Saat Seçin'),
                    subtitle: const Text('Randevu saati'),
                    onTap: () => _selectTime(context),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ),

                const SizedBox(height: 16),

                // Notlar
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notlar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Randevu ile ilgili notlar...',
                            border: OutlineInputBorder(),
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
                    label: const Text('Randevuyu İptal Et'),
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
                  label: Text(hasAppointment ? 'Randevuyu Güncelle' : 'Randevu Kaydet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                
                // Alt navigasyon çubuğu için ekstra boşluk
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
