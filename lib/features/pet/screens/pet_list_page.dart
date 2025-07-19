import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import 'pet_detail_page.dart';
import 'pet_form_page.dart';
import 'settings_page.dart';
import '../../../providers/pet_provider.dart';
import '../../profile/profile_page.dart';
import 'package:pet_app/l10n/app_localizations.dart';
import 'package:pet_app/features/pet/widgets/voice_command_widget.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt; // KALDIRILDI
import 'package:pet_app/services/realtime_service.dart';
import 'package:pet_app/widgets/ai_fab.dart';

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sesli komut için eklenenler
  // late stt.SpeechToText _speech; // KALDIRILDI
  // bool _isListening = false; // KALDIRILDI
  // String _command = ''; // KALDIRILDI
  final realtimeService = RealtimeService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    // _speech = stt.SpeechToText(); // KALDIRILDI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().loadPets();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // _speech, _isListening, _command ile ilgili kodlar ve _startListening fonksiyonu kaldırılacak

  Future<void> _handleVoiceCommand(String command) async {
    final intentData = await getIntentFromAI(command);
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
        if (pet != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PetDetailPage(pet: pet!),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hayvan bulunamadı!')),
          );
        }
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Komut anlaşılamadı: $command')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
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
                        // Uygulama adı en üstte
                        const SizedBox(height: 24),
                        Text(
                          'Patizeka',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Profil, ayarlar, mikrofon ikonları
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Profil butonu
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade700 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.person, color: Colors.deepPurple),
                                tooltip: 'Profil',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => ProfilePage()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Ayarlar butonu
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade700 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.settings, color: theme.colorScheme.primary, size: 24),
                                tooltip: AppLocalizations.of(context)!.settings,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Büyük başlık ve açıklama
                        Text(
                          AppLocalizations.of(context)!.myPets,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF2D3748),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.manageYourPets,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 80,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                        
                        // Pet List
                        Expanded(
                          child: Consumer<PetProvider>(
                            builder: (context, petProvider, child) {
                              if (petProvider.isLoading) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.grey.shade800 : Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            theme.colorScheme.primary,
                                          ),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        AppLocalizations.of(context)!.petsLoading,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              if (petProvider.pets.isEmpty) {
                                return Center(
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Container(
                                      padding: const EdgeInsets.all(40),
                                      margin: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.grey.shade800 : Colors.white,
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.pets,
                                              size: 80,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            AppLocalizations.of(context)!.noPetsAdded,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : const Color(0xFF2D3748),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            AppLocalizations.of(context)!.addPetHint,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                              
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: petProvider.pets.length,
                                itemBuilder: (context, index) {
                                  final pet = petProvider.pets[index];
                                  return FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.3),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: _animationController,
                                        curve: Interval(
                                          index * 0.1,
                                          1.0,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      )),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 20),
                                        child: _buildPetCard(pet, isDark, theme),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final newPet = await Navigator.push<Pet>(
              context,
              MaterialPageRoute(builder: (context) => const PetFormPage()),
            );
            if (newPet != null) {
              await context.read<PetProvider>().addPet(newPet);
            }
          },
          icon: const Icon(Icons.add, size: 24),
          label: Text(
            AppLocalizations.of(context)!.addPet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildPetCard(Pet pet, bool isDark, ThemeData theme) {
    return Card(
      elevation: 12,
      shadowColor: theme.colorScheme.primary.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            final updatedPet = await Navigator.push<Pet>(
              context,
              MaterialPageRoute(
                builder: (context) => PetDetailPage(pet: pet),
              ),
            );
            if (updatedPet != null) {
              context.read<PetProvider>().updatePetValues(updatedPet);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Pet Image
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: pet.imagePath != null
                        ? Image.file(
                            File(pet.imagePath!),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 45,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Pet Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pet.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          if (pet.isBirthday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.pink, Colors.purple, Colors.blue],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cake, color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    '🎉',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      Text(
                        '${getLocalizedPetType(pet.type, context)} • ${AppLocalizations.of(context)!.yearsOld(pet.age)} • ${getLocalizedGender(pet.gender, context)}',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Status Indicators
                      Row(
                        children: [
                          _buildStatusChip(
                            icon: Icons.restaurant,
                            value: pet.satiety,
                            label: AppLocalizations.of(context)!.hunger,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 10),
                          _buildStatusChip(
                            icon: Icons.favorite,
                            value: pet.happiness,
                            label: AppLocalizations.of(context)!.happiness,
                            isDark: isDark,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          _buildStatusChip(
                            icon: Icons.battery_charging_full,
                            value: pet.energy,
                            label: AppLocalizations.of(context)!.energy,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 10),
                          _buildStatusChip(
                            icon: Icons.healing,
                            value: pet.care,
                            label: AppLocalizations.of(context)!.maintenance,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Sil butonu kaldırıldı
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required int value,
    required String label,
    required bool isDark,
  }) {
    final color = value > 7 
        ? Colors.green 
        : value > 4 
            ? Colors.orange 
            : Colors.red;
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removePet(String petName) async {
    try {
      await context.read<PetProvider>().removePet(petName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.deletePetError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
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
} 