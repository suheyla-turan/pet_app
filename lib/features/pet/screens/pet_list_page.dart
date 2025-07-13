import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import 'pet_detail_page.dart';
import 'pet_form_page.dart';
import 'settings_page.dart';
import '../../../providers/pet_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/ai_provider.dart';

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    
    // Provider'dan hayvanları yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().loadPets();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Evcil',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Settings Button
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade700 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsPage(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.settings,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            tooltip: 'Ayarlar',
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hayvanlarım',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tüm sevimli dostlarını burada yönet',
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
                  ],
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
                                    color: Colors.black.withOpacity(0.1),
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
                              'Hayvanlarınız yükleniyor...',
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
                                  color: Colors.black.withOpacity(0.1),
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
                                  'Henüz evcil hayvan eklemediniz',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'İlk evcil hayvanınızı eklemek için\nsağ alt köşedeki + butonuna tıklayın',
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
          label: const Text(
            'Hayvan Ekle',
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
            color: Colors.black.withOpacity(0.1),
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
                        color: Colors.black.withOpacity(0.15),
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
                        '${pet.type} • ${pet.age} yaşında • ${pet.gender}',
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
                            value: pet.hunger,
                            label: 'Açlık',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 10),
                          _buildStatusChip(
                            icon: Icons.favorite,
                            value: pet.happiness,
                            label: 'Mutluluk',
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
                            label: 'Enerji',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 10),
                          _buildStatusChip(
                            icon: Icons.healing,
                            value: pet.care,
                            label: 'Bakım',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Delete Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                    onPressed: () => _removePet(pet.name),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
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
          content: Text('Hayvan silinirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 