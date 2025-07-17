import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_app/features/pet/models/pet.dart';
import 'package:pet_app/providers/ai_provider.dart';
import 'ai_chat_history_page.dart';
import 'package:pet_app/l10n/app_localizations.dart';

class AIChatPage extends StatefulWidget {
  final Pet pet;
  final String? chatId; // <-- yeni parametre
  const AIChatPage({super.key, required this.pet, this.chatId});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final aiProvider = context.read<AIProvider>();
      final petId = widget.pet.id ?? widget.pet.name;
      if (widget.chatId != null) {
        // Geçmiş sohbetten devam
        aiProvider.listenToChat(petId, widget.chatId!);
      } else {
        // Her girişte yeni sohbet başlat
        await aiProvider.startNewChat(petId);
        if (aiProvider.activeChatId != null) {
          aiProvider.listenToChat(petId, aiProvider.activeChatId!);
        }
      }
    });
  }

  @override
  void dispose() {
    // Sohbeti geçmişe kaydetme işlemi burada yapılabilir (gerekirse)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patizeka'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final aiProvider = context.read<AIProvider>();
              final petId = widget.pet.id ?? widget.pet.name;
              if (value == 'new') {
                await aiProvider.startNewChat(petId);
                if (aiProvider.activeChatId != null) {
                  aiProvider.listenToChat(petId, aiProvider.activeChatId!);
                }
              } else if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIChatHistoryPage(pet: widget.pet),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'new', child: Text(AppLocalizations.of(context)!.newChat)),
              PopupMenuItem(value: 'history', child: Text(AppLocalizations.of(context)!.chatHistory)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: aiProvider.activeMessages.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.noMessages))
                : ListView.builder(
                    itemCount: aiProvider.activeMessages.length,
                    itemBuilder: (context, i) {
                      final msg = aiProvider.activeMessages[i];
                      final isUser = msg.sender == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 48,
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(child: Text(msg.text, softWrap: true, overflow: TextOverflow.visible)),
                                if (!isUser)
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, size: 20),
                                    tooltip: 'Sesli Oku',
                                    onPressed: () async {
                                      await aiProvider.speakResponse(msg.text);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (aiProvider.isLoading)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.aiThinking),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  aiProvider.isListening ? Icons.stop : Icons.mic,
                  color: aiProvider.isListening ? Colors.red : null,
                ),
                tooltip: aiProvider.isListening ? AppLocalizations.of(context)!.stopListening : AppLocalizations.of(context)!.speakQuestion,
                onPressed: aiProvider.isLoading
                    ? null
                    : () async {
                        if (aiProvider.isListening) {
                          await aiProvider.stopVoiceInput();
                        } else {
                          await aiProvider.startVoiceInput();
                        }
                      },
              ),
              Expanded(
                child: TextField(
                  controller: _chatController,
                  enabled: !aiProvider.isLoading,
                  decoration: InputDecoration(hintText: AppLocalizations.of(context)!.chatHint),
                  onSubmitted: (val) async {
                    if (val.trim().isNotEmpty && !aiProvider.isLoading) {
                      await aiProvider.sendMessageAndGetAIResponse(
                        petId: widget.pet.id ?? widget.pet.name,
                        pet: widget.pet,
                        message: val.trim(),
                      );
                      _chatController.clear();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: aiProvider.isLoading
                    ? null
                    : () async {
                        final val = _chatController.text.trim();
                        if (val.isNotEmpty) {
                          await aiProvider.sendMessageAndGetAIResponse(
                            petId: widget.pet.id ?? widget.pet.name,
                            pet: widget.pet,
                            message: val,
                          );
                          _chatController.clear();
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
} 