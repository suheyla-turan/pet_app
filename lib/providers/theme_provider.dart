import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)];
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF6B46C1), // Beautiful purple
      brightness: Brightness.light,
      // Klavye performans optimizasyonları
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent, // Şeffaf app bar - ana menü gibi
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: const Color(0xFF6B46C1).withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shadowColor: const Color(0xFF6B46C1).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF9F7AEA), // Lighter purple for dark mode
      brightness: Brightness.dark,
      // Klavye performans optimizasyonları
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF2D3748), // Dark background for better contrast
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: const Color(0xFF9F7AEA).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shadowColor: const Color(0xFF9F7AEA).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF9F7AEA),
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF9F7AEA), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  // Optional: for migration, keep a helper
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Main homepage background gradient - Ana menü ile aynı
  LinearGradient getBackgroundGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark 
        ? [
            const Color(0xFF0F1419), // Ana menü koyu tema
            const Color(0xFF1A202C), 
            const Color(0xFF2D3748),
          ]
        : [
            const Color(0xFFF8FAFC), // Ana menü açık tema
            const Color(0xFFF1F5F9), 
            const Color(0xFFE2E8F0),
          ],
    );
  }

  // Alternative background gradient - Ana menü varyasyonu
  LinearGradient getAlternativeBackgroundGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark 
        ? [
            const Color(0xFF1A202C), // Ana menü tonları
            const Color(0xFF2D3748), 
            const Color(0xFF4A5568),
          ]
        : [
            const Color(0xFFF1F5F9), // Ana menü tonları
            const Color(0xFFE2E8F0), 
            const Color(0xFFCBD5E0),
          ],
    );
  }

  // Background decoration helper
  BoxDecoration getBackgroundDecoration(bool isDark) {
    return BoxDecoration(
      gradient: getBackgroundGradient(isDark),
    );
  }

  // Alternative background decoration
  BoxDecoration getAlternativeBackgroundDecoration(bool isDark) {
    return BoxDecoration(
      gradient: getAlternativeBackgroundGradient(isDark),
    );
  }

  // Solid background color - Ana menü tarzı
  Color getSolidBackgroundColor(bool isDark) {
    return isDark 
      ? const Color(0xFF1A202C) // Ana menü koyu tema
      : const Color(0xFFF8FAFC); // Ana menü açık tema
  }

  // Ana menü card colors
  Color getCardBackgroundColor(bool isDark) {
    return isDark 
      ? Colors.grey.shade800 // Ana menüdeki kart rengi
      : Colors.white; // Ana menüdeki kart rengi
  }

  // Ana menü container colors
  Color getContainerBackgroundColor(bool isDark) {
    return isDark 
      ? Colors.grey.shade700 // Ana menüdeki container rengi
      : Colors.white; // Ana menüdeki container rengi
  }

  // Ana menü text colors
  Color getPrimaryTextColor(bool isDark) {
    return isDark 
      ? Colors.white // Ana menüdeki ana metin rengi
      : const Color(0xFF2D3748); // Ana menüdeki ana metin rengi
  }

  Color getSecondaryTextColor(bool isDark) {
    return isDark 
      ? Colors.grey.shade300 // Ana menüdeki ikincil metin rengi
      : Colors.grey.shade600; // Ana menüdeki ikincil metin rengi
  }

  // Ana menü shadow colors
  Color getShadowColor(bool isDark) {
    return Colors.black.withValues(alpha: isDark ? 0.3 : 0.08);
  }

  // Gelişmiş okunabilirlik için kart arka planı
  Color getReadableCardBackgroundColor(bool isDark) {
    return isDark 
      ? Colors.grey.shade800.withValues(alpha: 0.9) // Daha opak
      : Colors.white.withValues(alpha: 0.95); // Daha opak
  }

  // Okunabilirlik için güçlendirilmiş metin renkleri
  Color getHighContrastTextColor(bool isDark) {
    return isDark 
      ? Colors.white // Maksimum kontrast
      : const Color(0xFF1A202C); // Daha koyu, daha okunabilir
  }

  Color getHighContrastSecondaryTextColor(bool isDark) {
    return isDark 
      ? Colors.grey.shade200 // Daha açık
      : Colors.grey.shade700; // Daha koyu
  }

  // Güçlendirilmiş gölge efekti
  List<BoxShadow> getReadableCardShadow(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
        blurRadius: 25,
        offset: const Offset(0, 10),
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Profile/settings pages - Ana menü tarzı varyasyon
  LinearGradient getWarmBackgroundGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark 
        ? [
            const Color(0xFF0F1419), // Ana menü temel renkleri
            const Color(0xFF1A202C), 
            const Color(0xFF2D3748),
          ]
        : [
            const Color(0xFFF8FAFC), // Ana menü temel renkleri
            const Color(0xFFF1F5F9), 
            const Color(0xFFE2E8F0),
          ],
    );
  }

  // Technical pages - Ana menü tarzı koyu varyasyon
  LinearGradient getCoolBackgroundGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark 
        ? [
            const Color(0xFF0F1419), // Ana menü koyu tonlar
            const Color(0xFF1A202C), 
            const Color(0xFF2D3748),
          ]
        : [
            const Color(0xFFF8FAFC), // Ana menü açık tonlar
            const Color(0xFFF1F5F9), 
            const Color(0xFFE2E8F0),
          ],
    );
  }
} 