import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:pati_takip/features/pet/models/pet.dart';
import 'package:pati_takip/services/firestore_service.dart';
import 'package:pati_takip/providers/theme_provider.dart';
import 'package:pati_takip/l10n/app_localizations.dart';

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
  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCoOwners();
    _loadMessages();
    _startMessageStream();
  }

  void _startMessageStream() {
    print('🔄 Mesaj stream başlatılıyor - Pet ID: ${widget.pet.id}');
    _messageSubscription = FirestoreService.streamCoOwnerMessages(widget.pet.id!)
        .listen((messages) {
      print('📨 Stream\'den ${messages.length} mesaj alındı');
      print('📝 Mesajlar: ${messages.map((m) => '${m['senderName']}: ${m['message']}').toList()}');
      print('🕐 Client Timestamp\'ler: ${messages.map((m) => m['createdAt']).toList()}');
      
      print('🔄 Stream setState çağrılıyor - önceki mesaj sayısı: ${_messages.length}');
      
      // Geçici mesajları gerçek mesajlarla değiştir
      final updatedMessages = List<Map<String, dynamic>>.from(messages);
      
      // Local mesajları kaldır (gerçek mesajlar geldiğinde)
      _messages.removeWhere((msg) => msg['isLocal'] == true);
      
      // Geçici mesajları kaldır (gerçek mesajlar geldiğinde)
      _messages.removeWhere((msg) => msg['messageId'].toString().startsWith('temp_'));
      
      // Optimistic update'leri temizle
      _messages.removeWhere((msg) => msg['isOptimistic'] == true);
      
      // Sending durumundaki mesajları temizle
      _messages.removeWhere((msg) => msg['status'] == 'sending');
      
      // Pending durumundaki mesajları temizle
      _messages.removeWhere((msg) => msg['isPending'] == true);
      
      // Stream'den gelen mesajları ekle
      for (final message in messages) {
        if (!_messages.any((m) => m['messageId'] == message['messageId'])) {
          _messages.add(message);
        }
      }
      
      // Mesajları createdAt'e göre sırala
      _messages.sort((a, b) {
        final aTime = a['createdAt'] as dynamic;
        final bTime = b['createdAt'] as dynamic;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime); // Ascending (eski mesajlar üstte)
      });
      
      // Duplicate'ları temizle
      final uniqueMessages = <Map<String, dynamic>>[];
      final seenIds = <String>{};
      
      for (final message in _messages) {
        final messageId = message['messageId'].toString();
        if (!seenIds.contains(messageId)) {
          seenIds.add(messageId);
          uniqueMessages.add(message);
        }
      }
      
      // Delivery durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isDelivered'] == false);
      
      // Read durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isRead'] == false);
      
      // Archive durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isArchived'] == true);
      
      // Delete durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isDeleted'] == true);
      
      // Flag durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isFlagged'] == true);
      
      // Spam durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isSpam'] == true);
      
      // Block durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isBlocked'] == true);
      
      // Mute durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isMuted'] == true);
      
      // Hide durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isHidden'] == true);
      
      // Pin durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isPinned'] == true);
      
      // Forward durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isForwarded'] == true);
      
      // Reply durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isReplied'] == true);
      
      // Edit durumundaki mesajları temizle
      uniqueMessages.removeWhere((msg) => msg['isEdited'] == true);
      
      setState(() {
        _messages = uniqueMessages;
      });
      print('✅ Stream setState tamamlandı - yeni mesaj sayısı: ${_messages.length}');
      
      // Yeni mesajlar geldiğinde en alta kaydır
      if (messages.isNotEmpty && _scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200), // Daha hızlı scroll
              curve: Curves.easeOutCubic, // Daha smooth scroll
            );
          }
        });
      }
    }, onError: (error) {
      print('❌ Mesaj stream hatası: $error');
      print('🔍 Hata detayı: ${error.toString()}');
    });
  }

  Future<void> _loadCoOwners() async {
    try {
      final coOwners = await FirestoreService.getCoOwners(widget.pet.id!);
      setState(() {
        _coOwners = coOwners;
      });
    } catch (e) {
      String errorMessage = '${AppLocalizations.of(context)!.coOwnersLoadingError}: ${e.toString()}';
      if (e.toString().contains('Hayvan bulunamadı')) {
        errorMessage = AppLocalizations.of(context)!.petNotFound;
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
    print('📥 Manuel mesaj yükleme başlatılıyor - Pet ID: ${widget.pet.id}');
    try {
      final messages = await FirestoreService.getCoOwnerMessages(widget.pet.id!);
      print('📨 Manuel olarak ${messages.length} mesaj yüklendi');
      print('📝 Yüklenen mesajlar: ${messages.map((m) => m['message']).toList()}');
      
      print('🔄 setState çağrılıyor - önceki mesaj sayısı: ${_messages.length}');
      setState(() {
        _messages = messages;
      });
      print('✅ setState tamamlandı - yeni mesaj sayısı: ${_messages.length}');
      
    } catch (e) {
      print('❌ Mesaj yükleme hatası: $e');
      String errorMessage = '${AppLocalizations.of(context)!.errorOccurred} $e';
      if (e.toString().contains('Hayvan bulunamadı')) {
        errorMessage = AppLocalizations.of(context)!.petNotFound;
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.emailRequired),
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
        SnackBar(
          content: Text('✅ ${AppLocalizations.of(context)!.coOwnerRequestSent}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      String errorMessage = '${AppLocalizations.of(context)!.errorOccurred} $e';
      if (e.toString().contains('Hayvan bulunamadı')) {
        errorMessage = AppLocalizations.of(context)!.petNotFound;
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

    print('📤 Mesaj gönderiliyor: "$message" - Pet ID: ${widget.pet.id}');
    print('📱 Mevcut mesaj sayısı: ${_messages.length}');
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 FirestoreService.sendCoOwnerMessage çağrılıyor...');
      
      await FirestoreService.sendCoOwnerMessage(
        widget.pet.id!,
        message,
        'text',
      );
      
      print('✅ Mesaj başarıyla gönderildi');
      _messageController.clear();
      
      print('📱 Mesaj gönderildi, local state güncelleniyor...');
      
      // Local state'e mesajı ekle (anında görünmesi için)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final now = DateTime.now();
        final newMessage = {
          'messageId': 'temp_${now.millisecondsSinceEpoch}',
          'petId': widget.pet.id,
          'petName': widget.pet.name,
          'senderId': currentUser.uid,
          'senderName': currentUser.displayName ?? 'İsimsiz Kullanıcı',
          'senderEmail': currentUser.email ?? '',
          'message': message,
          'messageType': 'text',
          'timestamp': now,
          'createdAt': now.millisecondsSinceEpoch,
          'isOwnMessage': true,
          'type': 'co_owner_message',
          'isOptimistic': true, // Optimistic update flag
          'status': 'sending', // Mesaj durumu
          'localId': 'temp_${now.millisecondsSinceEpoch}', // Local ID ekle
          'isLocal': true, // Local mesaj flag'i
          'isPending': true, // Pending durumu
          'isDelivered': false, // Delivery durumu
          'isRead': false, // Read durumu
          'isArchived': false, // Archive durumu
          'isDeleted': false, // Delete durumu
          'isFlagged': false, // Flag durumu
          'isSpam': false, // Spam durumu
          'isBlocked': false, // Block durumu
          'isMuted': false, // Mute durumu
          'isHidden': false, // Hide durumu
          'isPinned': false, // Pin durumu
          'isForwarded': false, // Forward durumu
          'isReplied': false, // Reply durumu
          'isEdited': false, // Edit durumu
        };
        
        setState(() {
          _messages.add(newMessage);
        });
        
        print('📱 Local state güncellendi, mesaj sayısı: ${_messages.length}');
      }
      
      // Mesaj gönderildikten sonra en alta kaydır
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), // Daha hızlı scroll
            curve: Curves.easeOutCubic, // Daha smooth scroll
          );
        }
      });
      
    } catch (e) {
      print('❌ Mesaj gönderme hatası: $e');
      String errorMessage = '${AppLocalizations.of(context)!.errorOccurred} $e';
      if (e.toString().contains('Hayvan bulunamadı')) {
        errorMessage = AppLocalizations.of(context)!.petNotFound;
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
        title: Text(AppLocalizations.of(context)!.addNoteOptional),
        content: TextField(
          controller: _imageCaptionController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.addNoteOptional,
            border: const OutlineInputBorder(),
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
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sendImageMessage();
            },
            child: Text(AppLocalizations.of(context)!.send),
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
        _imageCaptionController.text.trim().isEmpty ? AppLocalizations.of(context)!.imageNoteAddedMessage : _imageCaptionController.text.trim(),
        'image',
        imageFile: _selectedImage,
      );
      
      setState(() {
        _selectedImage = null;
        _imageCaptionController.clear();
      });
      
      await _loadMessages();
    } catch (e) {
      String errorMessage = '${AppLocalizations.of(context)!.errorOccurred} $e';
      if (e.toString().contains('Hayvan bulunamadı')) {
        errorMessage = AppLocalizations.of(context)!.petNotFound;
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
          content: Text('Voice recording completed: $_recordingDuration seconds'),
          backgroundColor: Colors.green,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.dark : Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
        title: Text(
          '${widget.pet.name} - ${AppLocalizations.of(context)!.coOwnerManagement}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.white.withOpacity(0.9),
        elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 2,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Provider.of<ThemeProvider>(context).getBackgroundGradient(
            Theme.of(context).brightness == Brightness.dark
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Tab Bar
              Container(
                color: Colors.transparent,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                  indicatorColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.addCoOwner),
                    Tab(text: AppLocalizations.of(context)!.messaging),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCoOwnerManagementTab(Theme.of(context).brightness == Brightness.dark),
                    _buildMessagingTab(Theme.of(context).brightness == Brightness.dark),
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
                AppLocalizations.of(context)!.coOwners,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
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
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noCoOwnersYet,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.useFormAboveToAddCoOwner,
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.black54,
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
          Text(
            AppLocalizations.of(context)!.addCoOwner,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.emailAddress,
              hintText: AppLocalizations.of(context)!.emailHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(
                Icons.email,
                color: isDark ? Colors.white : Colors.black87,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[700] : Colors.grey[100],
              labelStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
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
              label: Text(_isLoading ? AppLocalizations.of(context)!.sending : AppLocalizations.of(context)!.sendCoOwnerRequest),
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
                      AppLocalizations.of(context)!.mainOwner,
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      currentUser?.displayName ?? AppLocalizations.of(context)!.anonymousUser,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      currentUser?.email ?? '',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
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
                    AppLocalizations.of(context)!.mainOwner,
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
                  AppLocalizations.of(context)!.coOwner,
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  coOwner['displayName'] ?? AppLocalizations.of(context)!.anonymousUser,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  coOwner['email'] ?? '',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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
        title: Text(
          AppLocalizations.of(context)!.removeCoOwner,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.removeCoOwnerConfirmation,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.black87,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.remove),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirestoreService.removeCoOwner(widget.pet.id!, uid);
        await _loadCoOwners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${AppLocalizations.of(context)!.coOwnerRemoved}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorRemovingCoOwner}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMessagingTab(bool isDark) {
    print('🏗️ Mesajlaşma sekmesi oluşturuluyor - mesaj sayısı: ${_messages.length}');
    print('🔍 _messages.isEmpty: ${_messages.isEmpty}');
    
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
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.writeMessage,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
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
            AppLocalizations.of(context)!.noMessagesYet,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.startChattingWithCoOwners,
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(bool isDark) {
    print('🏗️ Mesaj listesi oluşturuluyor - ${_messages.length} mesaj var');
    print('📝 Mesaj detayları: ${_messages.map((m) => {
      'id': m['messageId'],
      'message': m['message'],
      'sender': m['senderName'],
      'timestamp': m['timestamp'],
    }).toList()}');
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isCurrentUser = message['senderId'] == FirebaseAuth.instance.currentUser?.uid;
        
        print('📱 Mesaj ${index + 1} render ediliyor: ${message['message']}');
        
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
                      // Sender name (only for messages from others)
                      if (!isCurrentUser) ...[
                        Text(
                          message['senderName'] ?? AppLocalizations.of(context)!.anonymousUser,
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
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
                              color: isDark ? Colors.grey[400] : Colors.black87,
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
                                      AppLocalizations.of(context)!.voiceMessage(''),
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${message['durationSeconds'] ?? 0} ${AppLocalizations.of(context)!.seconds}',
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.black87,
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



  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _imageCaptionController.dispose();
    _messageSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}
