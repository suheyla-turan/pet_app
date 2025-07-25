import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

import 'whisper_service.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _isContinuousListening = false;
  Timer? _continuousListeningTimer;
  String _currentTranscription = '';
  
  // Callbacks
  Function(String)? onSpeechResult;
  Function(String)? onSpeechError;
  Function()? onSpeakingStarted;
  Function()? onSpeakingStopped;
  Function()? onListeningStarted;
  Function()? onListeningStopped;
  Function(String)? onContinuousTranscription; // Yeni: anlık transkripsiyon
  Function()? onContinuousListeningStarted; // Yeni: sürekli dinleme başladı
  Function()? onContinuousListeningStopped; // Yeni: sürekli dinleme durdu

  String? _currentVoice;
  double _currentRate = 0.3;
  double _currentPitch = 1.0;

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;
  bool get isContinuousListening => _isContinuousListening;
  String get currentTranscription => _currentTranscription;

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

  // Whisper ile ses kayıt ve transkripsiyon
  Future<void> startVoiceInput({int seconds = 5}) async {
    if (_isListening) {
      print('⚠️ Zaten dinliyor, durduruluyor');
      await stopVoiceInput();
    }
    
    try {
      // Global ses kilidi kontrolü
      if (WhisperService.isAnyVoiceServiceActive) {
        final activeService = WhisperService.activeServiceName ?? 'Bilinmeyen';
        final status = WhisperService.getVoiceLockStatus();
        print('❌ Ses servisi meşgul: $activeService. $status');
        onSpeechError?.call('Ses servisi meşgul: $activeService. $status');
        return;
      }
      
      _isListening = true;
      onListeningStarted?.call();
      
      print('🎤 Ses kayıt başlatılıyor...');
      final transcription = await WhisperService.recordAndTranscribe(seconds: seconds);
      
      if (transcription != null && transcription.isNotEmpty) {
        print('🎤 Transkripsiyon: $transcription');
        onSpeechResult?.call(transcription);
      } else {
        print('❌ Transkripsiyon başarısız');
        onSpeechError?.call('Ses tanıma başarısız');
      }
    } catch (e) {
      print('❌ Ses kayıt hatası: $e');
      onSpeechError?.call('Ses kayıt hatası: $e');
    } finally {
      _isListening = false;
      onListeningStopped?.call();
    }
  }

  Future<void> stopVoiceInput() async {
    if (_isListening) {
      print('🎤 Ses kayıt durduruluyor');
      await WhisperService.dispose();
      _isListening = false;
      onListeningStopped?.call();
    }
  }

  // Yeni: Sürekli ses dinleme ve anlık transkripsiyon
  Future<void> startContinuousListening() async {
    if (_isContinuousListening) {
      print('⚠️ Zaten sürekli dinliyor');
      return;
    }
    
    try {
      // Global ses kilidi kontrolü
      if (WhisperService.isAnyVoiceServiceActive) {
        final activeService = WhisperService.activeServiceName ?? 'Bilinmeyen';
        final status = WhisperService.getVoiceLockStatus();
        print('❌ Ses servisi meşgul: $activeService. $status');
        onSpeechError?.call('Ses servisi meşgul: $activeService. $status');
        return;
      }
      
      _isContinuousListening = true;
      _currentTranscription = '';
      onContinuousListeningStarted?.call();
      
      print('🎤 Sürekli ses dinleme başlatılıyor...');
      
      // Whisper servisini başlat
      await WhisperService.initialize();
      
      // Önceki timer'ı temizle
      if (_continuousListeningTimer != null) {
        _continuousListeningTimer!.cancel();
        _continuousListeningTimer = null;
      }
      
      // Her 5 saniyede bir ses kaydı yap ve transkripsiyon al (daha uzun süre)
      _continuousListeningTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (!_isContinuousListening) {
          print('⏱️ Timer durduruldu - dinleme durmuş');
          timer.cancel();
          return;
        }
        
        try {
          print('🎤 Ses kayıt başlatılıyor...');
          final transcription = await WhisperService.recordAndTranscribe(seconds: 4); // 4 saniye kayıt
          if (transcription != null && transcription.isNotEmpty) {
            _currentTranscription += ' ' + transcription;
            _currentTranscription = _currentTranscription.trim();
            print('🎤 Anlık transkripsiyon: $_currentTranscription');
            onContinuousTranscription?.call(_currentTranscription);
          } else {
            print('⚠️ Transkripsiyon boş veya null');
          }
        } catch (e) {
          print('❌ Anlık transkripsiyon hatası: $e');
          // Hata durumunda timer'ı durdurma, devam et
        }
      });
      
    } catch (e) {
      print('❌ Sürekli dinleme başlatma hatası: $e');
      _isContinuousListening = false;
      _continuousListeningTimer?.cancel();
      _continuousListeningTimer = null;
      onContinuousListeningStopped?.call();
    }
  }

  // Yeni: Sürekli dinlemeyi durdur ve final transkripsiyonu al
  Future<String?> stopContinuousListening() async {
    if (!_isContinuousListening) {
      print('⚠️ Zaten durmuş durumda');
      return null;
    }
    
    try {
      print('🎤 Sürekli dinleme durduruluyor...');
      _isContinuousListening = false;
      
      // Timer'ı hemen durdur
      if (_continuousListeningTimer != null) {
        _continuousListeningTimer!.cancel();
        _continuousListeningTimer = null;
        print('⏱️ Timer durduruldu');
      }
      
      onContinuousListeningStopped?.call();
      
      // Son bir kayıt daha yap ve transkripsiyonu tamamla (daha uzun süre)
      final finalTranscription = await WhisperService.recordAndTranscribe(seconds: 3); // 3 saniye
      if (finalTranscription != null && finalTranscription.isNotEmpty) {
        _currentTranscription += ' ' + finalTranscription;
        _currentTranscription = _currentTranscription.trim();
      }
      
      final result = _currentTranscription.isNotEmpty ? _currentTranscription : null;
      _currentTranscription = '';
      
      if (result != null) {
        print('🎤 Final transkripsiyon: $result');
        onSpeechResult?.call(result);
      }
      
      return result;
    } catch (e) {
      print('❌ Sürekli dinleme durdurma hatası: $e');
      _currentTranscription = '';
      return null;
    }
  }

  // Yeni: Anlık transkripsiyonu temizle
  void clearCurrentTranscription() {
    _currentTranscription = '';
    onContinuousTranscription?.call('');
  }

  void dispose() {
    print('🧹 VoiceService dispose ediliyor...');
    _flutterTts.stop();
    
    // Timer'ı temizle
    if (_continuousListeningTimer != null) {
      _continuousListeningTimer!.cancel();
      _continuousListeningTimer = null;
      print('⏱️ Timer dispose edildi');
    }
    
    // Dinleme durumunu sıfırla
    _isContinuousListening = false;
    _isListening = false;
    
    WhisperService.dispose();
    print('✅ VoiceService dispose edildi');
  }
} 