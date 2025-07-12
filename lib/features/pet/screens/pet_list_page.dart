import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import 'pet_detail_page.dart';
import 'pet_form_page.dart';
import 'settings_page.dart';
import '../../../providers/pet_provider.dart';
import '../../../providers/theme_provider.dart';

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  @override
  void initState() {
    super.initState();
    // Provider'dan hayvanları yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().loadPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evcil Hayvanlarım'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PetProvider>().loadPets(),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          if (petProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (petProvider.pets.isEmpty) {
            return const Center(child: Text('Henüz evcil hayvan eklemediniz.'));
          }
          
          return ListView.builder(
            itemCount: petProvider.pets.length,
            itemBuilder: (context, index) {
              final pet = petProvider.pets[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: pet.imagePath != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(File(pet.imagePath!)), 
                          radius: 24,
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          radius: 24,
                          child: const Icon(Icons.pets, color: Colors.teal),
                        ),
                  title: Row(
                    children: [
                      Text(pet.name),
                      if (pet.isBirthday)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.cake, color: Colors.pink, size: 20),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tür: ${pet.type} | Yaş: ${pet.age}, Cinsiyet: ${pet.gender}'),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.restaurant, size: 16, color: pet.hunger > 7 ? Colors.red : Colors.green),
                              Text(' ${pet.hunger}/10'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite, size: 16, color: pet.happiness < 3 ? Colors.red : Colors.green),
                              Text(' ${pet.happiness}/10'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.battery_charging_full, size: 16, color: pet.energy < 3 ? Colors.red : Colors.green),
                              Text(' ${pet.energy}/10'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.healing, size: 16, color: pet.care < 3 ? Colors.red : Colors.green),
                              Text(' ${pet.care}/10'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removePet(pet.name),
                  ),
                  onTap: () async {
                    final updatedPet = await Navigator.push<Pet>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetDetailPage(pet: pet),
                      ),
                    );
                    if (updatedPet != null) {
                      petProvider.updatePetValues(updatedPet);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPet = await Navigator.push<Pet>(
            context,
            MaterialPageRoute(builder: (context) => const PetFormPage()),
          );
          if (newPet != null) {
            await context.read<PetProvider>().addPet(newPet);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _removePet(String petName) async {
    try {
      await context.read<PetProvider>().removePet(petName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hayvan silinirken hata oluştu: $e')),
      );
    }
  }
}
