import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'package:pet_app/features/pet/models/pet.dart';
import 'package:pet_app/services/firestore_service.dart';


class PetFormPage extends StatefulWidget {
  final Pet? pet;
  const PetFormPage({super.key, this.pet});

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  int _hunger = 5;
  int _happiness = 5;
  int _energy = 5;
  int _care = 5;
  int _hungerInterval = 60;
  int _happinessInterval = 60;
  int _energyInterval = 60;
  int _careInterval = 1440;
  String? _type;
  String? _imagePath;

  final List<String> _petTypes = [
    'Köpek', 'Kedi', 'Kuş', 'Balık', 'Hamster', 'Tavşan', 'Diğer'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _gender = widget.pet!.gender;
      _birthDate = widget.pet!.birthDate;
      _hunger = widget.pet!.hunger;
      _happiness = widget.pet!.happiness;
      _energy = widget.pet!.energy;
      _care = widget.pet!.care;
      _hungerInterval = widget.pet!.hungerInterval;
      _happinessInterval = widget.pet!.happinessInterval;
      _energyInterval = widget.pet!.energyInterval;
      _careInterval = widget.pet!.careInterval;
      _type = widget.pet!.type;
      _imagePath = widget.pet!.imagePath;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet == null ? 'Hayvan Ekle' : 'Bilgileri Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                    child: _imagePath == null ? const Icon(Icons.add_a_photo, size: 40, color: Colors.teal) : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Tür'),
                items: _petTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (value) => setState(() => _type = value),
                validator: (value) => value == null ? 'Tür seçiniz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'İsim'),
                validator: (value) => value == null || value.isEmpty ? 'İsim giriniz' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Cinsiyet'),
                items: const [
                  DropdownMenuItem(value: 'Dişi', child: Text('Dişi')),
                  DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                ],
                onChanged: (value) => setState(() => _gender = value),
                validator: (value) => value == null ? 'Cinsiyet seçiniz' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_birthDate == null
                    ? 'Doğum Tarihi Seçiniz'
                    : 'Doğum Tarihi: ${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birthDate ?? now,
                    firstDate: DateTime(now.year - 30),
                    lastDate: now,
                  );
                  if (picked != null) {
                    setState(() => _birthDate = picked);
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // Süre Ayarları
              const Text('Süre Ayarları (Dakika)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Açlık Süresi:'),
                        Slider(
                          value: _hungerInterval.toDouble(),
                          min: 10,
                          max: 300,
                          divisions: 29,
                          label: '$_hungerInterval dk',
                          onChanged: (value) => setState(() => _hungerInterval = value.round()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mutluluk Süresi:'),
                        Slider(
                          value: _happinessInterval.toDouble(),
                          min: 10,
                          max: 300,
                          divisions: 29,
                          label: '$_happinessInterval dk',
                          onChanged: (value) => setState(() => _happinessInterval = value.round()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Enerji Süresi:'),
                        Slider(
                          value: _energyInterval.toDouble(),
                          min: 10,
                          max: 300,
                          divisions: 29,
                          label: '$_energyInterval dk',
                          onChanged: (value) => setState(() => _energyInterval = value.round()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bakım Süresi:'),
                        Slider(
                          value: _careInterval.toDouble(),
                          min: 60,
                          max: 2880,
                          divisions: 47,
                          label: '$_careInterval dk',
                          onChanged: (value) => setState(() => _careInterval = value.round()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _birthDate != null) {
                    final pet = Pet(
                      name: _nameController.text,
                      gender: _gender!,
                      birthDate: _birthDate!,
                      hunger: _hunger,
                      happiness: _happiness,
                      energy: _energy,
                      care: _care,
                      hungerInterval: _hungerInterval,
                      happinessInterval: _happinessInterval,
                      energyInterval: _energyInterval,
                      careInterval: _careInterval,
                      vaccines: widget.pet?.vaccines ?? [],
                      type: _type ?? 'Köpek',
                      imagePath: _imagePath,
                    );
                    await FirestoreService.hayvanEkle(pet);
                    Navigator.pop(context, pet);
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}