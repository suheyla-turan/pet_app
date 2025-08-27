import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'features/pet/screens/pet_list_page.dart';
import 'services/notification_service.dart';
import 'services/media_service.dart';
import 'services/background_service.dart';
import 'providers/pet_provider.dart';

import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/auth/email_verification_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pati_takip/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Background callback fonksiyonu
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Firebase.initializeApp();
      
      switch (task) {
        case 'petValuesUpdate':
          await _updatePetValues();
          break;
        case 'periodicPetCheck':
          await _periodicPetCheck();
          break;
      }
      return true;
    } catch (e) {
      print('Background task error: $e');
      return false;
    }
  });
}

// Evcil hayvan değerlerini güncelle
@pragma('vm:entry-point')
Future<void> _updatePetValues() async {
  try {
    final auth = firebase_auth.FirebaseAuth.instance;
    if (auth.currentUser == null) return;

    final firestore = FirebaseFirestore.instance;
    final petsSnapshot = await firestore
        .collection('pets')
        .where('owners', arrayContains: auth.currentUser!.uid)
        .get();

    for (final doc in petsSnapshot.docs) {
      final petData = doc.data();
      final lastUpdate = DateTime.parse(petData['lastUpdate']);
      final now = DateTime.now();
      final difference = now.difference(lastUpdate).inMinutes;

      // Değerleri güncelle
      int satiety = petData['satiety'] ?? 5;
      int happiness = petData['happiness'] ?? 5;
      int energy = petData['energy'] ?? 5;
      int care = petData['care'] ?? 5;

      final satietyInterval = petData['satietyInterval'] ?? 60;
      final happinessInterval = petData['happinessInterval'] ?? 60;
      final energyInterval = petData['energyInterval'] ?? 60;
      final careInterval = petData['careInterval'] ?? 1440;

      // Değerleri güncelle
      if (difference >= satietyInterval) {
        satiety = (satiety - 1).clamp(0, 10);
      }
      if (difference >= happinessInterval) {
        happiness = (happiness - 1).clamp(0, 10);
      }
      if (difference >= energyInterval) {
        energy = (energy - 1).clamp(0, 10);
      }
      if (difference >= careInterval) {
        care = (care - 1).clamp(0, 10);
      }

      // Firestore'da güncelle
      await doc.reference.update({
        'satiety': satiety,
        'happiness': happiness,
        'energy': energy,
        'care': care,
        'lastUpdate': now.toIso8601String(),
      });
    }
  } catch (e) {
    print('Pet values update error: $e');
  }
}

// Periyodik evcil hayvan kontrolü
@pragma('vm:entry-point')
Future<void> _periodicPetCheck() async {
  try {
    final auth = firebase_auth.FirebaseAuth.instance;
    if (auth.currentUser == null) return;

    final firestore = FirebaseFirestore.instance;
    final petsSnapshot = await firestore
        .collection('pets')
        .where('owners', arrayContains: auth.currentUser!.uid)
        .get();

    for (final doc in petsSnapshot.docs) {
      final petData = doc.data();
      final lastUpdate = DateTime.parse(petData['lastUpdate']);
      final now = DateTime.now();
      final difference = now.difference(lastUpdate).inMinutes;

      // Değerleri güncelle
      int satiety = petData['satiety'] ?? 5;
      int happiness = petData['happiness'] ?? 5;
      int energy = petData['energy'] ?? 5;
      int care = petData['care'] ?? 5;

      final satietyInterval = petData['satietyInterval'] ?? 60;
      final happinessInterval = petData['happinessInterval'] ?? 60;
      final energyInterval = petData['energyInterval'] ?? 60;
      final careInterval = petData['careInterval'] ?? 1440;

      // Değerleri güncelle
      if (difference >= satietyInterval) {
        satiety = (satiety - 1).clamp(0, 10);
      }
      if (difference >= happinessInterval) {
        happiness = (happiness - 1).clamp(0, 10);
      }
      if (difference >= energyInterval) {
        energy = (energy - 1).clamp(0, 10);
      }
      if (difference >= careInterval) {
        care = (care - 1).clamp(0, 10);
      }

      // Firestore'da güncelle
      await doc.reference.update({
        'satiety': satiety,
        'happiness': happiness,
        'energy': energy,
        'care': care,
        'lastUpdate': now.toIso8601String(),
      });
    }
  } catch (e) {
    print('Periodic pet check error: $e');
  }
}

// import 'generated/l10n.dart'; // Otomatik oluşturulacak

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  
  // Güvenli Firebase başlatma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await NotificationService.initialize();
  
  // WorkManager'ı önce başlat
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  
  // Background service'i başlat
  await BackgroundService.initialize();
  
  // Servisleri sıralı başlat
  final mediaService = MediaService();
  await mediaService.initialize();
  
  runApp(const PatiTakipApp());
}

class PatiTakipApp extends StatefulWidget {
  const PatiTakipApp({super.key});

  @override
  State<PatiTakipApp> createState() => _PatiTakipAppState();
}

class _PatiTakipAppState extends State<PatiTakipApp> {


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, PetProvider>(
          create: (_) => PetProvider(),
          update: (_, settingsProvider, petProvider) {
            petProvider?.setSettingsProvider(settingsProvider);
            return petProvider ?? PetProvider();
          },
        ),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, child) {
                      return MaterialApp(
              key: ValueKey(settingsProvider.locale?.languageCode ?? 'tr'),
              title: 'PatiTakip',
              theme: themeProvider.lightTheme,
              darkTheme: themeProvider.darkTheme,
              themeMode: themeProvider.themeMode,
              // Klavye performans optimizasyonları
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    // Klavye animasyon süresini optimize et
                    viewInsets: MediaQuery.of(context).viewInsets,
                    // Klavye açılırken daha yumuşak geçiş
                    viewPadding: MediaQuery.of(context).viewPadding,
                  ),
                  child: child!,
                );
              },
              // Klavye açılırken daha iyi performans
              showPerformanceOverlay: false,
              // Klavye animasyonlarını optimize et
              showSemanticsDebugger: false,
              home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Stack(
                  children: [
                    const RootPage(),

                  ],
                );
              },
            ),
            debugShowCheckedModeBanner: false,
            locale: settingsProvider.locale ?? const Locale('tr'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            // supportedLocales: S.delegate.supportedLocales, // l10n dosyası oluşunca açılacak
          );
        },
      ),
    );
  }
} 

// Ana yönlendirme widget'ı
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _isFirstLaunch = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // İlk açılış ise onboarding'den başla
    if (_isFirstLaunch) {
      return OnboardingPage(
        initialPage: 0,
        onComplete: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isFirstLaunch', false);
          setState(() {
            _isFirstLaunch = false;
          });
        },
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Kullanıcı null ise (çıkış yapılmışsa) direkt giriş ekranına yönlendir
        if (authProvider.user == null) {
          return OnboardingPage(initialPage: 4); // 4. sayfa giriş ekranı
        }
        
        // Kullanıcı giriş yapmış ama e-posta doğrulanmamış
        if (authProvider.isLoggedInButNotVerified) {
          // E-posta doğrulanmamış kullanıcıları otomatik olarak çıkış yap
          // Bu sayede giriş ekranına yönlendirilirler
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.signOutUnverifiedUser();
          });
          return EmailVerificationScreen();
        }
        
        // Kullanıcı giriş yapmamış veya çıkış yapmış
        if (!authProvider.isAuthenticated) {
          return OnboardingPage(initialPage: 4); // 4. sayfa giriş ekranı
        }
        
        // Kullanıcı giriş yapmış ve e-posta doğrulanmış
        return PetListPage();
      },
    );
  }
} 