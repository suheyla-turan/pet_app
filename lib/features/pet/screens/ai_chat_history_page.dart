import 'package:flutter/material.dart';
import 'package:pati_takip/features/pet/models/pet.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/ai_provider.dart';
import 'package:pati_takip/features/pet/models/ai_chat_message.dart';
import 'package:pati_takip/services/realtime_service.dart';
import 'ai_chat_page.dart'; // <-- eksik import eklendi

class AIChatHistoryPage extends StatefulWidget {
  final Pet pet;
  const AIChatHistoryPage({super.key, required this.pet});

  @override
  State<AIChatHistoryPage> createState() => _AIChatHistoryPageState();
}

class _AIChatHistoryPageState extends State<AIChatHistoryPage> {
  late Future<List<Map<String, dynamic>>> _futureChats;

  @override
  void initState() {
    super.initState();
    _futureChats = Provider.of<AIProvider>(context, listen: false).getChatHistoryList(widget.pet.id ?? widget.pet.name);
  }

  void _refreshChats() {
    setState(() {
      _futureChats = Provider.of<AIProvider>(context, listen: false).getChatHistoryList(widget.pet.id ?? widget.pet.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PatiTakip')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureChats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return const Center(child: Text('Bu hayvan için henüz AI sohbeti yok.'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, i) {
              final chat = chats[i];
              final createdAt = DateTime.fromMillisecondsSinceEpoch(chat['createdAt'] ?? 0);
              return FutureBuilder<List<AIChatMessage>>(
                future: RealtimeService().getAIChatMessagesStream(widget.pet.id ?? widget.pet.name, chat['chatId']).first,
                builder: (context, msgSnapshot) {
                  String title = 'Sohbet ${i + 1}';
                  if (msgSnapshot.hasData && msgSnapshot.data!.isNotEmpty) {
                    final firstUserMsg = msgSnapshot.data!.firstWhere(
                      (m) => m.sender == 'user',
                      orElse: () => msgSnapshot.data!.first,
                    );
                    title = firstUserMsg.text.length > 30
                      ? '${firstUserMsg.text.substring(0, 30)}...'
                      : firstUserMsg.text;
                  }
                  return ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(title),
                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(createdAt)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Sohbeti Sil',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sohbeti Sil'),
                            content: const Text('Bu sohbeti silmek istediğinize emin misiniz?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('İptal'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Sil'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await RealtimeService().deleteAIChat(widget.pet.id ?? widget.pet.name, chat['chatId']);
                          _refreshChats();
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AIChatDetailPage(pet: widget.pet, chatId: chat['chatId']),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Geçici placeholder (detay sayfası ileride gerçek içerik ile değiştirilecek)
class AIChatDetailPage extends StatelessWidget {
  final Pet pet;
  final String chatId;
  const AIChatDetailPage({super.key, required this.pet, required this.chatId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PatiTakip')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<AIChatMessage>>(
              stream: RealtimeService().getAIChatMessagesStream(pet.id ?? pet.name, chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('Bu sohbette hiç mesaj yok.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isUser = msg.sender == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(msg.text),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(msg.timestamp),
                              ),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Bu sohbete devam et'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIChatPage(pet: pet, chatId: chatId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 