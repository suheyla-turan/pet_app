import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import 'package:pet_app/features/pet/models/pet.dart';
import 'package:pet_app/features/pet/widgets/progress_indicator.dart';
import 'package:pet_app/features/pet/screens/vaccine_page.dart';
import 'package:pet_app/features/pet/screens/pet_form_page.dart';
import 'package:pet_app/providers/ai_provider.dart';
import 'package:pet_app/providers/pet_provider.dart';
import 'package:pet_app/services/notification_service.dart';

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
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  void besle() {
    setState(() {
      _pet.hunger = (_pet.hunger > 0) ? _pet.hunger - 1 : 0;
    });
    context.read<PetProvider>().updatePetValues(_pet);
    speak('Afiyet olsun ${_pet.name}!');
  }

  void sev() {
    setState(() {
      _pet.happiness = (_pet.happiness < 10) ? _pet.happiness + 1 : 10;
    });
    context.read<PetProvider>().updatePetValues(_pet);
    speak('Sen harika bir dostsun ${_pet.name}!');
  }

  void dinlendir() {
    setState(() {
      _pet.energy = (_pet.energy < 10) ? _pet.energy + 1 : 10;
    });
    context.read<PetProvider>().updatePetValues(_pet);
    speak('İyi uykular ${_pet.name}!');
  }

  void bakim() {
    setState(() {
      _pet.care = (_pet.care < 10) ? _pet.care + 1 : 10;
    });
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
                    await aiProvider.getSuggestion(question, pet: _pet);
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
                                  _buildInfoRow('Cinsiyet', _pet.gender, Icons.person),
                                  _buildInfoRow('Doğum Tarihi', '${_pet.birthDate.day}.${_pet.birthDate.month}.${_pet.birthDate.year}', Icons.calendar_today),
                                  _buildInfoRow('Yaş', '${_pet.age} yaşında', Icons.cake),
                                ],
                              ),
                            ),
                          ),

                          // SABİT AŞILARI GÖRÜNTÜLE BUTONU
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.vaccines),
                              label: const Text(
                                'Aşıları Görüntüle',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: theme.colorScheme.primary,
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
                                    builder: (_) => VaccinePage(vaccines: _pet.vaccines),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Status Indicators Card
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
                                      'Durum Bilgileri',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    StatusIndicator(icon: Icons.restaurant, value: _pet.hunger),
                                    StatusIndicator(icon: Icons.favorite, value: _pet.happiness),
                                    StatusIndicator(icon: Icons.battery_charging_full, value: _pet.energy),
                                    StatusIndicator(icon: Icons.healing, value: _pet.care),
                                  ],
                                ),
                              ),
                            ),
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
                          
                          // AI Suggestions Card
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
                                      'AI Önerileri',
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
                                          onPressed: () => context.read<AIProvider>().getMamaOnerisi(_pet),
                                          icon: Icons.restaurant,
                                          label: 'Mama Önerisi',
                                          color: Colors.orange,
                                        ),
                                        _buildActionButton(
                                          onPressed: () => context.read<AIProvider>().getOyunOnerisi(_pet),
                                          icon: Icons.sports_esports,
                                          label: 'Oyun Önerisi',
                                          color: Colors.indigo,
                                        ),
                                        _buildActionButton(
                                          onPressed: () => context.read<AIProvider>().getBakimOnerisi(_pet),
                                          icon: Icons.auto_awesome,
                                          label: 'Bakım Önerisi',
                                          color: Colors.teal,
                                        ),
                                        _buildActionButton(
                                          onPressed: () => soruSorDialog(),
                                          icon: Icons.question_answer,
                                          label: 'Soru Sor',
                                          color: theme.colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // AI Response
                          Consumer<AIProvider>(
                            builder: (context, aiProvider, child) {
                              final aiResponse = aiProvider.getCurrentResponseForPet(_pet.name);
                              if (aiProvider.isLoading) {
                                return Card(
                                  elevation: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: isDark ? Colors.grey.shade800 : Colors.white,
                                    ),
                                    child: const Row(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(width: 16),
                                        Text('AI düşünüyor...'),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              if (aiResponse != null && aiResponse.isNotEmpty) {
                                return Card(
                                  elevation: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: isDark ? Colors.grey.shade800 : Colors.white,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AI Yanıtı:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          aiResponse,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: aiProvider.isSpeaking
                                                    ? () => aiProvider.stopSpeaking()
                                                    : () async {
                                                        if (aiResponse.isNotEmpty) {
                                                          await aiProvider.speakResponse(aiResponse);
                                                        }
                                                      },
                                                icon: Icon(
                                                  aiProvider.isSpeaking ? Icons.stop : Icons.volume_up,
                                                  size: 18,
                                                ),
                                                label: Text(
                                                  aiProvider.isSpeaking ? 'Durdur' : 'Sesli Dinle',
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              onPressed: () => aiProvider.clearResponseForPet(_pet.name),
                                              icon: const Icon(Icons.clear, size: 16),
                                              label: const Text('Temizle'),
                                              style: TextButton.styleFrom(foregroundColor: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
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
}
