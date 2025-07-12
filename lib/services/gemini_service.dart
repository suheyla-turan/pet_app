import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_app/secrets.dart';
import '../providers/settings_provider.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-pro:generateContent';

  static String _getStylePrompt(ConversationStyle style) {
    switch (style) {
      case ConversationStyle.friendly:
        return 'Lütfen dostane, sıcak ve samimi bir ton kullanarak yanıt ver. Evcil hayvan sahibiyle arkadaşça konuşur gibi ol. Yanıtını kısa ve öz tut, maksimum 2-3 cümle olsun.';
      case ConversationStyle.professional:
        return 'Lütfen profesyonel, bilgilendirici ve resmi bir ton kullanarak yanıt ver. Veteriner hekim gibi uzman tavsiyesi verir gibi ol. Yanıtını kısa ve öz tut, maksimum 2-3 cümle olsun.';
      case ConversationStyle.playful:
        return 'Lütfen eğlenceli, oyuncu ve neşeli bir ton kullanarak yanıt ver. Evcil hayvanla oyun oynar gibi eğlenceli ol. Yanıtını kısa ve öz tut, maksimum 2-3 cümle olsun.';
      case ConversationStyle.caring:
        return 'Lütfen şefkatli, koruyucu ve sevgi dolu bir ton kullanarak yanıt ver. Evcil hayvanı çok seven bir aile üyesi gibi ol. Yanıtını kısa ve öz tut, maksimum 2-3 cümle olsun.';
    }
  }

  static Future<String> getSuggestion(String userInput, {ConversationStyle? style}) async {
    final conversationStyle = style ?? ConversationStyle.friendly;
    final stylePrompt = _getStylePrompt(conversationStyle);
    
    final enhancedPrompt = '''
$stylePrompt

Kullanıcı sorusu: $userInput

Lütfen yukarıdaki stilde yanıt ver ve Türkçe kullan.
''';

    final url = Uri.parse('$_baseUrl?key=$geminiApiKey');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": enhancedPrompt}
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
