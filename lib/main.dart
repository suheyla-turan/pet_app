import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/pet/screens/pet_list_page.dart';
import 'services/notification_service.dart';
import 'services/firebase_config.dart';
import 'providers/pet_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Güvenli Firebase başlatma
  await FirebaseConfig.initialize();
  
  await NotificationService.initialize();
  runApp(const MiniPetApp());
}

class MiniPetApp extends StatelessWidget {
  const MiniPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, PetProvider>(
          create: (_) => PetProvider(),
          update: (_, settingsProvider, petProvider) {
            petProvider?.setSettingsProvider(settingsProvider);
            return petProvider ?? PetProvider();
          },
        ),
        ChangeNotifierProxyProvider<SettingsProvider, AIProvider>(
          create: (_) => AIProvider(),
          update: (_, settingsProvider, aiProvider) {
            aiProvider?.setSettingsProvider(settingsProvider);
            return aiProvider ?? AIProvider();
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Mini Pet',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const PetListPage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
} 