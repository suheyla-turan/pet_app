import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  
  bool _isRecording = false;
  String? _currentRecordingPath;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  // Callbacks
  Function(String)? onImageSelected;
  Function(String, int)? onVoiceRecorded;
  Function(String)? onError;
  Function()? onRecordingStarted;
  Function()? onRecordingStopped;
  Function(int)? onRecordingDurationChanged;

  bool get isRecording => _isRecording;
  int get recordingDuration => _recordingDuration;
  
  // Diğer ses servislerinin aktif olup olmadığını kontrol et
  bool get isAnyVoiceServiceActive => _isRecording;

  Future<void> initialize() async {
    try {
      await _recorder.openRecorder();
      print('✅ Media service başlatıldı');
    } catch (e) {
      print('❌ Media service başlatılamadı: $e');
    }
  }

  // Resim seçme
  Future<String?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      // İzin kontrolü
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (status != PermissionStatus.granted) {
          onError?.call('Kamera izni gerekli');
          return null;
        }
      } else {
        final status = await Permission.photos.request();
        if (status != PermissionStatus.granted) {
          onError?.call('Galeri izni gerekli');
          return null;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final path = image.path;
        onImageSelected?.call(path);
        return path;
      }
    } catch (e) {
      print('❌ Resim seçme hatası: $e');
      onError?.call('Resim seçilemedi: $e');
    }
    return null;
  }

  // Ses kayıt başlatma
  Future<void> startVoiceRecording() async {
    try {


      // Mikrofon izni kontrolü
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        onError?.call('Mikrofon izni gerekli');
        return;
      }

      if (_isRecording) {
        await stopVoiceRecording();
      }



      // Kayıt dosyası yolu oluştur
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/voice_$timestamp.aac';

      // Kayıt başlat
      await _recorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
      );

      _isRecording = true;
      _recordingDuration = 0;
      print('🎤 Kayıt başlatıldı, süre sıfırlandı');
      onRecordingStarted?.call();

      // Süre sayacı başlat
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration++;
        print('⏱️ Kayıt süresi: ${_recordingDuration}s');
        onRecordingDurationChanged?.call(_recordingDuration);
      });

      print('🎤 Ses kayıt başlatıldı: $_currentRecordingPath');
    } catch (e) {
      print('❌ Ses kayıt başlatma hatası: $e');
      onError?.call('Ses kayıt başlatılamadı: $e');
    }
  }

  // Ses kayıt durdurma
  Future<String?> stopVoiceRecording() async {
    try {
      if (!_isRecording) return null;

      // Kayıt durdur
      final path = await _recorder.stopRecorder();
      _isRecording = false;
      _recordingTimer?.cancel();
      _recordingTimer = null;

      onRecordingStopped?.call();



      if (path != null && _recordingDuration > 0) {
        onVoiceRecorded?.call(path, _recordingDuration);
        print('🎤 Ses kayıt tamamlandı: $path (${_recordingDuration}s)');
        return path;
      }
    } catch (e) {
      print('❌ Ses kayıt durdurma hatası: $e');
      onError?.call('Ses kayıt durdurulamadı: $e');
    }
    return null;
  }

  // Ses dosyasını oynatma
  Future<void> playVoiceFile(String filePath) async {
    try {
      final player = FlutterSoundPlayer();
      await player.openPlayer();
      
      await player.startPlayer(
        fromURI: filePath,
        whenFinished: () async {
          await player.closePlayer();
        },
      );
    } catch (e) {
      print('❌ Ses oynatma hatası: $e');
      onError?.call('Ses oynatılamadı: $e');
    }
  }

  // Süre formatını string'e çevirme
  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _recordingTimer?.cancel();
    _recorder.closeRecorder();
    

  }
} 