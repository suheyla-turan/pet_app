import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pati_takip/features/pet/models/pet.dart';
import 'package:pati_takip/features/pet/widgets/progress_indicator.dart';
import 'package:pati_takip/features/pet/screens/vaccine_page.dart';
import 'package:pati_takip/features/pet/screens/pet_form_page.dart';
import 'package:pati_takip/providers/ai_provider.dart';
import 'package:pati_takip/providers/pet_provider.dart';
import 'package:pati_takip/services/notification_service.dart';
import 'package:pati_takip/services/firestore_service.dart';
import 'package:pati_takip/services/realtime_service.dart';
import 'package:pati_takip/services/voice_service.dart';
import 'package:pati_takip/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pati_takip/features/pet/screens/ai_chat_page.dart';
import 'package:pati_takip/l10n/app_localizations.dart';
import 'package:pati_takip/features/pet/widgets/voice_command_widget.dart';
import 'package:pati_takip/widgets/ai_fab.dart';
import 'package:pati_takip/services/media_service.dart';

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
  // Sesli komut için eklenenler
  // late stt.SpeechToText _speech; // KALDIRILDI
  // bool _isListening = false; // KALDIRILDI
  // String _command = ''; // KALDIRILDI
  final realtimeService = RealtimeService();
  bool isAssistantOpen = false;
  void openAssistant() => setState(() => isAssistantOpen = true);
  void closeAssistant() => setState(() => isAssistantOpen = false);
  
  // Ses kayıt için eklenen değişkenler
  bool _isRecording = false;
  int _recordingDuration = 0;
  final MediaService _mediaService = MediaService();

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
    // _speech = stt.SpeechToText(); // KALDIRILDI
    
    // Media service'i başlat
    _initializeMediaService();
  }

  // Ses kayıt metodları
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleVoiceRecording() async {
    if (_isRecording) {
      await _stopVoiceRecording();
    } else {
      await _startVoiceRecording();
    }
  }

  Future<void> _startVoiceRecording() async {
    try {
      await _mediaService.initialize();
      
      _mediaService.onRecordingStarted = () {
        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
        });
      };
      
      _mediaService.onRecordingStopped = () {
        setState(() {
          _isRecording = false;
        });
      };
      
      _mediaService.onRecordingDurationChanged = (duration) {
        setState(() {
          _recordingDuration = duration;
        });
      };
      
      _mediaService.onVoiceRecorded = (path, duration) async {
        final user = Provider.of<AuthProvider>(context, listen: false).user;
        if (user != null) {
          final realtime = RealtimeService();
          await realtime.addPetMessage(_pet.id!, user.uid, '🎤 Ses mesajı (${_formatDuration(duration)})');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ses mesajı gönderildi!')),
          );
        }
      };
      
      _mediaService.onError = (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $error')),
        );
      };
      
      await _mediaService.startVoiceRecording();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ses kayıt başlatılamadı: $e')),
      );
    }
  }

  Future<void> _stopVoiceRecording() async {
    try {
      await _mediaService.stopVoiceRecording();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ses kayıt durdurulamadı: $e')),
      );
    }
  }

  Future<void> _initializeMediaService() async {
    try {
      await _mediaService.initialize();
    } catch (e) {
      print('Media service başlatılamadı: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mediaService.dispose();
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
      SnackBar(content: Text(AppLocalizations.of(context)!.feedingTimeSaved)),
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
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(AppLocalizations.of(context)!.aiAskTitle),
            content: SingleChildScrollView(
              child: Column(
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
                          Text(
                            AppLocalizations.of(context)!.recognizedText,
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
                  
                  // Metin girişi - SafeArea ile sarılmış
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.askHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        minLines: 1,
                        autofocus: true,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        onSubmitted: (text) async {
                          String question = text.trim();
                          
                          // Eğer sesli tanınan metin varsa onu kullan
                          if (aiProvider.recognizedText != null && aiProvider.recognizedText!.isNotEmpty) {
                            question = aiProvider.recognizedText!;
                          }
                          
                          if (question.isNotEmpty) {
                            Navigator.pop(context);
                            // Eski getSuggestion, getCurrentResponseForPet, clearResponseForPet fonksiyonlarına ait kalan kodları tamamen kaldır
                          }
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Sesli konuşma butonu kaldırıldı
                  // Yükleme göstergesi
                  if (aiProvider.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.aiThinking),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  String question = controller.text.trim();
                  
                  // Eğer sesli tanınan metin varsa onu kullan
                  if (aiProvider.recognizedText != null && aiProvider.recognizedText!.isNotEmpty) {
                    question = aiProvider.recognizedText!;
                  }
                  
                  if (question.isNotEmpty) {
                    Navigator.pop(context);
                    // Eski getSuggestion, getCurrentResponseForPet, clearResponseForPet fonksiyonlarına ait kalan kodları tamamen kaldır
                  }
                },
                child: Text(AppLocalizations.of(context)!.ask),
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
        title: Text(AppLocalizations.of(context)!.addUser),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.userEmailHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      if (_pet.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.petIdNotFound)),
        );
        return;
      }
      final success = await FirestoreService.addOwnerToPetByEmail(_pet.id!, result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? AppLocalizations.of(context)!.userAdded : AppLocalizations.of(context)!.userNotFound)),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.mainUserCannotRemoveSelf)),
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
        SnackBar(content: Text(AppLocalizations.of(context)!.onlyMainUserCanRemove)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final isCreator = user?.uid == _pet.creator;
    
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('PatiTakip'),
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
                                            Text(AppLocalizations.of(context)!.feedingTimeLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            const Spacer(),
                                            Text(_feedingTime != null
                                                ? DateFormat('HH:mm').format(_feedingTime!)
                                                : AppLocalizations.of(context)!.notSet),
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
                                              : Text(AppLocalizations.of(context)!.save),
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
                                      _buildInfoRow(AppLocalizations.of(context)!.petType, getLocalizedPetType(_pet.type, context), Icons.pets),
                                      _buildInfoRow(AppLocalizations.of(context)!.breed, _pet.breed?.isNotEmpty == true ? _pet.breed! : '-', Icons.label),
                                      _buildInfoRow(AppLocalizations.of(context)!.gender, getLocalizedGender(_pet.gender, context), Icons.person),
                                      _buildInfoRow(AppLocalizations.of(context)!.birthDateLabel, '${_pet.birthDate.day}.${_pet.birthDate.month}.${_pet.birthDate.year}', Icons.calendar_today),
                                      _buildInfoRow(AppLocalizations.of(context)!.age, AppLocalizations.of(context)!.yearsOld(_pet.age), Icons.cake),
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
                                      label: Text(AppLocalizations.of(context)!.vaccinesToBeTaken),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 4,
                                      ),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => VaccinePage(
                                              vaccines: _pet.vaccines, // Tüm listeyi gönder
                                              showDone: false,
                                            ),
                                          ),
                                        );
                                        if (result != null && result is List<Vaccine>) {
                                          setState(() {
                                            _pet.vaccines = result; // Güncel listeyi doğrudan ata
                                          });
                                          context.read<PetProvider>().updatePetValues(_pet);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.verified),
                                      label: Text(AppLocalizations.of(context)!.vaccinesTaken),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 4,
                                      ),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => VaccinePage(
                                              vaccines: _pet.vaccines, // Tüm listeyi gönder
                                              showDone: true,
                                            ),
                                          ),
                                        );
                                        if (result != null && result is List<Vaccine>) {
                                          setState(() {
                                            _pet.vaccines = result; // Güncel listeyi doğrudan ata
                                          });
                                          context.read<PetProvider>().updatePetValues(_pet);
                                        }
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
                                              AppLocalizations.of(context)!.statusInfoTitle,
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
                                          AppLocalizations.of(context)!.quickActions,
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
                                              label: AppLocalizations.of(context)!.feed,
                                              color: Colors.green,
                                            ),
                                            _buildActionButton(
                                              onPressed: sev,
                                              icon: Icons.favorite,
                                              label: AppLocalizations.of(context)!.pet,
                                              color: Colors.pink,
                                            ),
                                            _buildActionButton(
                                              onPressed: dinlendir,
                                              icon: Icons.battery_charging_full,
                                              label: AppLocalizations.of(context)!.rest,
                                              color: Colors.blue,
                                            ),
                                            _buildActionButton(
                                              onPressed: bakim,
                                              icon: Icons.healing,
                                              label: AppLocalizations.of(context)!.care,
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
                                          label: Text(AppLocalizations.of(context)!.askQuestionChat),
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
        ),
                          DraggableAIFab(onTap: openAssistant, pet: widget.pet),
        if (isAssistantOpen)
          Positioned.fill(
            child: Material(
              color: Colors.black.withOpacity(0.15),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                        child: VoiceCommandWidget(
                          key: ValueKey(isAssistantOpen),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 36,
                    right: 36,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 32, color: Colors.black54),
                      tooltip: 'Kapat',
                      onPressed: closeAssistant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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
        Text(AppLocalizations.of(context)!.owners, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              label: Text(AppLocalizations.of(context)!.addUser),
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
        Text(AppLocalizations.of(context)!.diaryChat, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                return Center(child: Text(AppLocalizations.of(context)!.errorOccurred));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final messages = snapshot.data ?? [];
              if (messages.isEmpty) {
                return Center(child: Text(AppLocalizations.of(context)!.noMessages));
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
                    child: GestureDetector(
                      onLongPress: isMe ? () => _showDeleteMessageDialog(msg) : null,
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(child: Text(msg.text)),
                                if (isMe && msg.key != null)
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                    onPressed: () => _showDeleteMessageDialog(msg),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateTime.fromMillisecondsSinceEpoch(msg.timestamp).toString().substring(0, 16),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Geliştirilmiş mesaj girişi alanı - SafeArea ile sarılmış
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 8,
              right: 8,
            ),
            child: Column(
              children: [
                // Kayıt süresi göstergesi
                if (_isRecording)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Kayıt yapılıyor... ${_formatDuration(_recordingDuration)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    // Ses kayıt butonu
                    IconButton(
                      icon: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: _isRecording ? Colors.red : Colors.blue,
                      ),
                      onPressed: () => _toggleVoiceRecording(),
                      tooltip: _isRecording ? 'Kaydı Durdur' : 'Ses Kaydet',
                    ),
                    // Görsel not butonu
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.green),
                      onPressed: () => _showImageNoteDialog(),
                      tooltip: 'Görsel Not Ekle',
                    ),
                    const SizedBox(width: 8),
                    // Metin girişi
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        enabled: !_isRecording,
                        decoration: InputDecoration(
                          hintText: _isRecording 
                              ? 'Kayıt yapılıyor...' 
                              : AppLocalizations.of(context)!.writeMessage,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (text) async {
                          if (text.trim().isNotEmpty && user != null && !_isRecording) {
                            await realtime.addPetMessage(_pet.id!, user.uid, text.trim());
                            _chatController.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Gönder butonu
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _isRecording ? null : () async {
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
            ),
          ),
        ),
      ],
    );
  }

  String getLocalizedPetType(String type, BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    switch (type) {
      case 'dog':
      case 'Köpek':
        return loc.dog;
      case 'cat':
      case 'Kedi':
        return loc.cat;
      case 'bird':
      case 'Kuş':
        return loc.bird;
      case 'fish':
      case 'Balık':
        return loc.fish;
      case 'hamster':
        return loc.hamster;
      case 'rabbit':
      case 'Tavşan':
        return loc.rabbit;
      case 'other':
      case 'Diğer':
        return loc.other;
      default:
        return type;
    }
  }

  String getLocalizedGender(String gender, BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    switch (gender) {
      case 'male':
      case 'Erkek':
        return loc.male;
      case 'female':
      case 'Dişi':
        return loc.female;
      default:
        return gender;
    }
  }

  // _startListening fonksiyonu kaldırıldı
  // void _startListening() async {
  //   if (!_isListening) {
  //     bool available = await _speech.initialize(
  //       onStatus: (status) => print('Speech status: $status'),
  //       onError: (error) {
  //         debugPrint('Speech initialize error: ${error.errorMsg} (permanent: ${error.permanent})');
  //         if (error.errorMsg == 'error_network') {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('İnternet bağlantısı yok veya Google servislerine erişilemiyor.')),
  //           );
  //         } else if (error.errorMsg == 'error_speech_timeout') {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Konuşma algılanamadı, lütfen tekrar deneyin.')),
  //           );
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('Sesli tanıma hatası: ${error.errorMsg}')),
  //           );
  //         }
  //       },
  //     );
  //     if (available) {
  //       setState(() => _isListening = true);
  //       _speech.listen(
  //         localeId: 'tr_TR', // Türkçe için
  //         listenFor: Duration(seconds: 10),
  //         onResult: (val) async {
  //           setState(() {
  //             _command = val.recognizedWords;
  //           });
  //           if (val.hasConfidenceRating && val.confidence > 0) {
  //             _speech.stop();
  //             setState(() => _isListening = false);
  //             await _handleVoiceCommand(_command);
  //           }
  //         },
  //       );
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Dinleniyor...')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Mikrofon izni verilmedi veya cihaz desteklemiyor!')),
  //       );
  //     }
  //   } else {
  //     _speech.stop();
  //     setState(() => _isListening = false);
  //   }
  // }

  Future<void> _handleVoiceCommand(String command) async {
    // Basit intent recognition - gerçek uygulamada AI servisi kullanılabilir
    Map<String, dynamic> intentData = {'intent': 'unknown', 'petId': null};
    
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('besle') || lowerCommand.contains('yemek')) {
      intentData['intent'] = 'feed';
    } else if (lowerCommand.contains('uyu') || lowerCommand.contains('dinlen')) {
      intentData['intent'] = 'sleep';
    } else if (lowerCommand.contains('bakım') || lowerCommand.contains('sev')) {
      intentData['intent'] = 'care';
    }
    
    // Pet adını bul
    for (final pet in context.read<PetProvider>().pets) {
      if (lowerCommand.contains(pet.name.toLowerCase())) {
        intentData['petId'] = pet.id;
        break;
      }
    }
    final petProvider = context.read<PetProvider>();
    Pet? pet;
    if (intentData['petId'] != null) {
      try {
        pet = petProvider.pets.firstWhere(
          (p) => p.id == intentData['petId'] || p.name == intentData['petId'],
        );
      } catch (e) {
        pet = null;
      }
    } else {
      pet = _pet;
    }
    switch (intentData['intent']) {
      case 'feed':
        if (pet != null) {
          await realtimeService.setFeedingTime(pet.id ?? pet.name, DateTime.now());
          await realtimeService.updatePetStatus(pet.id ?? pet.name, satiety: 100);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pet.name} beslendi!')),
          );
        }
        break;
      case 'sleep':
        if (pet != null) {
          await realtimeService.updatePetStatus(pet.id ?? pet.name, energy: 100);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pet.name} uyutuldu!')),
          );
        }
        break;
      case 'care':
        if (pet != null) {
          await realtimeService.updatePetStatus(pet.id ?? pet.name, happiness: 100);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pet.name} bakımı yapıldı!')),
          );
        }
        break;
      case 'go_to_profile':
        // Zaten profildeyiz, gerekirse başka bir işlem yapılabilir
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Komut anlaşılamadı: $command')),
        );
        break;
    }
  }

  // Sesli not dialog'u
  Future<void> _showVoiceNoteDialog() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    bool isRecording = false;
    String recordedText = '';
    final realtime = RealtimeService();
    final voiceService = VoiceService();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Sesli Not Ekle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRecording)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic, color: Colors.red, size: 24),
                        SizedBox(width: 8),
                        Text('Kayıt yapılıyor...'),
                      ],
                    ),
                  ),
                if (recordedText.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(recordedText),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (!isRecording) {
                          // Kayıt başlat
                          setDialogState(() {
                            isRecording = true;
                            recordedText = '';
                          });
                          
                          // Sesli tanıma servisini başlat
                          voiceService.onSpeechResult = (text) {
                            setDialogState(() {
                              recordedText = text;
                              isRecording = false;
                            });
                          };
                          
                          voiceService.onSpeechError = (error) {
                            setDialogState(() {
                              isRecording = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Hata: $error')),
                            );
                          };
                          
                          await voiceService.startVoiceInput(seconds: 10);
                        } else {
                          // Kayıt durdur
                          await voiceService.stopVoiceInput();
                          setDialogState(() {
                            isRecording = false;
                          });
                        }
                      },
                      icon: Icon(isRecording ? Icons.stop : Icons.mic),
                      label: Text(isRecording ? 'Durdur' : 'Kaydet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRecording ? Colors.red : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (isRecording) {
                    voiceService.stopVoiceInput();
                  }
                  Navigator.pop(context);
                },
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: recordedText.isNotEmpty
                    ? () async {
                        await realtime.addPetMessage(_pet.id!, user.uid, '🎤 $recordedText');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sesli not eklendi!')),
                        );
                      }
                    : null,
                child: const Text('Ekle'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Görsel not dialog'u
  Future<void> _showImageNoteDialog() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    String? selectedImagePath;
    final textController = TextEditingController();
    final realtime = RealtimeService();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Görsel Not Ekle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Görsel seçme butonları
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.camera);
                          if (image != null) {
                            setDialogState(() {
                              selectedImagePath = image.path;
                            });
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Kamera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setDialogState(() {
                              selectedImagePath = image.path;
                            });
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeri'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Seçilen görsel önizlemesi
                if (selectedImagePath != null)
                  Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(selectedImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Not metni
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Not ekleyin (opsiyonel)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: selectedImagePath != null
                    ? () async {
                        final note = textController.text.trim();
                        final message = note.isNotEmpty 
                            ? '📷 $note'
                            : '📷 Görsel not eklendi';
                        await realtime.addPetMessage(_pet.id!, user.uid, message);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Görsel not eklendi!')),
                        );
                      }
                    : null,
                child: const Text('Ekle'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Not silme dialog'u
  Future<void> _showDeleteMessageDialog(PetMessage message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteNote),
        content: Text(AppLocalizations.of(context)!.deleteNoteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    
    if (confirm == true && message.key != null && _pet.id != null) {
      try {
        await RealtimeService().deletePetMessage(_pet.id!, message.key!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noteDeleted)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noteDeleteError(e.toString()))),
        );
      }
    }
  }
}

// Geçici placeholder (ileride gerçek sayfa ile değiştirilecek)
class AIChatHistoryPage extends StatelessWidget {
  final Pet pet;
  const AIChatHistoryPage({super.key, required this.pet});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.chatHistory)),
      body: const Center(child: Text('Sohbet geçmişi burada görünecek.')),
    );
  }
}
