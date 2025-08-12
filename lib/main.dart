import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/pet/screens/pet_list_page.dart';
import 'services/notification_service.dart';
import 'services/media_service.dart';
import 'providers/pet_provider.dart';

import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'features/onboarding/onboarding_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pati_takip/l10n/app_localizations.dart';

// import 'generated/l10n.dart'; // Otomatik oluşturulacak

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  
  // Güvenli Firebase başlatma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await NotificationService.initialize();
  
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
              key: ValueKey(settingsProvider.locale?.languageCode ?? 'system'),
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
            locale: settingsProvider.locale,
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
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!authProvider.isAuthenticated) {
          return OnboardingPage();
        }
        return PetListPage();
      },
    );
  }
} 