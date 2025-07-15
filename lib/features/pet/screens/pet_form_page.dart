import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pet_app/features/pet/models/pet.dart';
import 'package:pet_app/providers/pet_provider.dart';

class PetFormPage extends StatefulWidget {
  final Pet? pet;
  const PetFormPage({super.key, this.pet});

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  int _satiety = 5;
  int _happiness = 5;
  int _energy = 5;
  int _care = 5;
  int _satietyInterval = 60;
  int _happinessInterval = 60;
  int _energyInterval = 60;
  int _careInterval = 1440;
  String? _type;
  String? _imagePath;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _petTypes = [
    'Köpek', 'Kedi', 'Kuş', 'Balık', 'Hamster', 'Tavşan', 'Diğer'
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _gender = widget.pet!.gender;
      _birthDate = widget.pet!.birthDate;
      _satiety = widget.pet!.satiety;
      _happiness = widget.pet!.happiness;
      _energy = widget.pet!.energy;
      _care = widget.pet!.care;
      _satietyInterval = widget.pet!.satietyInterval;
      _happinessInterval = widget.pet!.happinessInterval;
      _energyInterval = widget.pet!.energyInterval;
      _careInterval = widget.pet!.careInterval;
      _type = widget.pet!.type;
      _imagePath = widget.pet!.imagePath;
      _breedController.text = widget.pet!.breed ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  Future<void> _savePet() async {
    if (_formKey.currentState!.validate() && _birthDate != null) {
      final pet = Pet(
        name: _nameController.text,
        gender: _gender!,
        birthDate: _birthDate!,
        satiety: _satiety,
        happiness: _happiness,
        energy: _energy,
        care: _care,
        satietyInterval: _satietyInterval,
        happinessInterval: _happinessInterval,
        energyInterval: _energyInterval,
        careInterval: _careInterval,
        vaccines: widget.pet?.vaccines ?? [],
        type: _type ?? 'Köpek',
        breed: _breedController.text.trim(),
        imagePath: _imagePath,
      );

      try {
        if (widget.pet == null) {
          // Yeni hayvan ekleme - sadece Navigator.pop ile pet'i döndür
          // PetListPage'de addPet çağrılacak
        } else {
          // Mevcut hayvanı güncelleme
          await context.read<PetProvider>().updatePet(widget.pet!.name, pet);
        }
        Navigator.pop(context, pet);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [
                  const Color(0xFF1A202C),
                  const Color(0xFF2D3748),
                  const Color(0xFF4A5568),
                ]
              : [
                  const Color(0xFFF7FAFC),
                  const Color(0xFFEDF2F7),
                  const Color(0xFFE2E8F0),
                ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Beautiful Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.pet == null ? 'Yeni Evcil Hayvan' : 'Bilgileri Düzenle',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            'Sevimli dostunuzun bilgilerini girin',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Image Picker Card
                          Card(
                            elevation: 8,
                            shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          Colors.grey.shade800,
                                          Colors.grey.shade700,
                                        ]
                                      : [
                                          Colors.white,
                                          Colors.grey.shade50,
                                        ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Text(
                                      'Fotoğraf',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: theme.colorScheme.primary.withOpacity(0.3),
                                            width: 2,
                                            style: BorderStyle.solid,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(18),
                                          child: _imagePath != null
                                              ? Image.file(
                                                  File(_imagePath!),
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        theme.colorScheme.primary.withOpacity(0.1),
                                                        theme.colorScheme.primary.withOpacity(0.05),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.add_a_photo,
                                                        size: 40,
                                                        color: theme.colorScheme.primary,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Fotoğraf Ekle',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: theme.colorScheme.primary,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Basic Info Card
                          Card(
                            elevation: 8,
                            shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          Colors.grey.shade800,
                                          Colors.grey.shade700,
                                        ]
                                      : [
                                          Colors.white,
                                          Colors.grey.shade50,
                                        ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Temel Bilgiler',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Pet Type
                                    DropdownButtonFormField<String>(
                                      value: _type,
                                      decoration: const InputDecoration(
                                        labelText: 'Tür',
                                        prefixIcon: Icon(Icons.pets),
                                      ),
                                      items: _petTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                      onChanged: (value) => setState(() => _type = value),
                                      validator: (value) => value == null ? 'Tür seçiniz' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Pet Name
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'İsim',
                                        prefixIcon: Icon(Icons.edit),
                                      ),
                                      validator: (value) => value == null || value.isEmpty ? 'İsim giriniz' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Breed
                                    TextFormField(
                                      controller: _breedController,
                                      decoration: const InputDecoration(
                                        labelText: 'Cinsi',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Cinsi zorunlu';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Gender
                                    DropdownButtonFormField<String>(
                                      value: _gender,
                                      decoration: const InputDecoration(
                                        labelText: 'Cinsiyet',
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'Dişi', child: Text('Dişi')),
                                        DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                                      ],
                                      onChanged: (value) => setState(() => _gender = value),
                                      validator: (value) => value == null ? 'Cinsiyet seçiniz' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Birth Date
                                    InkWell(
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
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_today, color: Colors.grey),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _birthDate == null
                                                    ? 'Doğum Tarihi Seçiniz'
                                                    : 'Doğum Tarihi: ${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}',
                                                style: TextStyle(
                                                  color: _birthDate == null ? Colors.grey.shade500 : null,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Interval Settings Card
                          Card(
                            elevation: 8,
                            shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          Colors.grey.shade800,
                                          Colors.grey.shade700,
                                        ]
                                      : [
                                          Colors.white,
                                          Colors.grey.shade50,
                                        ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Süre Ayarları (Dakika)',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    
                                     _buildIntervalSlider(
                                       label: 'Tokluk Süresi',
                                       value: _satietyInterval.toDouble(),
                                       min: 10,
                                       max: 300,
                                       icon: Icons.restaurant,
                                       onChanged: (value) => setState(() => _satietyInterval = value.round()),
                                     ),
                                     
                                     const SizedBox(height: 16),
                                     
                                     _buildIntervalSlider(
                                       label: 'Mutluluk Süresi',
                                       value: _happinessInterval.toDouble(),
                                       min: 10,
                                       max: 300,
                                       icon: Icons.favorite,
                                       onChanged: (value) => setState(() => _happinessInterval = value.round()),
                                     ),
                                     
                                     const SizedBox(height: 16),
                                     
                                     _buildIntervalSlider(
                                       label: 'Enerji Süresi',
                                       value: _energyInterval.toDouble(),
                                       min: 10,
                                       max: 300,
                                       icon: Icons.battery_charging_full,
                                       onChanged: (value) => setState(() => _energyInterval = value.round()),
                                     ),
                                     
                                     const SizedBox(height: 16),
                                     
                                     _buildIntervalSlider(
                                       label: 'Bakım Süresi',
                                       value: _careInterval.toDouble(),
                                       min: 60,
                                       max: 2880,
                                       icon: Icons.healing,
                                       onChanged: (value) => setState(() => _careInterval = value.round()),
                                     ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _savePet,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                widget.pet == null ? 'Hayvan Ekle' : 'Güncelle',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.round()} dk',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 10).round(),
          activeColor: theme.colorScheme.primary,
          inactiveColor: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          onChanged: onChanged,
        ),
      ],
    );
  }
}