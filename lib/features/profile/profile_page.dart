import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pati_takip/l10n/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: user == null
            ? Center(child: Text(AppLocalizations.of(context)!.userNotFound))
            : Column(
                children: [
                  // Üst Header - Zaman ve durum bilgileri
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        // Sol taraf - Zaman
                        Text(
                          '13:50',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        // Sağ taraf - Durum ikonları
                        Row(
                          children: [
                            Icon(Icons.wifi, color: Colors.white.withOpacity(0.8), size: 16),
                            const SizedBox(width: 8),
                            Icon(Icons.signal_cellular_4_bar, color: Colors.white.withOpacity(0.8), size: 16),
                            const SizedBox(width: 8),
                            Icon(Icons.battery_full, color: Colors.white.withOpacity(0.8), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '54%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Ana Header - Hayvan adı ve türü
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Boncuk',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Chinchilla',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // Profil Kartı
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                // Profil Resmi - Paw print ikonu ile
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3A3A3A),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: const Icon(
                                    Icons.pets,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                
                                // Hayvan Bilgileri
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Boncuk',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Bilgi Etiketleri - Sadece temel bilgiler
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _buildInfoTag(
                                            icon: Icons.cake,
                                            text: '3 yaşında',
                                            color: Colors.orange,
                                          ),
                                          _buildInfoTag(
                                            icon: Icons.pets,
                                            text: 'Dişi',
                                            color: Colors.pink,
                                          ),
                                          _buildInfoTag(
                                            icon: Icons.pets,
                                            text: 'Chinchilla',
                                            color: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Durum Bilgileri
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Durum Bilgileri',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                // Durum Çubukları - Görüntüdeki gibi
                                _buildStatusBar(
                                  icon: Icons.restaurant,
                                  label: 'Açlık',
                                  progress: 1.0,
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 16),
                                _buildStatusBar(
                                  icon: Icons.favorite,
                                  label: 'Mutluluk',
                                  progress: 1.0,
                                  color: Colors.pink,
                                ),
                                const SizedBox(height: 16),
                                _buildStatusBar(
                                  icon: Icons.flash_on,
                                  label: 'Enerji',
                                  progress: 1.0,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 16),
                                _buildStatusBar(
                                  icon: Icons.healing,
                                  label: 'Bakım',
                                  progress: 1.0,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Hızlı İşlemler
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.orange,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Hızlı İşlemler',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                // Besle Butonu - Görüntüdeki gibi
                                _buildActionButton(
                                  icon: Icons.restaurant,
                                  text: 'Besle',
                                  color: Colors.orange,
                                  onTap: () {},
                                ),
                                const SizedBox(height: 12),
                                
                                // Sev Butonu - Görüntüdeki gibi
                                _buildActionButton(
                                  icon: Icons.favorite,
                                  text: 'Sev',
                                  color: Colors.pink,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  Widget _buildInfoTag({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBar({
    required IconData icon,
    required String label,
    required double progress,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '10/10',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  File? _imageFile;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editProfile),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() {
                      _imageFile = File(picked.path);
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null) as ImageProvider?,
                  child: _imageFile == null && (user?.photoURL == null)
                      ? Icon(Icons.camera_alt, size: 32)
                      : null,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: user?.displayName ?? '',
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
                onChanged: (v) => _name = v,
                validator: (v) => v != null && v.trim().length >= 2 ? null : AppLocalizations.of(context)!.nameMinLengthError,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _loading = true);
                    await authProvider.updateProfile(
                      displayName: _name?.trim().isNotEmpty == true ? _name!.trim() : user?.displayName,
                    );
                    setState(() => _loading = false);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
          child: _loading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}

Future<void> _deleteProfile(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final user = authProvider.user;
  if (user == null) return;
  try {
    final uid = user.uid;
    // Firestore'dan kullanıcı dokümanını sil
    await FirebaseFirestore.instance.collection('profiller').doc(uid).delete();
    // Firebase Auth'tan kullanıcıyı sil
    await user.delete();
    await authProvider.signOut();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.deleteProfileError(e.toString()))),
    );
  }
}
