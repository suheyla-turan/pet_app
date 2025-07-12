import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  
  // Callbacks
  Function(String)? onSpeechResult;
  Function(String)? onSpeechError;
  Function()? onListeningStarted;
  Function()? onListeningStopped;
  Function()? onSpeakingStarted;
  Function()? onSpeakingStopped;

  bool get speechEnabled => _speechEnabled;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          print('❌ Konuşma tanıma hatası: $error');
          onSpeechError?.call(error.errorMsg);
        },
        onStatus: (status) {
          print('📱 Konuşma durumu: $status');
          if (status == 'listening') {
            _isListening = true;
            onListeningStarted?.call();
          } else if (status == 'notListening') {
            _isListening = false;
            onListeningStopped?.call();
          }
        },
      );

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
        print('⚠️ Türkçe TTS dili bulunamadı, İngilizce kullanılıyor');
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
      print('❌ Sesli konuşma servisi başlatılamadı: $e');
      _speechEnabled = false;
    }
  }

  Future<void> startListening() async {
    if (!_speechEnabled) {
      print('❌ Konuşma tanıma etkin değil');
      onSpeechError?.call('Konuşma tanıma etkin değil');
      return;
    }

    if (_isListening) {
      print('⚠️ Zaten dinleniyor');
      return;
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            final recognizedWords = result.recognizedWords;
            print('🎤 Tanınan kelimeler: $recognizedWords');
            onSpeechResult?.call(recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: "tr_TR",
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      print('❌ Dinleme başlatılamadı: $e');
      onSpeechError?.call('Dinleme başlatılamadı: $e');
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  Future<void> speak(String text) async {
    print('🎤 Sesli okuma başlatılıyor: $text');
    
    if (_isSpeaking) {
      print('⚠️ Zaten konuşuyor, durduruluyor');
      await _flutterTts.stop();
    }

    try {
      // Metni temizle ve optimize et
      final cleanText = text.trim();
      if (cleanText.isEmpty) {
        print('❌ Boş metin, okuma yapılmıyor');
        return;
      }
      
      // Uzun metinleri kısalt
      String shortText = cleanText;
      if (cleanText.length > 200) {
        // İlk 200 karakteri al ve cümle sonunda kes
        shortText = cleanText.substring(0, 200);
        final lastPeriod = shortText.lastIndexOf('.');
        final lastExclamation = shortText.lastIndexOf('!');
        final lastQuestion = shortText.lastIndexOf('?');
        
        final lastSentenceEnd = [lastPeriod, lastExclamation, lastQuestion]
            .where((i) => i > 0)
            .reduce((a, b) => a > b ? a : b);
            
        if (lastSentenceEnd > 0) {
          shortText = shortText.substring(0, lastSentenceEnd + 1);
        }
        
        print('🎤 Uzun metin kısaltıldı: ${cleanText.length} -> ${shortText.length} karakter');
      }
      
      // Önce Türkçe dene
      print('🎤 Türkçe TTS deneniyor...');
      await _flutterTts.setLanguage("tr-TR");
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.3);
      
      print('🎤 TTS çağrısı yapılıyor...');
      print('🎤 Okunacak metin: $shortText');
      final result = await _flutterTts.speak(shortText);
      print('🎤 TTS sonucu: $result');
      
      if (result != 1) {
        print('❌ Türkçe TTS başarısız, İngilizce deneniyor...');
        await _flutterTts.setLanguage("en-US");
        final result2 = await _flutterTts.speak("Hello, this is a test message.");
        print('🎤 İngilizce TTS sonucu: $result2');
        
        if (result2 != 1) {
          print('❌ TTS başlatılamadı');
          onSpeechError?.call('Sesli okuma başlatılamadı');
        }
      }
    } catch (e) {
      print('❌ Konuşma hatası: $e');
      onSpeechError?.call('Konuşma hatası: $e');
    }
  }

  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      print('🎤 Konuşma durduruluyor');
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
  }
} 