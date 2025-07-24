import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../secrets.dart';

class WhisperService {
  static const String _baseUrl = 'https://api.openai.com/v1/audio/transcriptions';
  
  static final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  static bool _isInitialized = false;
  
  // Rate limit yönetimi için
  static DateTime? _lastRequestTime;
  static const int _minRequestInterval = 21; // 20 saniye + 1 saniye buffer
  static const int _maxRetries = 3;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('🔧 WhisperService başlatılıyor...');
    
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      print('❌ Mikrofon izni verilmedi!');
      throw Exception('Mikrofon izni verilmedi!');
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
    try {
      await initialize();
      
      // Geçici dosya yolu - platform bağımsız
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/temp_audio.wav';
      
      print('📁 Geçici dosya yolu: $tempPath');
      
      // Kayıt başlat
      print('🎤 Kayıt başlatılıyor...');
      await _recorder.startRecorder(
        toFile: tempPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
      );
      
      print('✅ Kayıt başlatıldı, $seconds saniye bekleniyor...');
      
      // Belirtilen süre kadar bekle
      await Future.delayed(Duration(seconds: seconds));
      
      // Kayıt durdur
      final path = await _recorder.stopRecorder();
      if (path == null) {
        print('❌ Kayıt durdurulamadı, path null');
        return null;
      }
      
      print('✅ Kayıt tamamlandı: $path');
      
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
        final file = File(path);
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
      return null;
    }
  }

  static Future<String?> _transcribeAudio(String audioPath) async {
    int retryCount = 0;
    
    while (retryCount <= _maxRetries) {
      try {
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
        
        // Multipart request oluştur
        final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
        
        // Authorization header ekle
        request.headers['Authorization'] = 'Bearer $openaiApiKey';
        
        // Ses dosyasını ekle
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'audio.wav',
          ),
        );
        
        // Model parametresi ekle
        request.fields['model'] = 'whisper-1';
        request.fields['language'] = 'tr';
        request.fields['response_format'] = 'json';

        print('🌐 Whisper API isteği gönderiliyor... (Deneme ${retryCount + 1}/${_maxRetries + 1})');
        _lastRequestTime = DateTime.now();
        
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print('📡 API yanıt kodu: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          final text = data['text']?.toString().trim();
          print('✅ API yanıtı başarılı: $text');
          return text;
        } else if (response.statusCode == 429) {
          // Rate limit hatası
          print('⚠️ Rate limit hatası (429) alındı');
          
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
          return null;
        }
      } catch (e) {
        print('❌ Transcription hatası: $e');
        
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
    print('✅ WhisperService temizlendi');
  }
} 