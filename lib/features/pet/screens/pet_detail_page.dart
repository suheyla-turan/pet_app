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
import 'package:pati_takip/features/pet/screens/ai_chat_page.dart';
import 'package:pati_takip/features/pet/screens/co_owner_management_page.dart';

import 'package:pati_takip/providers/pet_provider.dart';
import 'package:pati_takip/services/notification_service.dart';
import 'package:pati_takip/services/firestore_service.dart';
import 'package:pati_takip/services/realtime_service.dart';

import 'package:pati_takip/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pati_takip/l10n/app_localizations.dart';


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
  final TextEditingController _chatController = TextEditingController();
  // Sesli komut için eklenenler
  // late stt.SpeechToText _speech; // KALDIRILDI
  // bool _isListening = false; // KALDIRILDI
  // String _command = ''; // KALDIRILDI
  final realtimeService = RealtimeService();

  
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
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Soru Sor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Metin girişi
              TextField(
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
                  if (question.isNotEmpty) {
                    Navigator.pop(context);
                    // AI özelliği kaldırıldı
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('AI özelliği kaldırıldı')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              String question = controller.text.trim();
              if (question.isNotEmpty) {
                Navigator.pop(context);
                // AI özelliği kaldırıldı
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('AI özelliği kaldırıldı')),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.ask),
          ),
        ],
      ),
    );
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
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              _pet.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetFormPage(pet: _pet),
                        ),
                      );
                      if (result != null && result is Pet) {
                        setState(() {
                          _pet = result;
                        });
                        context.read<PetProvider>().updatePetValues(_pet);
                      }
                      break;
                    case 'delete':
                      await _showDeletePetDialog();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (isCreator) // Sadece hayvanın yaratıcısı düzenleyebilir
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue.shade600),
                          const SizedBox(width: 12),
                          const Text('Hayvanı Düzenle'),
                        ],
                      ),
                    ),
                  if (isCreator) // Sadece hayvanın yaratıcısı silebilir
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red.shade600),
                          const SizedBox(width: 12),
                          const Text('Hayvanı Sil'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          floatingActionButton: _buildAIChatButton(),
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
                              
                                                             // Pet Image and Info Card - Yeni tasarım
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
                                   child: Row(
                                     children: [
                                       // Sol taraf - Pet Image
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
                                                 Colors.purple,
                                                 Colors.purple.withOpacity(0.7),
                                               ],
                                             ),
                                             boxShadow: [
                                               BoxShadow(
                                                 color: Colors.purple.withOpacity(0.3),
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
                                       const SizedBox(width: 20),
                                       
                                       // Sağ taraf - Pet Info
                                       Expanded(
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             // Hayvan adı
                                             Text(
                                               _pet.name,
                                               style: const TextStyle(
                                                 fontSize: 20,
                                                 fontWeight: FontWeight.bold,
                                                 color: Colors.white,
                                               ),
                                             ),
                                             const SizedBox(height: 12),
                                             
                                                                                           // Bilgi etiketleri - Görüntüdeki gibi
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  _buildInfoTag(
                                                    icon: Icons.cake,
                                                    text: '${_pet.age} yaşında',
                                                    color: Colors.orange,
                                                  ),
                                                  _buildInfoTag(
                                                    icon: Icons.pets,
                                                    text: _getLocalizedGender(_pet.gender),
                                                    color: Colors.pink,
                                                  ),
                                                  _buildInfoTag(
                                                    icon: Icons.pets,
                                                    text: _getLocalizedPetType(_pet.type),
                                                    color: Colors.green,
                                                  ),
                                                  if (_pet.breed != null && _pet.breed!.isNotEmpty)
                                                    _buildInfoTag(
                                                      icon: Icons.label,
                                                      text: _pet.breed!,
                                                      color: Colors.blue,
                                                    ),
                                                ],
                                              ),
                                           ],
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ),

                              
                              
                                                             // Durum Bilgileri Kartı - Görüntüdeki tasarım
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
                                         color: Colors.grey.shade800,
                                       ),
                                       child: Padding(
                                         padding: const EdgeInsets.all(20),
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             // Başlık
                                             Text(
                                               'Durum Bilgileri',
                                               style: TextStyle(
                                                 fontSize: 18,
                                                 fontWeight: FontWeight.w700,
                                                 color: Colors.white,
                                               ),
                                             ),
                                             const SizedBox(height: 20),
                                             
                                             // Durum göstergeleri
                                             _buildStatusRow(
                                               icon: Icons.restaurant,
                                               label: 'Açlık',
                                               value: satiety,
                                               color: Colors.orange,
                                             ),
                                             const SizedBox(height: 16),
                                             _buildStatusRow(
                                               icon: Icons.favorite,
                                               label: 'Mutluluk',
                                               value: happiness,
                                               color: Colors.pink,
                                             ),
                                             const SizedBox(height: 16),
                                             _buildStatusRow(
                                               icon: Icons.battery_charging_full,
                                               label: 'Enerji',
                                               value: energy,
                                               color: Colors.blue,
                                             ),
                                             const SizedBox(height: 16),
                                             _buildStatusRow(
                                               icon: Icons.healing,
                                               label: 'Bakım',
                                               value: _pet.care,
                                               color: Colors.green,
                                             ),
                                             
                                             const SizedBox(height: 20),
                                             
                                             // Alt kısım - Online sahip bilgisi
                                             Container(
                                               width: double.infinity,
                                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                               decoration: BoxDecoration(
                                                 color: Colors.green.shade700,
                                                 borderRadius: BorderRadius.circular(12),
                                               ),
                                               child: Row(
                                                 children: [
                                                   Container(
                                                     width: 8,
                                                     height: 8,
                                                     decoration: BoxDecoration(
                                                       color: Colors.green.shade300,
                                                       shape: BoxShape.circle,
                                                     ),
                                                   ),
                                                   const SizedBox(width: 8),
                                                   Text(
                                                     '1 eş sahip çevrimiçi',
                                                     style: TextStyle(
                                                       color: Colors.white,
                                                       fontSize: 14,
                                                       fontWeight: FontWeight.w500,
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                     ),
                                   );
                                 },
                               ),
                              
                              const SizedBox(height: 20),
                              
                              // Hızlı İşlemler Kartı - Yeni tasarım
                              Card(
                                elevation: 8,
                                shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey.shade800,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Başlık
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.calendar_today,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Hızlı İşlemler',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        
                                        // Hızlı işlem butonları (2x2 grid)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildQuickActionButton(
                                                onPressed: besle,
                                                icon: Icons.restaurant,
                                                label: 'Besle',
                                                color: Colors.orange,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildQuickActionButton(
                                                onPressed: sev,
                                                icon: Icons.favorite,
                                                label: 'Sev',
                                                color: Colors.pink,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildQuickActionButton(
                                                onPressed: dinlendir,
                                                icon: Icons.nightlight_round,
                                                label: 'Dinlendir',
                                                color: Colors.blue,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildQuickActionButton(
                                                onPressed: bakim,
                                                icon: Icons.build,
                                                label: 'Bakım',
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Aşı Bilgileri Kartı - Yeni tasarım
                               Card(
                                 elevation: 8,
                                 shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                                 child: Container(
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(20),
                                     color: Colors.grey.shade800,
                                   ),
                                   child: Padding(
                                     padding: const EdgeInsets.all(20),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         // Başlık
                                         Row(
                                           children: [
                                             Container(
                                               width: 40,
                                               height: 40,
                                               decoration: BoxDecoration(
                                                 color: Colors.blue,
                                                 borderRadius: BorderRadius.circular(8),
                                               ),
                                               child: const Icon(
                                                 Icons.vaccines,
                                                 color: Colors.white,
                                                 size: 20,
                                               ),
                                             ),
                                             const SizedBox(width: 12),
                                             const Text(
                                               'Aşı Bilgileri',
                                               style: TextStyle(
                                                 fontSize: 18,
                                                 fontWeight: FontWeight.w700,
                                                 color: Colors.white,
                                               ),
                                             ),
                                           ],
                                         ),
                                         const SizedBox(height: 20),
                                         
                                         // Aşı butonları
                                         Row(
                                           children: [
                                             Expanded(
                                               child: _buildVaccineButton(
                                                 onPressed: () async {
                                                   final result = await Navigator.push(
                                                     context,
                                                     MaterialPageRoute(
                                                       builder: (_) => VaccinePage(
                                                         vaccines: _pet.vaccines,
                                                         showDone: false,
                                                       ),
                                                     ),
                                                   );
                                                   if (result != null && result is List<Vaccine>) {
                                                     setState(() {
                                                       _pet.vaccines = result;
                                                     });
                                                     context.read<PetProvider>().updatePetValues(_pet);
                                                   }
                                                 },
                                                 icon: Icons.event_available,
                                                 label: 'Yapılacak Aşılar',
                                                 color: Colors.orange,
                                               ),
                                             ),
                                             const SizedBox(width: 12),
                                             Expanded(
                                               child: _buildVaccineButton(
                                                 onPressed: () async {
                                                   final result = await Navigator.push(
                                                     context,
                                                     MaterialPageRoute(
                                                       builder: (_) => VaccinePage(
                                                         vaccines: _pet.vaccines,
                                                         showDone: true,
                                                       ),
                                                     ),
                                                   );
                                                   if (result != null && result is List<Vaccine>) {
                                                     setState(() {
                                                       _pet.vaccines = result;
                                                     });
                                                     context.read<PetProvider>().updatePetValues(_pet);
                                                   }
                                                 },
                                                 icon: Icons.verified,
                                                 label: 'Yapılan Aşılar',
                                                 color: Colors.green,
                                               ),
                                             ),
                                           ],
                                         ),
                                       ],
                                     ),
                                   ),
                                                                ),
                             ),
                             
                             const SizedBox(height: 20),
                             
                             // Eş Sahip Yönetimi Kartı
                             Card(
                               elevation: 8,
                               shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                               child: Container(
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(20),
                                   color: Colors.grey.shade800,
                                 ),
                                 child: Padding(
                                   padding: const EdgeInsets.all(20),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       // Başlık
                                       Row(
                                         children: [
                                           Container(
                                             width: 40,
                                             height: 40,
                                             decoration: BoxDecoration(
                                               color: Colors.purple,
                                               borderRadius: BorderRadius.circular(8),
                                             ),
                                             child: const Icon(
                                               Icons.people,
                                               color: Colors.white,
                                               size: 20,
                                             ),
                                           ),
                                           const SizedBox(width: 12),
                                           const Text(
                                             'Eş Sahip Yönetimi',
                                             style: TextStyle(
                                               fontSize: 18,
                                               fontWeight: FontWeight.w700,
                                               color: Colors.white,
                                             ),
                                           ),
                                         ],
                                       ),
                                       const SizedBox(height: 20),
                                       
                                       // Eş sahip yönetimi butonu
                                       SizedBox(
                                         width: double.infinity,
                                         child: _buildQuickActionButton(
                                           onPressed: () {
                                             Navigator.push(
                                               context,
                                               MaterialPageRoute(
                                                 builder: (_) => CoOwnerManagementPage(pet: _pet),
                                               ),
                                             );
                                           },
                                           icon: Icons.people,
                                           label: 'Eş Sahip Yönetimi',
                                           color: Colors.purple,
                                         ),
                                       ),
                                       
                                       // Mevcut eş sahip bilgileri

                                     ],
                                   ),
                                 ),
                               ),
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

  Widget _buildQuickActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade700.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVaccineButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade700.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedPetType(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
      case 'köpek':
        return 'Köpek';
      case 'cat':
      case 'kedi':
        return 'Kedi';
      case 'bird':
      case 'kuş':
        return 'Kuş';
      case 'fish':
      case 'balık':
        return 'Balık';
      case 'hamster':
        return 'Hamster';
      case 'rabbit':
      case 'tavşan':
        return 'Tavşan';
      case 'cow':
      case 'inek':
        return 'İnek';
      case 'horse':
      case 'at':
        return 'At';
      case 'other':
      case 'diğer':
        return 'Diğer';
      default:
        return type.isNotEmpty ? type : 'Hayvan';
    }
  }

  String _getLocalizedGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
      case 'erkek':
        return 'Erkek';
      case 'female':
      case 'dişi':
        return 'Dişi';
      default:
        return gender.isNotEmpty ? gender : 'Belirsiz';
    }
  }

  Widget _buildInfoTag({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Row(
      children: [
        // İkon
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(width: 12),
        // Etiket
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        // Progress bar
        Container(
          width: 120,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade600,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 10,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Değer
        Text(
          '$value/10',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
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
          height: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey.shade900 
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey.shade700 
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: StreamBuilder<List<PetMessage>>(
            stream: realtime.getPetMessagesStream(_pet.id!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.errorOccurred,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Mesajlar yükleniyor...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              final messages = snapshot.data ?? [];
              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noMessages,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'İlk mesajınızı yazmaya başlayın!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
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
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe 
                              ? Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.blue.shade700 
                                  : Colors.blue.shade100
                              : Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey.shade700 
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Message text with better wrapping
                            Text(
                              msg.text,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isMe 
                                    ? Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white 
                                        : Colors.black87
                                    : Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white 
                                        : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Timestamp and delete button row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatMessageTime(msg.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMe 
                                        ? Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.blue.shade200 
                                            : Colors.blue.shade600
                                        : Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.grey.shade400 
                                            : Colors.grey.shade600,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                if (isMe && msg.key != null)
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline, 
                                      size: 18, 
                                      color: isMe 
                                          ? Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.red.shade300 
                                              : Colors.red.shade600
                                          : Colors.red.shade400,
                                    ),
                                    onPressed: () => _showDeleteMessageDialog(msg),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Mesajı Sil',
                                  ),
                              ],
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
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey.shade800 
                              : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black87,
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

  // AI Chat butonu
  Widget _buildAIChatButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 80), // Chat input alanının üstünde konumlandır
      child: FloatingActionButton(
        onPressed: () => _showAIChatDialog(),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 8,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.smart_toy,
            size: 28,
          ),
        ),
      ),
    );
  }

  // AI Chat sayfasına yönlendir
  void _showAIChatDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AIChatPage(),
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

  // Hayvanı silme dialog'u
  Future<void> _showDeletePetDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletePet),
        content: Text(AppLocalizations.of(context)!.deletePetConfirm),
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

    if (confirm == true && _pet.id != null) {
      try {
        await FirestoreService.hayvanSil(_pet.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.petDeleted)),
        );
        Navigator.of(context).pop(); // Ana sayfaya dön
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.petDeleteError(e.toString()))),
        );
      }
    }
  }







  // Mesaj zamanını formatla
  String _formatMessageTime(int timestamp) {
    final now = DateTime.now();
    final messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(messageTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
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
