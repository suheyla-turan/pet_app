import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:pet_app/features/pet/models/pet.dart';
import 'package:pet_app/features/pet/widgets/progress_indicator.dart';
import 'package:pet_app/features/pet/screens/vaccine_page.dart';
import 'package:pet_app/features/pet/screens/pet_form_page.dart';
import 'package:pet_app/providers/ai_provider.dart';
import 'package:pet_app/providers/pet_provider.dart';
import 'package:pet_app/services/notification_service.dart';
import 'package:pet_app/services/firestore_service.dart';
import 'package:pet_app/services/realtime_service.dart';
import 'package:pet_app/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/features/pet/screens/ai_chat_history_page.dart';
import 'package:pet_app/features/pet/models/ai_chat_message.dart';
import 'package:pet_app/features/pet/screens/ai_chat_page.dart';

class PetDetailPage extends StatefulWidget {
  final Pet pet;

  const PetDetailPage({super.key, required this.pet});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> with TickerProviderStateMixin {
  late Pet _pet;
  final FlutterTts flutterTts = FlutterTts();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  DateTime? _feedingTime;
  bool _isSavingFeedingTime = false;
  final TextEditingController _chatController = TextEditingController();
  String? _creatorName;

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
    
    _checkBirthday();
    // Doğum günü ise otomatik seslendir
    if (_pet.isBirthday) {
      Future.delayed(const Duration(milliseconds: 500), () {
        speak('Doğum günün kutlu olsun ${_pet.name}!');
      });
    }
    _loadFeedingTime();
    _loadCreatorName();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedingTime() async {
    final provider = context.read<PetProvider>();
    final time = await provider.getPetFeedingTime(_pet.name);
    if (mounted) {
      setState(() {
        _feedingTime = time;
      });
    }
  }

  Future<void> _selectFeedingTime(BuildContext context) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _feedingTime != null
          ? TimeOfDay(hour: _feedingTime!.hour, minute: _feedingTime!.minute)
          : now,
    );
    if (picked != null) {
      final today = DateTime.now();
      final selected = DateTime(today.year, today.month, today.day, picked.hour, picked.minute);
      setState(() {
        _feedingTime = selected;
      });
    }
  }

  Future<void> _saveFeedingTime() async {
    if (_feedingTime == null) return;
    setState(() { _isSavingFeedingTime = true; });
    final provider = context.read<PetProvider>();
    await provider.setPetFeedingTime(_pet.name, _feedingTime!);
    setState(() { _isSavingFeedingTime = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Beslenme zamanı kaydedildi!')),
    );
  }

  void _checkBirthday() async {
    if (_pet.isBirthday) {
      final lastCheck = await NotificationService.getLastBirthdayCheck(_pet.name);
      final today = DateTime.now();
      
      if (lastCheck == null || 
          lastCheck.day != today.day || 
          lastCheck.month != today.month || 
          lastCheck.year != today.year) {
        await NotificationService.showBirthdayNotification(_pet.name);
        await NotificationService.saveLastBirthdayCheck(_pet.name, today);
      }
    }
  }

  void besle() async {
    setState(() {
      _pet.satiety = (_pet.satiety < 10) ? _pet.satiety + 1 : 10;
    });
    await FirestoreService.hayvanGuncelle(_pet.id!, _pet);
    context.read<PetProvider>().updatePetValues(_pet);
    speak('Afiyet olsun ${_pet.name}!');
  }

  void sev() async {
    setState(() {
      _pet.happiness = (_pet.happiness < 10) ? _pet.happiness + 1 : 10;
    });
    await FirestoreService.hayvanGuncelle(_pet.id!, _pet);
    context.read<PetProvider>().updatePetValues(_pet);
    speak('Sen harika bir dostsun ${_pet.name}!');
  }

  void dinlendir() async {
    setState(() {
      _pet.energy = (_pet.energy < 10) ? _pet.energy + 1 : 10;
    });
    await FirestoreService.hayvanGuncelle(_pet.id!, _pet);
    context.read<PetProvider>().updatePetValues(_pet);
    speak('İyi uykular ${_pet.name}!');
  }

  void bakim() async {
    setState(() {
      _pet.care = (_pet.care < 10) ? _pet.care + 1 : 10;
    });
    await FirestoreService.hayvanGuncelle(_pet.id!, _pet);
    context.read<PetProvider>().updatePetValues(_pet);
    speak('Bakım zamanı, aferin ${_pet.name}!');
  }

  Future<void> soruSorDialog() async {
    final controller = TextEditingController();
    final aiProvider = context.read<AIProvider>();
    
    // AI Provider'ı başlat
    await aiProvider.initializeVoiceService();
    
    return showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Yapay Zekaya Soru Sor'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tanınan metin gösterimi
                if (aiProvider.recognizedText != null && aiProvider.recognizedText!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanınan Metin:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          aiProvider.recognizedText!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                
                // Metin girişi
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Sorunuzu yazın veya sesli sorun...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  autofocus: true,
                ),
                
                const SizedBox(height: 12),
                
                // Sesli konuşma butonu
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: aiProvider.isLoading
                            ? null
                            : () {
                                if (aiProvider.isListening) {
                                  aiProvider.stopVoiceInput();
                                } else {
                                  aiProvider.startVoiceInput();
                                }
                                setDialogState(() {});
                              },
                        icon: Icon(
                          aiProvider.isListening ? Icons.stop : Icons.mic,
                          color: aiProvider.isListening ? Colors.white : null,
                        ),
                        label: Text(
                          aiProvider.isListening ? 'Dinlemeyi Durdur' : 'Sesli Sor',
                          style: TextStyle(
                            color: aiProvider.isListening ? Colors.white : null,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: aiProvider.isListening ? Colors.red : null,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Yükleme göstergesi
                if (aiProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('AI düşünüyor...'),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  aiProvider.stopVoiceInput();
                  Navigator.pop(context);
                },
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String question = controller.text.trim();
                  
                  // Eğer sesli tanınan metin varsa onu kullan
                  if (aiProvider.recognizedText != null && aiProvider.recognizedText!.isNotEmpty) {
                    question = aiProvider.recognizedText!;
                  }
                  
                  if (question.isNotEmpty) {
                    aiProvider.stopVoiceInput();
                    Navigator.pop(context);
                    // Eski getSuggestion, getCurrentResponseForPet, clearResponseForPet fonksiyonlarına ait kalan kodları tamamen kaldır
                  }
                },
                child: const Text('Sor'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addOwnerDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcı Ekle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Kullanıcı e-posta adresi'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      if (_pet.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet ID bulunamadı!')),
        );
        return;
      }
      final success = await FirestoreService.addOwnerToPetByEmail(_pet.id!, result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Kullanıcı eklendi!' : 'Kullanıcı bulunamadı!')),
      );
    }
  }

  Future<void> _removeOwner(String uid) async {
    if (_pet.id == null) return;
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final isCreator = user?.uid == _pet.creator;
    // Sadece creator başkasını çıkarabilir, kullanıcı sadece kendini çıkarabilir
    if (uid == user?.uid || isCreator) {
      // Creator kendini çıkaramaz
      if (uid == _pet.creator) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ana kullanıcı kendini çıkaramaz!')),
        );
        return;
      }
      final docRef = FirebaseFirestore.instance.collection('hayvanlar').doc(_pet.id!);
      await docRef.update({
        'owners': FieldValue.arrayRemove([uid])
      });
      if (uid == user?.uid) {
        Navigator.pop(context); // Kendini çıkaran kullanıcı için sayfadan çık
      } else {
        setState(() {
          _pet.owners.remove(uid);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sadece ana kullanıcı başkasını çıkarabilir!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final isCreator = user?.uid == _pet.creator;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
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
        actions: [
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Hayvanı Sil',
              onPressed: () async {
                if (_pet.id != null) {
                  await FirestoreService.hayvanSil(_pet.id!);
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
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
                            _pet.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            'Detaylar',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PetFormPage(pet: _pet),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _pet = result;
                          });
                          context.read<PetProvider>().updatePetValues(_pet);
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: _buildOwnersList(),
                          ),
                          // FEEDING TIME CARD (moved here)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, color: Colors.orange),
                                        const SizedBox(width: 8),
                                        const Text('Beslenme Zamanı:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        Text(_feedingTime != null
                                            ? DateFormat('HH:mm').format(_feedingTime!)
                                            : 'Ayarlanmadı'),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _selectFeedingTime(context),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: _isSavingFeedingTime ? null : _saveFeedingTime,
                                      icon: const Icon(Icons.save),
                                      label: _isSavingFeedingTime
                                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                          : const Text('Kaydet'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Doğum günü mesajı
                          if (_pet.isBirthday)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.pink, Colors.purple, Colors.blue],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.cake, color: Colors.white, size: 40),
                                  SizedBox(height: 12),
                                  Text(
                                    '🎉 Doğum Günün Kutlu Olsun! 🎉',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Pet Image and Info Card
                          Card(
                            elevation: 12,
                            shadowColor: theme.colorScheme.primary.withOpacity(0.3),
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
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // Pet Image
                                  if (_pet.imagePath != null)
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.file(
                                          File(_pet.imagePath!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.primary.withOpacity(0.7),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.primary.withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.pets,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                    ),
                                  const SizedBox(height: 20),
                                  // Pet Info
                                  _buildInfoRow('Tür', _pet.type, Icons.pets),
                                  _buildInfoRow('Cins', _pet.breed?.isNotEmpty == true ? _pet.breed! : '-', Icons.label),
                                  _buildInfoRow('Cinsiyet', _pet.gender, Icons.person),
                                  _buildInfoRow('Doğum Tarihi', '${_pet.birthDate.day}.${_pet.birthDate.month}.${_pet.birthDate.year}', Icons.calendar_today),
                                  _buildInfoRow('Yaş', '${_pet.age} yaşında', Icons.cake),
                                ],
                              ),
                            ),
                          ),

                          // SABİT AŞILARI GÖRÜNTÜLE BUTONU
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.event_available),
                                  label: const Text('Yapılacak Aşılar'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VaccinePage(
                                          vaccines: _pet.vaccines.where((v) => !v.isDone).toList(),
                                          showDone: false,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.verified),
                                  label: const Text('Yapılmış Aşılar'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VaccinePage(
                                          vaccines: _pet.vaccines.where((v) => v.isDone).toList(),
                                          showDone: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Status Indicators Card
                          StreamBuilder<Map<String, dynamic>?>(
                            stream: RealtimeService().getPetStatusStream(_pet.id ?? _pet.name),
                            builder: (context, snapshot) {
                              final status = snapshot.data;
                              final satiety = status?['satiety'] ?? _pet.satiety;
                              final happiness = status?['happiness'] ?? _pet.happiness;
                              final energy = status?['energy'] ?? _pet.energy;
                              return Card(
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
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Durum Bilgileri',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white : const Color(0xFF2D3748),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        StatusIndicator(icon: Icons.restaurant, value: satiety),
                                        StatusIndicator(icon: Icons.favorite, value: happiness),
                                        StatusIndicator(icon: Icons.battery_charging_full, value: energy),
                                        StatusIndicator(icon: Icons.healing, value: _pet.care),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Action Buttons Card
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
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hızlı İşlemler',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        _buildActionButton(
                                          onPressed: besle,
                                          icon: Icons.restaurant,
                                          label: 'Besle',
                                          color: Colors.green,
                                        ),
                                        _buildActionButton(
                                          onPressed: sev,
                                          icon: Icons.favorite,
                                          label: 'Sev',
                                          color: Colors.pink,
                                        ),
                                        _buildActionButton(
                                          onPressed: dinlendir,
                                          icon: Icons.battery_charging_full,
                                          label: 'Dinlendir',
                                          color: Colors.blue,
                                        ),
                                        _buildActionButton(
                                          onPressed: bakim,
                                          icon: Icons.healing,
                                          label: 'Bakım',
                                          color: Colors.purple,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // AI Sohbet ve Sohbet Geçmişi Butonu
                          Consumer<AIProvider>(
                            builder: (context, aiProvider, child) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AIChatPage(pet: _pet),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.psychology),
                                      label: const Text('Soru Sor / Sohbet'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Günlük Notları (Pet Chat) kısmı tekrar eklendi
                          _buildPetChat(),
                          
                          const SizedBox(height: 20),
                          
                          // AI Response
                          // Eski tek mesajlık AI yanıtı gösteren blok ve fonksiyonlar kaldırıldı
                          // ... existing code ...
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _loadCreatorName() async {
    if (_pet.creator != null) {
      final doc = await FirebaseFirestore.instance.collection('profiller').doc(_pet.creator).get();
      if (doc.exists) {
        setState(() {
          _creatorName = doc.data()?['name'] ?? 'Ana Kullanıcı';
        });
      } else {
        setState(() {
          _creatorName = 'Ana Kullanıcı';
        });
      }
    }
  }

  Widget _buildOwnersList() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final isCreator = user?.uid == _pet.creator;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Sahipler:', style: TextStyle(fontWeight: FontWeight.bold)),
        ..._pet.owners.map((uid) => FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('profiller').doc(uid).get(),
          builder: (context, snapshot) {
            String displayName;
            if (uid == _pet.creator) {
              displayName = _creatorName ?? 'Ana Kullanıcı';
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              displayName = 'Yükleniyor...';
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              displayName = 'Bilinmeyen Kullanıcı';
            } else {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              displayName = data?['name'] ?? data?['email'] ?? 'Bilinmeyen Kullanıcı';
            }
            return ListTile(
              title: Text(displayName),
              trailing: (
                (isCreator && uid != _pet.creator) || (!isCreator && uid == user?.uid)
              )
                  ? IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeOwner(uid),
                    )
                  : null,
            );
          },
        )),
        if (isCreator)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton.icon(
              onPressed: _addOwnerDialog,
              icon: const Icon(Icons.group_add),
              label: const Text('Kullanıcı Ekle'),
            ),
          ),
      ],
    );
  }

  Widget _buildPetChat() {
    if (_pet.id == null) {
      return const SizedBox.shrink();
    }
    final realtime = RealtimeService();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text('Günlük / Sohbet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: StreamBuilder<List<PetMessage>>(
            stream: realtime.getPetMessagesStream(_pet.id!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Bir hata oluştu'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final messages = snapshot.data ?? [];
              if (messages.isEmpty) {
                return const Center(child: Text('Henüz mesaj yok.'));
              }
              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final msg = messages[i];
                  // Sadece günlük mesajları göster (AI mesajı değil)
                  // PetMessage modelinde sender alanı user uid olmalı, 'ai' veya benzeri olmamalı
                  final user = Provider.of<AuthProvider>(context, listen: false).user;
                  final isAI = msg.sender == 'ai';
                  if (isAI) return const SizedBox.shrink();
                  final isMe = user?.uid == msg.sender;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg.text),
                          const SizedBox(height: 4),
                          Text(
                            DateTime.fromMillisecondsSinceEpoch(msg.timestamp).toString().substring(0, 16),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                decoration: const InputDecoration(hintText: 'Mesaj yaz...'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                final text = _chatController.text.trim();
                if (text.isNotEmpty && user != null) {
                  await realtime.addPetMessage(_pet.id!, user.uid, text);
                  _chatController.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

// Geçici placeholder (ileride gerçek sayfa ile değiştirilecek)
class AIChatHistoryPage extends StatelessWidget {
  final Pet pet;
  const AIChatHistoryPage({super.key, required this.pet});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sohbet Geçmişi')),
      body: const Center(child: Text('Sohbet geçmişi burada görünecek.')),
    );
  }
}
