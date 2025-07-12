import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_app/secrets.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-pro:generateContent';

  static Future<String> getSuggestion(String userInput) async {
    final url = Uri.parse('$_baseUrl?key=$geminiApiKey');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": userInput}
          ]
        }
      ]
    });

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return 'Hata: ${response.body}';
      }
    } catch (e) {
      return 'Bağlantı hatası veya zaman aşımı: $e';
    }
  }
}
