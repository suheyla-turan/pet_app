import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pati_takip/secrets.dart';
import '../providers/settings_provider.dart';
import 'package:pati_takip/features/pet/models/ai_chat_message.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

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

    final url = Uri.parse(_baseUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openaiApiKey',
    };
    
    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content": "Sen evcil hayvan bakımı konusunda uzman bir AI asistanısın. Türkçe yanıt ver ve kısa tut."
        },
        {
          "role": "user",
          "content": enhancedPrompt
        }
      ],
      "max_tokens": 150,
      "temperature": 0.7,
    });

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["choices"][0]["message"]["content"];
      } else {
        return 'Hata: ${response.body}';
      }
    } catch (e) {
      return 'Bağlantı hatası veya zaman aşımı: $e';
    }
  }

  static Future<String> getMultiTurnSuggestion({
    required pet,
    required List<AIChatMessage> history,
    ConversationStyle? style,
  }) async {
    final conversationStyle = style ?? ConversationStyle.friendly;
    final stylePrompt = _getStylePrompt(conversationStyle);
    final petInfo = '''Aşağıda evcil hayvanımın bilgileri var:
- Adı: ${pet.name}
- Türü: ${pet.type}
- Cinsiyet: ${pet.gender}
- Yaş: ${pet.age}
- Doğum Tarihi: ${pet.birthDate.day}.${pet.birthDate.month}.${pet.birthDate.year}
- Tokluk: ${pet.satiety}/10
- Mutluluk: ${pet.happiness}/10
- Enerji: ${pet.energy}/10
- Bakım: ${pet.care}/10
''';

    // OpenAI için mesaj formatını oluştur
    final messages = [
      {
        "role": "system",
        "content": "$stylePrompt\n\n$petInfo\n\nSen evcil hayvan bakımı konusunda uzman bir AI asistanısın. Türkçe yanıt ver ve kısa tut."
      }
    ];

    // Sohbet geçmişini OpenAI formatına çevir
    for (final msg in history) {
      messages.add({
        "role": msg.sender == 'user' ? 'user' : 'assistant',
        "content": msg.text,
      });
    }

    final url = Uri.parse(_baseUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openaiApiKey',
    };
    
    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": messages,
      "max_tokens": 150,
      "temperature": 0.7,
    });

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["choices"][0]["message"]["content"];
      } else {
        return 'Hata: ${response.body}';
      }
    } catch (e) {
      return 'Bağlantı hatası veya zaman aşımı: $e';
    }
  }
} 