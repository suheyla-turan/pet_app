import 'package:flutter/material.dart';
import 'package:pati_takip/l10n/app_localizations.dart';
import '../models/chat_history.dart';
import '../../../services/chat_history_service.dart';

class ChatHistoryOverlay extends StatefulWidget {
  final String? petId;
  final String? petName;
  final VoidCallback onNewChat;
  final Function(ChatHistory) onChatSelected;
  final VoidCallback onClose;
  final VoidCallback onClearCurrentChat;
  final Function(ChatHistory)? onDeleteChat;

  const ChatHistoryOverlay({
    super.key,
    this.petId,
    this.petName,
    required this.onNewChat,
    required this.onChatSelected,
    required this.onClose,
    required this.onClearCurrentChat,
    this.onDeleteChat,
  });

  @override
  State<ChatHistoryOverlay> createState() => _ChatHistoryOverlayState();
}

class _ChatHistoryOverlayState extends State<ChatHistoryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  List<ChatHistory> _chatHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadChatHistory();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    try {
      print('🔄 Chat history overlay\'de veri yükleniyor...');
      final history = await ChatHistoryService.getChatHistory();
      print('📊 Chat history service\'den ${history.length} chat döndü');
      
      setState(() {
        _chatHistory = history;
        _isLoading = false;
      });
      
      print('✅ Chat history overlay state güncellendi');
    } catch (e) {
      print('❌ Chat history overlay\'de hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteChat(ChatHistory chat) async {
    // Eğer onDeleteChat callback'i tanımlıysa, onu kullan
    if (widget.onDeleteChat != null) {
      await widget.onDeleteChat!(chat);
      // Callback'den sonra chat history'yi yeniden yükle
      await _loadChatHistory();
    } else {
      // Fallback: Eski yöntem
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sohbeti Sil'),
          content: Text('"${chat.title}" sohbetini silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await ChatHistoryService.deleteChat(chat.id);
        await _loadChatHistory();
      }
    }
  }

  void _closeOverlay() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            MediaQuery.of(context).size.width * _slideAnimation.value,
            0,
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // Made wider
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            border: Border(
              left: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20), // Increased padding
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _closeOverlay,
                      icon: const Icon(Icons.close, color: Colors.white, size: 24), // Made icon bigger
                      iconSize: 24, // Set icon size
                    ),
                    Expanded(
                      child: Text(
                        l10n.chatHistory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20, // Made bigger
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // New Chat Button
              Container(
                margin: const EdgeInsets.all(20), // Increased margin
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onNewChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20), // Increased padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Increased border radius
                    ),
                  ),
                  icon: const Icon(Icons.add_comment, size: 24), // Made icon bigger
                  label: Text(
                    l10n.newChat,
                    style: const TextStyle(
                      fontSize: 18, // Made bigger
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              // Clear Current Chat Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Increased margins
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onClearCurrentChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16), // Increased padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Increased border radius
                    ),
                  ),
                  icon: const Icon(Icons.clear, size: 20), // Made icon bigger
                  label: Text(
                    l10n.clearCurrentChat,
                    style: const TextStyle(
                      fontSize: 16, // Made bigger
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              

              
              // Chat History List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B5CF6),
                        ),
                      )
                    : _chatHistory.isEmpty
                        ? _buildEmptyState(l10n)
                        : _buildChatHistoryList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80, // Made bigger
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 20), // Increased spacing
          Text(
            l10n.noChatHistoryYet,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 18, // Made bigger
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startNewChat,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 16, // Made bigger
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _chatHistory.length,
      itemBuilder: (context, index) {
        final chat = _chatHistory[index];
        return _buildChatHistoryItem(chat);
      },
    );
  }

  Widget _buildChatHistoryItem(ChatHistory chat) {
    final isCurrentPet = widget.petId != null && chat.petId == widget.petId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentPet 
            ? const Color(0xFF8B5CF6).withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPet 
              ? const Color(0xFF8B5CF6).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => widget.onChatSelected(chat),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCurrentPet 
                ? const Color(0xFF8B5CF6).withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isCurrentPet ? Icons.pets : Icons.chat_bubble_outline,
            color: isCurrentPet ? const Color(0xFF8B5CF6) : Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          chat.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chat.lastMessage != null) ...[
              Text(
                chat.lastMessage!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Text(
              _formatDate(chat.lastModified),
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chat.messageCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${chat.messageCount}',
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white.withOpacity(0.6),
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteChat(chat);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Sil'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} dk önce';
      }
      return '${difference.inHours} sa önce';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
