import 'dart:convert';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../secrets.dart';

final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

Future<void> initRecorder() async {
  var status = await Permission.microphone.request();
  if (!status.isGranted) {
    throw Exception('Mikrofon izni verilmedi!');
  }
  if (_recorder.isStopped) {
    await _recorder.openRecorder();
  }
}

Future<String?> recordAndGetBase64({int seconds = 5}) async {
  await initRecorder(); // Her zaman önce çağır!
  final tempPath = '/sdcard/temp_audio.wav';
  await _recorder.startRecorder(
    toFile: tempPath,
    codec: Codec.pcm16WAV,
    sampleRate: 16000,
  );
  await Future.delayed(Duration(seconds: seconds));
  final path = await _recorder.stopRecorder();
  if (path == null) return null;
  final bytes = await File(path).readAsBytes();
  return base64Encode(bytes);
}

Future<String?> googleSpeechToText(String base64Audio) async {
  final url = 'https://speech.googleapis.com/v1/speech:recognize?key=$googleSpeechApiKey';
  final body = jsonEncode({
    "config": {
      "encoding": "LINEAR16",
      "sampleRateHertz": 16000,
      "languageCode": "tr-TR"
    },
    "audio": {
      "content": base64Audio
    }
  });

  final response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['results'] != null && data['results'].isNotEmpty) {
      return data['results'][0]['alternatives'][0]['transcript'];
    }
  }
  return null;
} 