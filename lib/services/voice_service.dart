import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isSpeaking = false;
  
  // Callbacks
  Function()? onSpeakingStarted;
  Function()? onSpeakingStopped;

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
        print('⚠️ Boş metin, okuma yapılmıyor');
        return;
      }

      // Parametreleri ayarla
      if (voice != null) await _flutterTts.setVoice({"name": voice, "locale": "tr-TR"});
      if (rate != null) await _flutterTts.setSpeechRate(rate);
      if (pitch != null) await _flutterTts.setPitch(pitch);

      print('🎤 TTS parametreleri ayarlandı, okuma başlatılıyor');
      await _flutterTts.speak(cleanText);
      print('✅ TTS okuma başlatıldı');
    } catch (e) {
      print('❌ TTS okuma hatası: $e');
      _isSpeaking = false;
      onSpeakingStopped?.call();
    }
  }

  Future<void> stop() async {
    try {
      if (_isSpeaking) {
        await _flutterTts.stop();
        _isSpeaking = false;
        print('🛑 TTS durduruldu');
      }
    } catch (e) {
      print('❌ TTS durdurma hatası: $e');
    }
  }

  Future<void> pause() async {
    try {
      if (_isSpeaking) {
        await _flutterTts.pause();
        print('⏸️ TTS duraklatıldı');
      }
    } catch (e) {
      print('❌ TTS duraklatma hatası: $e');
    }
  }



  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
      print('🌍 TTS dili ayarlandı: $language');
    } catch (e) {
      print('❌ TTS dil ayarlama hatası: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
      print('⚡ TTS hızı ayarlandı: $rate');
    } catch (e) {
      print('❌ TTS hız ayarlama hatası: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
      print('🔊 TTS ses seviyesi ayarlandı: $volume');
    } catch (e) {
      print('❌ TTS ses seviyesi ayarlama hatası: $e');
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
      print('🎵 TTS perdesi ayarlandı: $pitch');
    } catch (e) {
      print('❌ TTS perde ayarlama hatası: $e');
    }
  }

  Future<List<dynamic>?> getLanguages() async {
    try {
      return await _flutterTts.getLanguages;
    } catch (e) {
      print('❌ TTS dilleri alma hatası: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getVoices() async {
    try {
      return await _flutterTts.getVoices;
    } catch (e) {
      print('❌ TTS sesleri alma hatası: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getEngines() async {
    try {
      return await _flutterTts.getEngines;
    } catch (e) {
      print('❌ TTS motorları alma hatası: $e');
      return null;
    }
  }

  void dispose() {
    _flutterTts.stop();
    print('🗑️ Voice service temizlendi');
  }
} 