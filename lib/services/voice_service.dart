import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pet_app/l10n/app_localizations.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isSpeaking = false;
  
  // Callbacks
  Function(String)? onSpeechResult;
  Function(String)? onSpeechError;
  Function()? onSpeakingStarted;
  Function()? onSpeakingStopped;

  String? _currentVoice;
  double _currentRate = 0.3;
  double _currentPitch = 1.0;

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    try {
      // TTS ayarları - daha kapsamlı
      await _flutterTts.setLanguage("tr-TR");
      await _flutterTts.setSpeechRate(0.3); // Daha yavaş okuma
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      // Mevcut dilleri kontrol et
      final languages = await _flutterTts.getLanguages;
      print('📱 Mevcut TTS dilleri: $languages');
      
      // Mevcut motorları kontrol et
      final engines = await _flutterTts.getEngines;
      print('📱 Mevcut TTS motorları: $engines');
      
      // Türkçe yoksa İngilizce kullan
      if (languages != null && !languages.contains("tr-TR")) {
        // TODO: Inject localization here for TTS language not found
        print('Turkish TTS language not found, using English instead');
        await _flutterTts.setLanguage("en-US");
      }
      
      // Ses seviyesini maksimuma çıkar
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.3);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        print('🎤 TTS başladı');
        _isSpeaking = true;
        onSpeakingStarted?.call();
      });

      _flutterTts.setCompletionHandler(() {
        print('🎤 TTS tamamlandı');
        _isSpeaking = false;
        onSpeakingStopped?.call();
      });

      _flutterTts.setErrorHandler((msg) {
        print('❌ TTS hatası: $msg');
        _isSpeaking = false;
        onSpeakingStopped?.call();
      });

      print('✅ Sesli konuşma servisi başlatıldı');
    } catch (e) {
      // TODO: Inject localization here for TTS service failed
      print('Voice service could not be started: $e');
      _isSpeaking = false; // Ensure _isSpeaking is false on failure
    }
  }

  Future<void> speak(String text, {String? voice, double? rate, double? pitch}) async {
    print('🎤 Sesli okuma başlatılıyor: $text');
    if (_isSpeaking) {
      print('⚠️ Zaten konuşuyor, durduruluyor');
      await _flutterTts.stop();
    }
    try {
      final cleanText = text.trim();
      if (cleanText.isEmpty) {
        print('❌ Boş metin, okuma yapılmıyor');
        return;
      }
      // Metni 200 karakterlik cümle sonlarına göre parçalara ayır
      List<String> chunks = [];
      int start = 0;
      while (start < cleanText.length) {
        int end = start + 200;
        if (end >= cleanText.length) {
          chunks.add(cleanText.substring(start));
          break;
        }
        // 200. karakterden geriye doğru ilk nokta, ünlem veya soru işareti bul
        int lastPeriod = cleanText.lastIndexOf('.', end);
        int lastExclamation = cleanText.lastIndexOf('!', end);
        int lastQuestion = cleanText.lastIndexOf('?', end);
        int lastSentenceEnd = [lastPeriod, lastExclamation, lastQuestion]
            .where((i) => i >= start)
            .fold(-1, (a, b) => a > b ? a : b);
        if (lastSentenceEnd > start) {
          chunks.add(cleanText.substring(start, lastSentenceEnd + 1));
          start = lastSentenceEnd + 1;
        } else {
          // Cümle sonu yoksa 200 karakterlik parça al
          chunks.add(cleanText.substring(start, end));
          start = end;
        }
      }
      // TTS ayarlarını uygula
      await _flutterTts.setLanguage("tr-TR");
      await setVoice(voice ?? _currentVoice);
      await setRate(rate ?? _currentRate);
      await setPitch(pitch ?? _currentPitch);
      // Parçaları sırayla oku
      for (final chunk in chunks) {
        print('🎤 Okunacak parça: $chunk');
        final result = await _flutterTts.speak(chunk);
        // TTS tamamlanana kadar bekle
        await _waitForTtsCompletion();
        if (result != 1) {
          print('❌ Türkçe TTS başarısız, İngilizce deneniyor...');
          await _flutterTts.setLanguage("en-US");
          await setVoice(null);
          final result2 = await _flutterTts.speak("Hello, this is a test message.");
          print('🎤 İngilizce TTS sonucu: $result2');
          if (result2 != 1) {
            print('❌ TTS başlatılamadı');
            onSpeechError?.call('Sesli okuma başlatılamadı');
          }
        }
      }
    } catch (e) {
      print('❌ Konuşma hatası: $e');
      onSpeechError?.call('Konuşma hatası: $e');
    }
  }

  Future<void> _waitForTtsCompletion() async {
    // TTS konuşması bitene kadar bekle
    while (_isSpeaking) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      print('🎤 Konuşma durduruluyor');
      await _flutterTts.stop();
      _isSpeaking = false;
      onSpeakingStopped?.call(); // Ensure UI updates immediately
    }
  }

  Future<List<dynamic>> getAvailableVoices() async {
    return await _flutterTts.getVoices;
  }

  Future<void> setVoice(String? voice) async {
    _currentVoice = voice;
    if (voice != null) {
      await _flutterTts.setVoice({"name": voice});
    }
  }

  Future<void> setRate(double rate) async {
    _currentRate = rate;
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    _currentPitch = pitch;
    await _flutterTts.setPitch(pitch);
  }

  void dispose() {
    _flutterTts.stop();
  }
} 