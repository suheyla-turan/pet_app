import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pati_takip/features/pet/models/pet.dart';
import 'package:pati_takip/services/firestore_service.dart';

class PetCoOwnerManagementPage extends StatefulWidget {
  final Pet pet;
  
  const PetCoOwnerManagementPage({
    super.key,
    required this.pet,
  });

  @override
  State<PetCoOwnerManagementPage> createState() => _PetCoOwnerManagementPageState();
}

class _PetCoOwnerManagementPageState extends State<PetCoOwnerManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _coOwners = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isRecording = false;
  int _recordingDuration = 0;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _imageCaptionController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCoOwners();
    _loadMessages();
  }

  Future<void> _loadCoOwners() async {
    try {
      final coOwners = await FirestoreService.getCoOwners(widget.pet.id!);
      setState(() {
        _coOwners = coOwners;
      });
    } catch (e) {
      String errorMessage = 'Eş sahipler yüklenirken hata: $e';
      if (e.toString().contains('Hayvan bulunamadı')) {
        errorMessage = 'Hayvan bulunamadı. Lütfen sayfayı yenileyin.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await FirestoreService.getCoOwnerMessages(widget.pet.id!);
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      String errorMessage = 'Mesajlar yüklenirken hata: $e';
      if (e.toString().contains('Hayvan bulunamadı')) {
        errorMessage = 'Hayvan bulunamadı. Lütfen sayfayı yenileyin.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _sendCoOwnerRequest() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen email adresi girin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirestoreService.sendCoOwnerRequest(widget.pet.id!, email);
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Eş sahip isteği gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      String errorMessage = 'İstek gönderilirken hata: $e';
      if (e.toString().contains('Hayvan bulunamadı')) {
        errorMessage = 'Hayvan bulunamadı. Lütfen sayfayı yenileyin.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirestoreService.sendCoOwnerMessage(
        widget.pet.id!,
        message,
        'text',
      );
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      String errorMessage = 'Mesaj gönderilirken hata: $e';
      if (e.toString().contains('Hayvan bulunamadı')) {
        errorMessage = 'Hayvan bulunamadı. Lütfen sayfayı yenileyin.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      
      // Resim caption'ı için dialog göster
      _showImageCaptionDialog();
    }
  }

  void _showImageCaptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resim Açıklaması'),
        content: TextField(
          controller: _imageCaptionController,
          decoration: const InputDecoration(
            hintText: 'Resim için açıklama yazın (opsiyonel)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedImage = null;
                _imageCaptionController.clear();
              });
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sendImageMessage();
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendImageMessage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Resim yükleme işlemi burada yapılacak
      // Şimdilik sadece caption'ı gönderelim
      await FirestoreService.sendCoOwnerMessage(
        widget.pet.id!,
        _imageCaptionController.text.trim().isEmpty ? 'Görsel mesaj' : _imageCaptionController.text.trim(),
        'image',
        imageFile: _selectedImage,
      );
      
      setState(() {
        _selectedImage = null;
        _imageCaptionController.clear();
      });
      
      await _loadMessages();
    } catch (e) {
      String errorMessage = 'Resim gönderilirken hata: $e';
      if (e.toString().contains('Hayvan bulunamadı')) {
        errorMessage = 'Hayvan bulunamadı. Lütfen sayfayı yenileyin.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });

    // Ses kayıt işlemi burada yapılacak
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording) {
        setState(() {
          _recordingDuration++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
    });

    // Ses kayıt işlemi burada yapılacak
    // Şimdilik sadece süreyi gösterelim
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ses kaydı tamamlandı: $_recordingDuration saniye'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('${widget.pet.name} - Eş Sahip Yönetimi'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F1419),
              Color(0xFF1A202C), 
              Color(0xFF2D3748),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Tab Bar
              Container(
                color: Colors.transparent, // AppBar'ın arka planını kaldır
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.purple,
                  unselectedLabelColor: Colors.white.withOpacity(0.7), // AppBar'ın arka planı ile uyumlu
                  indicatorColor: Colors.purple,
                  tabs: const [
                    Tab(text: 'Eş Sahip Ekle'),
                    Tab(text: 'Mesajlaşma'),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCoOwnerManagementTab(true), // isDark yerine true
                    _buildMessagingTab(true), // isDark yerine true
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoOwnerManagementTab(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCoOwners,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ana sahip bilgisi
            _buildMainOwnerSection(isDark),
            const SizedBox(height: 24),
            
            // Eş sahip ekleme formu
            _buildAddCoOwnerForm(isDark),
            const SizedBox(height: 24),
            
            // Eş sahip listesi
            if (_coOwners.isNotEmpty) ...[
              Text(
                'Eş Sahipler',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._coOwners.map((coOwner) => _buildCoOwnerCard(coOwner, isDark)).toList(),
            ] else ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: Colors.grey[400],
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                                         Text(
                       'Henüz eş sahip eklenmemiş',
                       style: TextStyle(
                         color: Colors.grey[400],
                         fontSize: 18,
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                    const SizedBox(height: 8),
                                         Text(
                       'Eş sahip eklemek için yukarıdaki formu kullanın',
                       style: TextStyle(
                         color: Colors.grey[500],
                         fontSize: 14,
                       ),
                     ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddCoOwnerForm(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Eş Sahip Ekle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'E-posta Adresi',
              hintText: 'eşsahip@email.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.email),
              filled: true,
              fillColor: Colors.grey[700],
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendCoOwnerRequest,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add),
              label: Text(_isLoading ? 'Gönderiliyor...' : 'Eş Sahip İsteği Gönder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainOwnerSection(bool isDark) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isCreator = currentUser?.uid == widget.pet.creator;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.purple.shade100,
                child: Icon(
                  Icons.person,
                  color: Colors.purple.shade700,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ana Sahip',
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      currentUser?.email ?? 'Bilinmeyen',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCreator) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Sahip',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoOwnerCard(Map<String, dynamic> coOwner, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade100,
            child: Icon(
              Icons.person,
              color: Colors.blue.shade700,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eş Sahip',
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  coOwner['email'] ?? 'Bilinmeyen',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.shade400,
            ),
            onPressed: () => _removeCoOwner(coOwner['uid']),
          ),
        ],
      ),
    );
  }

  Future<void> _removeCoOwner(String? uid) async {
    if (uid == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eş Sahibi Kaldır'),
        content: const Text('Bu eş sahibi kaldırmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kaldır'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirestoreService.removeCoOwner(widget.pet.id!, uid);
        await _loadCoOwners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Eş sahip kaldırıldı'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eş sahip kaldırılırken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMessagingTab(bool isDark) {
    return Column(
      children: [
        // Mesaj listesi
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyMessagesState(isDark)
              : _buildMessagesList(isDark),
        ),
        
        // Mesaj gönderme alanı - Telefon butonlarından uzak tutuldu
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40), // Alt padding artırıldı
          margin: const EdgeInsets.only(bottom: 20), // Alt margin eklendi
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Kamera butonu
              IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                onPressed: _pickImage,
              ),
              
              // Mikrofon butonu
              IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording 
                      ? Colors.red 
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                onPressed: _isRecording ? _stopRecording : _startRecording,
              ),
              
              // Mesaj yazma alanı
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Mesaj yazın...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Gönder butonu
              Container(
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey : Colors.blue,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMessagesState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz mesaj yok',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Eş sahiplerle mesajlaşmaya başlayın',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isCurrentUser = message['senderId'] == FirebaseAuth.instance.currentUser?.uid;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isCurrentUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Colors.blue
                        : (isDark ? Colors.grey[700] : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message['messageType'] == 'text') ...[
                        Text(
                          message['message'] ?? '',
                          style: TextStyle(
                            color: isCurrentUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                            fontSize: 16,
                          ),
                        ),
                      ] else if (message['messageType'] == 'image') ...[
                        if (message['imageUrl'] != null) ...[
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                message['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                                    child: Icon(
                                      Icons.broken_image,
                                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                                      size: 48,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                        if (message['caption']?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Text(
                            message['caption'],
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ] else if (message['messageType'] == 'voice') ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.orange.shade900 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sesli Mesaj',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${message['durationSeconds'] ?? 0} saniye',
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              if (isCurrentUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _imageCaptionController.dispose();
    super.dispose();
  }
}
