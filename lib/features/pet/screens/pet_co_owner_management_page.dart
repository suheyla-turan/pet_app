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
    _tabController = TabController(length: 3, vsync: this);
    _loadCoOwners();
    _loadMessages();
  }

  Future<void> _loadCoOwners() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final coOwners = await FirestoreService.getCoOwners(widget.pet.id!);
      setState(() {
        _coOwners = coOwners;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eş sahipler yüklenirken hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await FirestoreService.getCoOwnerMessages(widget.pet.id!);
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesajlar yüklenirken hata: $e')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İstek gönderilirken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessageToAll() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen mesaj girin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirestoreService.sendMessageToCoOwners(widget.pet.id!, message);
      _messageController.clear();
      // StreamBuilder otomatik olarak güncellenecek
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Mesaj tüm eş sahiplere gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mesaj gönderilirken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Kamera veya galeri seçimi için dialog göster
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fotoğraf Seç'),
          content: const Text('Fotoğrafı nereden almak istiyorsunuz?'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Kamera'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galeri'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
          ],
        ),
      );
      
      if (source != null) {
        final XFile? image = await picker.pickImage(
          source: source,
          imageQuality: 80, // Kaliteyi biraz düşür
          maxWidth: 1024, // Maksimum genişlik
          maxHeight: 1024, // Maksimum yükseklik
        );
        
        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görsel seçilirken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendImageMessage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce bir görsel seçin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Görseli Firebase Storage'a yükle
      final imageUrl = await _uploadImageToStorage(_selectedImage!);
      
      // Görsel mesajı gönder
      await FirestoreService.sendImageMessageToCoOwners(
        widget.pet.id!,
        imageUrl,
        _imageCaptionController.text.trim(),
      );
      
      // UI'ı temizle
      setState(() {
        _selectedImage = null;
      });
      _imageCaptionController.clear();
      
      // StreamBuilder otomatik olarak güncellenecek
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Görsel mesaj gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görsel mesaj gönderilirken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    // Basit bir implementasyon - gerçek uygulamada Firebase Storage kullanılmalı
    // Şimdilik dosya yolunu döndürüyoruz
    return imageFile.path;
  }

  Future<void> _startRecording() async {
    if (_isRecording) {
      // Kaydı durdur
      setState(() {
        _isRecording = false;
      });
      // Kayıt süresini sıfırla
      _recordingDuration = 0;
    } else {
      // Kayda başla
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });
      
      // Basit bir timer ile kayıt süresini simüle et
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
  }

  Future<void> _sendVoiceMessage() async {
    if (_recordingDuration == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce ses kaydı yapın'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Ses dosyasını Firebase Storage'a yükle (şimdilik simüle ediyoruz)
      final audioUrl = 'simulated_audio_url_${DateTime.now().millisecondsSinceEpoch}';
      
      // Sesli mesajı gönder
      await FirestoreService.sendVoiceMessageToCoOwners(
        widget.pet.id!,
        audioUrl,
        _recordingDuration,
      );
      
      // UI'ı temizle
      setState(() {
        _recordingDuration = 0;
      });
      
      // StreamBuilder otomatik olarak güncellenecek
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Sesli mesaj gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sesli mesaj gönderilirken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mesajı Sil'),
        content: const Text('Bu mesajı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
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
      try {
        await FirestoreService.deleteMessage(messageId);
        // StreamBuilder otomatik olarak güncellenecek
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mesaj silindi'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mesaj silinirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editMessage(String messageId, String currentMessage) async {
    final TextEditingController editController = TextEditingController(text: currentMessage);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mesajı Düzenle'),
        content: TextField(
          controller: editController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Mesajınızı düzenleyin...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, editController.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentMessage) {
      try {
        await FirestoreService.editMessage(messageId, result);
        // StreamBuilder otomatik olarak güncellenecek
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mesaj düzenlendi'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mesaj düzenlenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendCurrentMessage() async {
    // Sesli mesaj varsa onu gönder
    if (_recordingDuration > 0) {
      await _sendVoiceMessage();
      return;
    }
    
    // Görsel mesaj varsa onu gönder
    if (_selectedImage != null) {
      await _sendImageMessage();
      return;
    }
    
    // Metin mesajı gönder
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await _sendMessageToAll();
    }
  }

  Future<void> _removeCoOwner(String userId) async {
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
        await FirestoreService.removeCoOwner(widget.pet.id!, userId);
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

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _imageCaptionController.dispose();
    super.dispose();
  }

  /// Ana sahip tarafından hayvanı silme
  Future<void> _deletePet() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hayvanı Sil'),
        content: const Text(
          'Bu hayvanı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm eş sahipler hayvana erişimini kaybeder.',
        ),
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
      try {
        await FirestoreService.deletePetByCreator(widget.pet.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Hayvan silindi'),
            backgroundColor: Colors.green,
          ),
        );
        // Ana sayfaya dön
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hayvan silinirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Eş sahip olarak sahipliği bırakma
  Future<void> _leaveOwnership() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sahipliği Bırak'),
        content: const Text(
          'Bu hayvandan sahipliği bırakmak istediğinizden emin misiniz? Artık hayvana erişiminiz olmayacak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sahipliği Bırak'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirestoreService.leavePetOwnership(widget.pet.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sahiplik bırakıldı'),
            backgroundColor: Colors.green,
          ),
        );
        // Ana sayfaya dön
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sahiplik bırakılırken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        elevation: 0,
        title: Column(
          children: [
            Text(
              widget.pet.name,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Eş Sahip Yönetimi',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: _loadCoOwners,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? Colors.white : Colors.black87,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: Colors.purple,
          tabs: const [
            Tab(text: 'Eş Sahip Ekle'),
            Tab(text: 'Mesajlaşma'),
            Tab(text: 'Eş Sahip Yönetimi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddCoOwnerTab(isDark),
          _buildChatTab(isDark),
          _buildCoOwnerManagementTab(isDark),
        ],
      ),
    );
  }

  Widget _buildAddCoOwnerTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Container(
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Eş Sahip İsteği Gönder',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Eş sahip olarak eklemek istediğiniz kişiye istek gönderin',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Email adresi girin',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendCoOwnerRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'İstek Gönder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          
          // Eş sahip listesi
          if (_coOwners.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Mevcut Eş Sahipler',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._coOwners.map((coOwner) => _buildCoOwnerCard(coOwner, isDark)).toList(),
          ],
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                (coOwner['displayName'] ?? '?').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coOwner['displayName'] ?? 'İsimsiz Kullanıcı',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  coOwner['email'] ?? 'Email yok',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeCoOwner(coOwner['uid']),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.remove,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab(bool isDark) {
    return Column(
      children: [
        // Mesajları görüntüleme alanı - StreamBuilder ile real-time güncelleme
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirestoreService.streamCoOwnerMessages(widget.pet.id!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mesajlar yüklenirken hata oluştu',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                );
              }

              final messages = snapshot.data!;
              
              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
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
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                reverse: true, // En yeni mesaj altta
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index]; // Ters çevir
                  final isOwnMessage = message['isOwnMessage'] ?? false;
                  final timestamp = message['timestamp'] as Timestamp?;
                  final timeAgo = timestamp != null 
                      ? _getTimeAgo(timestamp.toDate())
                      : 'Bilinmeyen zaman';

                  return _buildMessageBubble(message, isOwnMessage, timeAgo, isDark);
                },
              );
            },
          ),
        ),
        
        // Mesaj gönderme kutusu
        _buildMessageInputBox(isDark),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isOwnMessage, String timeAgo, bool isDark) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
        left: isOwnMessage ? 60 : 0,
        right: isOwnMessage ? 0 : 60,
      ),
      child: Row(
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage) ...[
            // Diğer kullanıcıların avatar'ı
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  (message['senderName'] ?? '?').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Mesaj baloncuğu
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOwnMessage 
                    ? Colors.blue
                    : (isDark ? const Color(0xFF2D2D2D) : Colors.grey[200]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isOwnMessage ? 18 : 4),
                  bottomRight: Radius.circular(isOwnMessage ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gönderen adı (sadece diğer kullanıcılar için)
                  if (!isOwnMessage) ...[
                    Text(
                      message['senderName'] ?? 'İsimsiz Kullanıcı',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  // Mesaj içeriği
                  _buildMessageContent(message, isOwnMessage, isDark),
                  
                  const SizedBox(height: 4),
                  
                  // Zaman ve işlem butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: isOwnMessage 
                              ? Colors.white70 
                              : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          fontSize: 10,
                        ),
                      ),
                      if (isOwnMessage) ...[
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Düzenle butonu (sadece metin mesajları için)
                            if (message['messageType'] == 'text')
                              GestureDetector(
                                onTap: () => _editMessage(
                                  message['messageId'],
                                  message['message'] ?? '',
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 4),
                            // Sil butonu
                            GestureDetector(
                              onTap: () => _deleteMessage(message['messageId']),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isOwnMessage) ...[
            const SizedBox(width: 8),
            // Kendi avatar'ımız
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> message, bool isOwnMessage, bool isDark) {
    final messageType = message['messageType'] ?? 'text';
    
    switch (messageType) {
      case 'text':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['message'] ?? '',
              style: TextStyle(
                color: isOwnMessage ? Colors.white : (isDark ? Colors.white : Colors.black87),
                fontSize: 14,
                height: 1.3,
              ),
            ),
            // Düzenlendi etiketi
            if (message['isEdited'] == true) ...[
              const SizedBox(height: 2),
              Text(
                'düzenlendi',
                style: TextStyle(
                  color: isOwnMessage ? Colors.white60 : Colors.grey[500],
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        );
        
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message['imageUrl'] != null) ...[
              Container(
                constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            if (message['caption']?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                message['caption'],
                style: TextStyle(
                  color: isOwnMessage ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        );
        
      case 'voice':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isOwnMessage ? Colors.white : Colors.orange).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow,
                color: isOwnMessage ? Colors.white : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sesli mesaj (${message['durationSeconds'] ?? 0}s)',
                style: TextStyle(
                  color: isOwnMessage ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
        
      default:
        return Text(
          'Desteklenmeyen mesaj türü',
          style: TextStyle(
            color: isOwnMessage ? Colors.white70 : Colors.grey[500],
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        );
    }
  }

  Widget _buildMessageInputBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Seçilen görsel önizlemesi
          if (_selectedImage != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: Image.file(
                      _selectedImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: _imageCaptionController,
                        decoration: const InputDecoration(
                          hintText: 'Görsel açıklaması...',
                          border: InputBorder.none,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                      _imageCaptionController.clear();
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
          
          // Kayıt durumu göstergesi
          if (_isRecording) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mic, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Ses kaydediliyor... ${_recordingDuration}s',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _startRecording,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.stop, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Ana mesaj input satırı
          Row(
            children: [
              // Fotoğraf butonu
              IconButton(
                onPressed: _pickImage,
                icon: Icon(
                  Icons.camera_alt,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                tooltip: 'Fotoğraf ekle',
              ),
              
              // Ses kaydı butonu
              IconButton(
                onPressed: _startRecording,
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                tooltip: _isRecording ? 'Kaydı durdur' : 'Ses kaydı',
              ),
              
              // Mesaj input alanı
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Mesaj yazın...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 4,
                    minLines: 1,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              
              // Gönder butonu
              IconButton(
                onPressed: _sendCurrentMessage,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                tooltip: 'Gönder',
              ),
            ],
          ),
        ],
      ),
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
            // Ana sahip bilgisi ve silme butonu
            _buildMainOwnerSection(isDark),
            const SizedBox(height: 24),
            
            // Eş sahip listesi
            if (_coOwners.isNotEmpty) ...[
              Text(
                'Eş Sahipler',
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
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz eş sahip eklenmemiş',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Eş sahip eklemek için ilk tab\'ı kullanın',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCreator ? Colors.red : Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCreator ? Icons.pets : Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCreator ? 'Ana Sahip (Siz)' : 'Ana Sahip',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser?.email ?? 'Email yok',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (isCreator) ...[
            // Ana sahip için hayvan silme butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _deletePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Hayvanı Sil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ] else ...[
            // Eş sahip için sahiplik bırakma butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _leaveOwnership,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Sahipliği Bırak',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }


}
