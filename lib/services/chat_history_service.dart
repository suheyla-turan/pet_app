import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/pet/models/chat_history.dart';

class ChatHistoryService {
  static const String _chatHistoryKey = 'chat_history';
  static const String _currentChatKey = 'current_chat';
  
  /// Chat geçmişini kaydet
  static Future<void> saveChatHistory(ChatHistory chatHistory) async {
    try {
      print('💾 Chat geçmişi kaydediliyor: ${chatHistory.title}');
      final prefs = await SharedPreferences.getInstance();
      final existingHistory = await getChatHistory();
      
      print('📚 Mevcut chat sayısı: ${existingHistory.length}');
      
      // Mevcut chat'i güncelle veya yeni ekle
      final updatedHistory = existingHistory.where((chat) => chat.id != chatHistory.id).toList();
      updatedHistory.add(chatHistory);
      
      print('🔄 Güncellenmiş chat sayısı: ${updatedHistory.length}');
      
      // Sort by date (newest first)
      updatedHistory.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      
      // Keep only last 50 chats
      if (updatedHistory.length > 50) {
        updatedHistory.removeRange(50, updatedHistory.length);
        print('🗑️ 50\'den fazla chat olduğu için eski chat\'ler silindi');
      }
      
      final historyJson = updatedHistory.map((chat) => chat.toMap()).toList();
      final jsonString = jsonEncode(historyJson);
      print('📝 JSON string uzunluğu: ${jsonString.length}');
      
      await prefs.setString(_chatHistoryKey, jsonString);
      print('✅ Chat geçmişi başarıyla kaydedildi');
    } catch (e) {
      print('❌ Chat geçmişi kaydedilemedi: $e');
      print('❌ Hata detayı: ${e.runtimeType}');
    }
  }
  
  /// Chat geçmişini getir
  static Future<List<ChatHistory>> getChatHistory() async {
    try {
      print('🔍 Chat geçmişi getiriliyor...');
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString(_chatHistoryKey);
      
      print('📱 SharedPreferences\'dan alınan veri: $historyString');
      
      if (historyString == null || historyString.isEmpty) {
        print('⚠️ Chat geçmişi verisi bulunamadı veya boş');
        return [];
      }
      
      final historyList = jsonDecode(historyString) as List;
      print('📊 JSON decode edildi, ${historyList.length} chat bulundu');
      
      final result = historyList.map((item) {
        print('📝 Chat item: $item');
        return ChatHistory.fromMap(item, item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString());
      }).toList();
      
      print('✅ Chat geçmişi başarıyla yüklendi: ${result.length} chat');
      return result;
    } catch (e) {
      print('❌ Chat geçmişi getirilemedi: $e');
      print('❌ Hata detayı: ${e.runtimeType}');
      return [];
    }
  }
  
  /// Mevcut chat'i kaydet
  static Future<void> saveCurrentChat(String chatId, List<Map<String, dynamic>> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatData = {
        'chatId': chatId,
        'messages': messages,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString(_currentChatKey, jsonEncode(chatData));
    } catch (e) {
      print('❌ Mevcut chat kaydedilemedi: $e');
    }
  }
  
  /// Mevcut chat'i getir
  static Future<Map<String, dynamic>?> getCurrentChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatString = prefs.getString(_currentChatKey);
      
      if (chatString == null || chatString.isEmpty) {
        return null;
      }
      
      return jsonDecode(chatString);
    } catch (e) {
      print('❌ Mevcut chat getirilemedi: $e');
      return null;
    }
  }
  
  /// Chat'i sil
  static Future<void> deleteChat(String chatId) async {
    try {
      print('🗑️ ChatHistoryService.deleteChat başlatıldı: $chatId');
      
      final prefs = await SharedPreferences.getInstance();
      print('✅ SharedPreferences instance alındı');
      
      final existingHistory = await getChatHistory();
      print('📊 Mevcut chat history yüklendi: ${existingHistory.length} chat');
      
      final updatedHistory = existingHistory.where((chat) => chat.id != chatId).toList();
      print('🔄 Silinecek chat filtrelendi, kalan chat sayısı: ${updatedHistory.length}');
      
      final historyJson = updatedHistory.map((chat) => chat.toMap()).toList();
      print('📝 Chat history JSON\'a dönüştürüldü');
      
      await prefs.setString(_chatHistoryKey, jsonEncode(historyJson));
      print('💾 Chat history SharedPreferences\'a kaydedildi');
      
      print('✅ Chat başarıyla silindi: $chatId');
    } catch (e) {
      print('❌ Chat silinemedi: $e');
      print('❌ Hata detayı: ${e.runtimeType}');
      rethrow; // Hatayı yukarı fırlat
    }
  }
  
  /// Tüm chat geçmişini temizle
  static Future<void> clearAllChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
      await prefs.remove(_currentChatKey);
    } catch (e) {
      print('❌ Chat geçmişi temizlenemedi: $e');
    }
  }
  
  /// Yeni chat oluştur
  static ChatHistory createNewChat({
    String? petId,
    String? petName,
    String? title,
  }) {
    final now = DateTime.now();
    final chatId = '${now.millisecondsSinceEpoch}_${petId ?? 'general'}';
    
    return ChatHistory(
      id: chatId,
      title: title ?? (petName != null ? 'Chat with $petName' : 'New Chat'),
      createdAt: now,
      lastModified: now,
      messageCount: 0,
      petId: petId,
      petName: petName,
    );
  }

  /// Test method to check if SharedPreferences is working
  static Future<void> testSharedPreferences() async {
    try {
      print('🧪 SharedPreferences test başlatılıyor...');
      final prefs = await SharedPreferences.getInstance();
      
      // Test verisi oluştur
      final testData = {
        'test': 'data',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Test verisini kaydet
      await prefs.setString('test_key', jsonEncode(testData));
      print('✅ Test verisi kaydedildi');
      
      // Test verisini oku
      final retrievedData = prefs.getString('test_key');
      print('📱 Okunan test verisi: $retrievedData');
      
      if (retrievedData != null) {
        final decodedData = jsonDecode(retrievedData);
        print('🔍 Decode edilen test verisi: $decodedData');
      }
      
      // Test verisini temizle
      await prefs.remove('test_key');
      print('🧹 Test verisi temizlendi');
      
    } catch (e) {
      print('❌ SharedPreferences test hatası: $e');
    }
  }

  /// Debug method to show current SharedPreferences content
  static Future<void> debugSharedPreferences() async {
    try {
      print('🔍 SharedPreferences debug başlatılıyor...');
      final prefs = await SharedPreferences.getInstance();
      
      // Tüm anahtarları listele
      final keys = prefs.getKeys();
      print('🔑 Mevcut anahtarlar: $keys');
      
      // Chat history anahtarını kontrol et
      final chatHistoryData = prefs.getString(_chatHistoryKey);
      print('💬 Chat history verisi: $chatHistoryData');
      
      if (chatHistoryData != null) {
        try {
          final decoded = jsonDecode(chatHistoryData);
          print('📊 Decode edilen chat history: $decoded');
        } catch (e) {
          print('❌ Chat history decode hatası: $e');
        }
      }
      
    } catch (e) {
      print('❌ SharedPreferences debug hatası: $e');
    }
  }

  /// Create a sample chat history entry for testing
  static Future<void> createSampleChatHistory() async {
    try {
      print('🧪 Örnek chat history oluşturuluyor...');
      
      final sampleChat = ChatHistory(
        id: 'sample_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Chat - ${DateTime.now().toString().substring(0, 16)}',
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        messageCount: 2,
        petId: 'test_pet',
        petName: 'Test Pet',
        lastMessage: 'Bu bir test mesajıdır',
      );
      
      print('📝 Örnek chat oluşturuldu: ${sampleChat.title}');
      
      await saveChatHistory(sampleChat);
      
      print('✅ Örnek chat history kaydedildi');
      
      // Hemen okuyarak test et
      final retrieved = await getChatHistory();
      print('📊 Kaydedilen chat sayısı: ${retrieved.length}');
      
    } catch (e) {
      print('❌ Örnek chat history oluşturulamadı: $e');
    }
  }

  /// Comprehensive test for SharedPreferences functionality
  static Future<void> comprehensiveTest() async {
    try {
      print('🧪 Kapsamlı SharedPreferences testi başlatılıyor...');
      final prefs = await SharedPreferences.getInstance();
      
      // Test 1: Basit string kaydetme
      print('\n📝 Test 1: Basit string kaydetme');
      await prefs.setString('simple_test', 'Hello World');
      final simpleResult = prefs.getString('simple_test');
      print('✅ Basit string testi: ${simpleResult == 'Hello World' ? 'BAŞARILI' : 'BAŞARISIZ'}');
      
      // Test 2: Integer kaydetme
      print('\n📝 Test 2: Integer kaydetme');
      await prefs.setInt('int_test', 42);
      final intResult = prefs.getInt('int_test');
      print('✅ Integer testi: ${intResult == 42 ? 'BAŞARILI' : 'BAŞARISIZ'}');
      
      // Test 3: Boolean kaydetme
      print('\n📝 Test 3: Boolean kaydetme');
      await prefs.setBool('bool_test', true);
      final boolResult = prefs.getBool('bool_test');
      print('✅ Boolean testi: ${boolResult == true ? 'BAŞARILI' : 'BAŞARISIZ'}');
      
      // Test 4: JSON string kaydetme
      print('\n📝 Test 4: JSON string kaydetme');
      final testData = {
        'name': 'Test Pet',
        'age': 3,
        'type': 'dog'
      };
      final jsonString = jsonEncode(testData);
      await prefs.setString('json_test', jsonString);
      final jsonResult = prefs.getString('json_test');
      print('✅ JSON string testi: ${jsonResult == jsonString ? 'BAŞARILI' : 'BAŞARISIZ'}');
      
      // Test 5: Chat history key ile test
      print('\n📝 Test 5: Chat history key ile test');
      final chatTestData = {
        'id': 'test_chat_1',
        'title': 'Test Chat',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastModified': DateTime.now().millisecondsSinceEpoch,
        'messageCount': 1,
        'petId': 'test_pet',
        'petName': 'Test Pet',
        'lastMessage': 'Test message'
      };
      await prefs.setString(_chatHistoryKey, jsonEncode([chatTestData]));
      final chatResult = prefs.getString(_chatHistoryKey);
      print('✅ Chat history key testi: ${chatResult != null ? 'BAŞARILI' : 'BAŞARISIZ'}');
      
      // Test 6: Mevcut anahtarları listele
      print('\n📝 Test 6: Mevcut anahtarlar');
      final keys = prefs.getKeys();
      print('🔑 Mevcut anahtarlar: $keys');
      
      // Test 7: Chat history verisini oku
      print('\n📝 Test 7: Chat history verisini oku');
      if (chatResult != null) {
        try {
          final decoded = jsonDecode(chatResult);
          print('📊 Decode edilen chat history: $decoded');
          print('✅ Chat history decode testi: BAŞARILI');
        } catch (e) {
          print('❌ Chat history decode testi: BAŞARISIZ - $e');
        }
      }
      
      // Temizlik
      print('\n🧹 Test verileri temizleniyor...');
      await prefs.remove('simple_test');
      await prefs.remove('int_test');
      await prefs.remove('bool_test');
      await prefs.remove('json_test');
      await prefs.remove(_chatHistoryKey);
      print('✅ Test verileri temizlendi');
      
    } catch (e) {
      print('❌ Kapsamlı test hatası: $e');
      print('❌ Hata detayı: ${e.runtimeType}');
    }
  }
}
