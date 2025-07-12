import 'package:flutter/foundation.dart';
import '../services/gemini_service.dart';

class AIProvider with ChangeNotifier {
  String? _currentResponse;
  bool _isLoading = false;

  String? get currentResponse => _currentResponse;
  bool get isLoading => _isLoading;

  Future<void> getSuggestion(String prompt) async {
    _setLoading(true);
    _currentResponse = null;
    notifyListeners();

    try {
      final response = await GeminiService.getSuggestion(prompt);
      _currentResponse = response;
    } catch (e) {
      _currentResponse = 'Hata: $e';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> getMamaOnerisi(String petName, String petType) async {
    await getSuggestion('$petName adlı $petType için mama önerisi verir misin?');
  }

  Future<void> getOyunOnerisi(String petName, String petType) async {
    await getSuggestion('$petName adlı $petType için oyun önerisi verir misin?');
  }

  Future<void> getBakimOnerisi(String petName, String petType) async {
    await getSuggestion('$petName adlı $petType için bakım önerisi verir misin?');
  }

  void clearResponse() {
    _currentResponse = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
  }
} 