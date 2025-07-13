import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: user == null
                ? null
                : () async {
                    await showDialog(
                      context: context,
                      builder: (context) => EditProfileDialog(),
                    );
                  },
            tooltip: 'Profili Düzenle',
          ),
        ],
      ),
      body: user == null
          ? Center(child: Text('Kullanıcı bulunamadı'))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                      child: user.photoURL == null ? Icon(Icons.person, size: 40) : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('İsim: ${user.displayName ?? '-'}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Email: ${user.email}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await authProvider.signOut();
                        // Çıkış yapınca direkt giriş sayfasına yönlendir
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      },
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text('Çıkış Yap', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Profili Sil'),
                          content: Text('Profilinizi ve tüm verilerinizi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Vazgeç'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Evet, Sil'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _deleteProfile(context);
                      }
                    },
                    child: Text('Profili Sil'),
                  ),
                ],
              ),
            ),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
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
      title: Text('Profili Düzenle'),
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
                decoration: InputDecoration(labelText: 'İsim'),
                onChanged: (v) => _name = v,
                validator: (v) => v != null && v.trim().length >= 2 ? null : 'İsim en az 2 karakter olmalı',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _loading = true);
                    // Profil fotoğrafı yükleme işlemi burada yapılabilir (ör. Firebase Storage)
                    // Şimdilik sadece isim güncellenecek
                    await authProvider.updateProfile(displayName: _name?.trim().isNotEmpty == true ? _name!.trim() : user?.displayName);
                    setState(() => _loading = false);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
          child: _loading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Kaydet'),
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
      SnackBar(content: Text('Profil silinirken hata oluştu: $e')),
    );
  }
} 