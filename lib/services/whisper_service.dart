import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../secrets.dart';
import 'dart:async'; // Timer için

class WhisperService {
  static const String _baseUrl = 'https://api.openai.com/v1/audio/transcriptions';
  
  static final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  static bool _isInitialized = false;
  
  // Rate limit yönetimi için
  static DateTime? _lastRequestTime;
  static const int _minRequestInterval = 10; // 10 saniye (test için daha kısa)
  static const int _maxRetries = 3;

  // Global ses servisi durumu yönetimi
  static bool _isAnyVoiceServiceActive = false;
  static String? _activeServiceName;
  static DateTime? _lockAcquiredTime;
  static Timer? _autoReleaseTimer;
  
  static bool get isAnyVoiceServiceActive => _isAnyVoiceServiceActive;
  static String? get activeServiceName => _activeServiceName;

  // Ses servisi kilidi alma
  static bool acquireVoiceLock(String serviceName) {
    if (_isAnyVoiceServiceActive) {
      print('⚠️ Ses servisi zaten aktif: $_activeServiceName, istenen: $serviceName');
      return false;
    }
    
    // Eğer 5 dakikadan fazla süre geçmişse kilidi zorla temizle
    if (_lockAcquiredTime != null) {
      final duration = DateTime.now().difference(_lockAcquiredTime!).inMinutes;
      if (duration >= 5) {
        print('⏰ Kilidi zorla temizleme (${duration} dakika geçti)');
        releaseVoiceLock();
      }
    }
    
    _isAnyVoiceServiceActive = true;
    _activeServiceName = serviceName;
    _lockAcquiredTime = DateTime.now();
    
    // Otomatik temizleme timer'ı (5 dakika sonra)
    _autoReleaseTimer?.cancel();
    _autoReleaseTimer = Timer(Duration(minutes: 5), () {
      print('⏰ Otomatik ses kilidi temizleme (5 dakika geçti)');
      releaseVoiceLock();
    });
    
    print('🔒 Ses kilidi alındı: $serviceName');
    return true;
  }

  // Ses servisi kilidini serbest bırakma
  static void releaseVoiceLock() {
    if (_isAnyVoiceServiceActive) {
      print('🔓 Ses kilidi serbest bırakıldı: $_activeServiceName');
      _isAnyVoiceServiceActive = false;
      _activeServiceName = null;
      _lockAcquiredTime = null;
      
      // Timer'ı temizle
      _autoReleaseTimer?.cancel();
      _autoReleaseTimer = null;
    }
  }

  // Zorla tüm ses servislerini temizle
  static void forceReleaseAllVoiceLocks() {
    print('🛑 Tüm ses kilitleri zorla temizleniyor...');
    releaseVoiceLock();
    
    // Recorder'ı da durdur
    if (_recorder.isRecording) {
      _recorder.stopRecorder();
    }
  }

  // Ses kilidi durumunu kontrol et
  static String getVoiceLockStatus() {
    if (!_isAnyVoiceServiceActive) {
      return 'Ses servisi aktif değil';
    }
    
    final duration = _lockAcquiredTime != null 
        ? DateTime.now().difference(_lockAcquiredTime!).inSeconds 
        : 0;
    
    return 'Aktif servis: $_activeServiceName (${duration}s)';
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('🔧 WhisperService başlatılıyor...');
    
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      print('❌ Mikrofon izni verilmedi!');
      throw Exception('Mikrofon izni verilmedi! Lütfen ayarlardan mikrofon iznini verin.');
    }
    
    print('✅ Mikrofon izni verildi');
    
    if (_recorder.isStopped) {
      print('🎤 Recorder açılıyor...');
      await _recorder.openRecorder();
      print('✅ Recorder açıldı');
    }
    
    _isInitialized = true;
    print('✅ WhisperService başlatıldı');
  }

  static Future<String?> recordAndTranscribe({int seconds = 5}) async {
    // Ses kilidi kontrolü
    if (!acquireVoiceLock('WhisperService')) {
      print('❌ Ses servisi meşgul, kayıt başlatılamıyor');
      return null;
    }
    
    try {
      print('🔧 WhisperService.recordAndTranscribe başlatılıyor...');
      await initialize();
      
      // Geçici dosya yolu - platform bağımsız
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      print('📁 Geçici dosya yolu: $tempPath');
      
      // Recorder durumunu kontrol et
      print('🎤 Recorder durumu: isRecording=${_recorder.isRecording}, isStopped=${_recorder.isStopped}');
      
      // Kayıt başlat
      print('🎤 Kayıt başlatılıyor...');
      await _recorder.startRecorder(
        toFile: tempPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1, // Mono kayıt (daha iyi tanıma)
      );
      
      print('✅ Kayıt başlatıldı, $seconds saniye bekleniyor...');
      print('🎤 Kayıt sırasında recorder durumu: isRecording=${_recorder.isRecording}');
      
      // Belirtilen süre kadar bekle
      await Future.delayed(Duration(seconds: seconds));
      
      // Kayıt durdur
      print('🛑 Kayıt durduruluyor...');
      final path = await _recorder.stopRecorder();
      if (path == null) {
        print('❌ Kayıt durdurulamadı, path null');
        return null;
      }
      
      print('✅ Kayıt tamamlandı: $path');
      
      // Dosya boyutunu kontrol et
      final file = File(path);
      if (await file.exists()) {
        final fileSize = await file.length();
        print('📊 Dosya boyutu: $fileSize bytes');
        
        if (fileSize < 2000) { // 2KB'dan küçük dosyalar için uyarı
          print('⚠️ Dosya çok küçük ($fileSize bytes), muhtemelen ses kaydedilmedi');
          print('🔍 Dosya içeriği kontrol ediliyor...');
          try {
            final bytes = await file.readAsBytes();
            print('🔍 Dosya ilk 100 byte: ${bytes.take(100).toList()}');
          } catch (e) {
            print('❌ Dosya okuma hatası: $e');
          }
          return null;
        }
      } else {
        print('❌ Ses dosyası bulunamadı: $path');
        return null;
      }
      
      // Whisper API'ye gönder
      print('🔄 Whisper API\'ye gönderiliyor...');
      final transcription = await _transcribeAudio(path);
      
      if (transcription != null && transcription.isNotEmpty) {
        print('✅ Transkripsiyon başarılı: $transcription');
      } else {
        print('❌ Transkripsiyon boş veya null');
      }
      
      // Geçici dosyayı sil
      try {
        if (await file.exists()) {
          await file.delete();
          print('✅ Geçici dosya silindi: $path');
        } else {
          print('⚠️ Geçici dosya zaten mevcut değil: $path');
        }
      } catch (e) {
        print('❌ Geçici dosya silinemedi: $e');
      }
      
      return transcription;
    } catch (e) {
      print('❌ Ses kayıt hatası: $e');
      print('🔍 Hata detayı: ${e.runtimeType}');
      return null;
    } finally {
      // Ses kilidini serbest bırak
      releaseVoiceLock();
    }
  }

  static Future<String?> _transcribeAudio(String audioPath) async {
    int retryCount = 0;
    
    print('🔧 _transcribeAudio başlatılıyor...');
    
    // API key kontrolü
    if (openaiApiKey == 'YOUR_OPENAI_API_KEY_HERE' || openaiApiKey.isEmpty) {
      print('❌ OpenAI API key ayarlanmamış! Lütfen lib/secrets.dart dosyasına gerçek API key\'inizi ekleyin.');
      return null;
    }
    
    // API key format kontrolü
    if (!openaiApiKey.startsWith('sk-')) {
      print('❌ OpenAI API key formatı yanlış! API key "sk-" ile başlamalı.');
      print('🔑 Mevcut API key: ${openaiApiKey.substring(0, 10)}...');
      return null;
    }
    
    print('🔑 API Key kontrol edildi: ${openaiApiKey.substring(0, 10)}...');
    print('🔑 API Key uzunluğu: ${openaiApiKey.length} karakter');
    print('🔑 API Key formatı: ${openaiApiKey.startsWith('sk-') ? 'Doğru' : 'Yanlış'}');
    
    while (retryCount <= _maxRetries) {
      try {
        print('🔄 Transcription denemesi ${retryCount + 1}/${_maxRetries + 1}');
        
        // Rate limit kontrolü
        if (_lastRequestTime != null) {
          final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!).inSeconds;
          if (timeSinceLastRequest < _minRequestInterval) {
            final waitTime = _minRequestInterval - timeSinceLastRequest;
            print('⏳ Rate limit nedeniyle $waitTime saniye bekleniyor...');
            await Future.delayed(Duration(seconds: waitTime));
          }
        }
        
        final audioFile = File(audioPath);
        if (!await audioFile.exists()) {
          print('❌ Ses dosyası bulunamadı: $audioPath');
          return null;
        }

        final bytes = await audioFile.readAsBytes();
        print('📊 Ses dosyası boyutu: ${bytes.length} bytes');
        
        // Dosya formatını kontrol et
        if (bytes.length > 4) {
          final header = bytes.take(4).toList();
          print('🔍 Dosya header: $header');
          // WAV dosyası header kontrolü (RIFF)
          if (header[0] == 82 && header[1] == 73 && header[2] == 70 && header[3] == 70) {
            print('✅ WAV dosya formatı doğrulandı');
          } else {
            print('⚠️ WAV dosya formatı doğrulanamadı, header: $header');
          }
        }
        
        // Multipart request oluştur
        final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
        
        // Authorization header ekle
        request.headers['Authorization'] = 'Bearer $openaiApiKey';
        print('🔑 Authorization header eklendi');
        
        // Ses dosyasını ekle
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'audio.wav',
          ),
        );
        print('📎 Ses dosyası request\'e eklendi');
        
        // Model parametresi ekle
        request.fields['model'] = 'whisper-1';
        request.fields['language'] = 'tr';
        request.fields['response_format'] = 'json';
        print('⚙️ Request parametreleri eklendi: model=whisper-1, language=tr');

        print('🌐 Whisper API isteği gönderiliyor... (Deneme ${retryCount + 1}/${_maxRetries + 1})');
        print('🌐 API URL: $_baseUrl');
        _lastRequestTime = DateTime.now();
        
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print('📡 API yanıt kodu: ${response.statusCode}');
        print('📡 Response headers: ${response.headers}');
        
        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          final text = data['text']?.toString().trim();
          print('✅ API yanıtı başarılı: $text');
          print('✅ Response data: $data');
          return text;
        } else if (response.statusCode == 429) {
          // Rate limit hatası
          print('⚠️ Rate limit hatası (429) alındı');
          print('⚠️ Response body: $responseBody');
          
          if (retryCount < _maxRetries) {
            // Exponential backoff ile bekle
            final waitTime = pow(2, retryCount) * 5; // 5, 10, 20 saniye
            print('⏳ ${waitTime.toInt()} saniye sonra tekrar deneniyor...');
            await Future.delayed(Duration(seconds: waitTime.toInt()));
            retryCount++;
            continue;
          } else {
            print('❌ Maksimum deneme sayısına ulaşıldı');
            return null;
          }
        } else {
          print('❌ Whisper API hatası: ${response.statusCode} - $responseBody');
          print('❌ Response headers: ${response.headers}');
          
          // Özel hata mesajları
          if (response.statusCode == 400) {
            print('❌ Bad Request: Ses dosyası formatı veya boyutu uygun değil');
          } else if (response.statusCode == 401) {
            print('❌ Unauthorized: API key geçersiz veya eksik');
          } else if (response.statusCode == 403) {
            print('❌ Forbidden: API key yetkisi yok');
          } else if (response.statusCode == 413) {
            print('❌ Payload Too Large: Ses dosyası çok büyük');
          } else if (response.statusCode == 500) {
            print('❌ Internal Server Error: OpenAI sunucu hatası');
          }
          
          return null;
        }
      } catch (e) {
        print('❌ Transcription hatası: $e');
        print('🔍 Hata türü: ${e.runtimeType}');
        
        if (retryCount < _maxRetries) {
          final waitTime = pow(2, retryCount) * 2; // 2, 4, 8 saniye
          print('⏳ Hata nedeniyle ${waitTime.toInt()} saniye sonra tekrar deneniyor...');
          await Future.delayed(Duration(seconds: waitTime.toInt()));
          retryCount++;
          continue;
        } else {
          return null;
        }
      }
    }
    
    return null;
  }

  // Basit ses kayıt test fonksiyonu
  static Future<String?> testSimpleRecording({int seconds = 3}) async {
    print('🧪 Basit ses kayıt testi başlatılıyor...');
    
    try {
      await initialize();
      
      // Geçici dosya yolu
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/test_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      print('📁 Test dosya yolu: $tempPath');
      
      // Kayıt başlat
      print('🎤 Test kayıt başlatılıyor...');
      await _recorder.startRecorder(
        toFile: tempPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );
      
      print('✅ Test kayıt başlatıldı, $seconds saniye bekleniyor...');
      await Future.delayed(Duration(seconds: seconds));
      
      // Kayıt durdur
      final path = await _recorder.stopRecorder();
      if (path == null) {
        print('❌ Test kayıt durdurulamadı');
        return null;
      }
      
      print('✅ Test kayıt tamamlandı: $path');
      
      // Dosya boyutunu kontrol et
      final file = File(path);
      if (await file.exists()) {
        final fileSize = await file.length();
        print('📊 Test dosya boyutu: $fileSize bytes');
        
        if (fileSize < 1000) {
          print('⚠️ Test dosyası çok küçük ($fileSize bytes)');
          return null;
        }
        
        // Dosyayı sil
        await file.delete();
        print('✅ Test dosyası silindi');
        
        return 'Test kayıt başarılı: $fileSize bytes';
      } else {
        print('❌ Test dosyası bulunamadı');
        return null;
      }
    } catch (e) {
      print('❌ Test kayıt hatası: $e');
      return null;
    }
  }

  // API key test fonksiyonu
  static Future<bool> testApiKey() async {
    print('🧪 API key test ediliyor...');
    
    // API key kontrolü
    if (openaiApiKey == 'YOUR_OPENAI_API_KEY_HERE' || openaiApiKey.isEmpty) {
      print('❌ OpenAI API key ayarlanmamış!');
      return false;
    }
    
    if (!openaiApiKey.startsWith('sk-')) {
      print('❌ OpenAI API key formatı yanlış!');
      return false;
    }
    
    try {
      // Basit bir test isteği gönder
      final request = http.Request('GET', Uri.parse('https://api.openai.com/v1/models'));
      request.headers['Authorization'] = 'Bearer $openaiApiKey';
      
      print('🌐 API test isteği gönderiliyor...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('📡 Test yanıt kodu: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ API key geçerli!');
        return true;
      } else if (response.statusCode == 401) {
        print('❌ API key geçersiz! (401 Unauthorized)');
        print('📡 Response: $responseBody');
        return false;
      } else {
        print('❌ API test hatası: ${response.statusCode}');
        print('📡 Response: $responseBody');
        return false;
      }
    } catch (e) {
      print('❌ API test hatası: $e');
      return false;
    }
  }

  static Future<void> dispose() async {
    print('🧹 WhisperService temizleniyor...');
    
    if (_recorder.isRecording) {
      print('🛑 Kayıt durduruluyor...');
      await _recorder.stopRecorder();
    }
    if (!_recorder.isStopped) {
      print('🔒 Recorder kapatılıyor...');
      await _recorder.closeRecorder();
    }
    _isInitialized = false;
    
    // Tüm ses kilitlerini zorla temizle
    forceReleaseAllVoiceLocks();
    
    print('✅ WhisperService temizlendi');
  }
} 