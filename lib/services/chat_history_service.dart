import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/pet/models/chat_history.dart';

class ChatHistoryService {
  static const String _chatHistoryKey = 'chat_history';
  static const String _currentChatKey = 'current_chat';
  
  /// Chat geçmişini kaydet
  static Future<void> saveChatHistory(ChatHistory chatHistory) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingHistory = await getChatHistory();
      
      // Mevcut chat'i güncelle veya yeni ekle
      final updatedHistory = existingHistory.where((chat) => chat.id != chatHistory.id).toList();
      updatedHistory.add(chatHistory);
      
      // Tarihe göre sırala (en yeni üstte)
      updatedHistory.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      
      // Sadece son 50 chat'i tut
      if (updatedHistory.length > 50) {
        updatedHistory.removeRange(50, updatedHistory.length);
      }
      
      final historyJson = updatedHistory.map((chat) => chat.toMap()).toList();
      await prefs.setString(_chatHistoryKey, jsonEncode(historyJson));
    } catch (e) {
      print('❌ Chat geçmişi kaydedilemedi: $e');
    }
  }
  
  /// Chat geçmişini getir
  static Future<List<ChatHistory>> getChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString(_chatHistoryKey);
      
      if (historyString == null || historyString.isEmpty) {
        return [];
      }
      
      final historyList = jsonDecode(historyString) as List;
      return historyList.map((item) => ChatHistory.fromMap(item, item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())).toList();
    } catch (e) {
      print('❌ Chat geçmişi getirilemedi: $e');
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
      final prefs = await SharedPreferences.getInstance();
      final existingHistory = await getChatHistory();
      
      final updatedHistory = existingHistory.where((chat) => chat.id != chatId).toList();
      
      final historyJson = updatedHistory.map((chat) => chat.toMap()).toList();
      await prefs.setString(_chatHistoryKey, jsonEncode(historyJson));
    } catch (e) {
      print('❌ Chat silinemedi: $e');
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
      title: title ?? (petName != null ? '$petName ile Sohbet' : 'Yeni Sohbet'),
      createdAt: now,
      lastModified: now,
      messageCount: 0,
      petId: petId,
      petName: petName,
    );
  }
}
