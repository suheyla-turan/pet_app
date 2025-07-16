import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/l10n/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF232526), const Color(0xFF414345)]
                : [theme.colorScheme.primary.withOpacity(0.15), Colors.white],
          ),
        ),
        child: SafeArea(
          child: user == null
              ? Center(child: Text(AppLocalizations.of(context)!.userNotFound))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Stack(
                        children: [
                          // Header ana içeriği
                          Column(
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(32),
                                    bottomRight: Radius.circular(32),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 54,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 50,
                                            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                                            child: user.photoURL == null ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary) : null,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: MediaQuery.of(context).size.width / 2 - 54 - 8,
                                          child: Material(
                                            color: theme.colorScheme.primary,
                                            shape: const CircleBorder(),
                                            child: InkWell(
                                              customBorder: const CircleBorder(),
                                              onTap: user == null
                                                  ? null
                                                  : () async {
                                                      await showDialog(
                                                        context: context,
                                                        builder: (context) => EditProfileDialog(),
                                                      );
                                                    },
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(Icons.edit, color: Colors.white, size: 22),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      user.displayName ?? '-',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      user.email ?? '-',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Geri butonu
                          Positioned(
                            top: 0,
                            left: 0,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // User Info Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person, color: theme.colorScheme.primary),
                                    const SizedBox(width: 10),
                                    Text(AppLocalizations.of(context)!.nameLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    Text(user.displayName ?? '-', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.email, color: theme.colorScheme.primary),
                                    const SizedBox(width: 10),
                                    Text(AppLocalizations.of(context)!.emailLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    Text(user.email ?? '-', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              child: ListTile(
                                leading: const Icon(Icons.logout, color: Colors.red),
                                title: Text(AppLocalizations.of(context)!.logout, style: TextStyle(fontWeight: FontWeight.w600)),
                                onTap: () async {
                                  await authProvider.signOut();
                                  if (context.mounted) {
                                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              child: ListTile(
                                leading: const Icon(Icons.delete_forever, color: Colors.red),
                                title: Text(AppLocalizations.of(context)!.deleteProfile, style: TextStyle(fontWeight: FontWeight.w600)),
                                onTap: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(AppLocalizations.of(context)!.deleteProfile),
                                      content: Text(AppLocalizations.of(context)!.deleteProfileConfirm),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text(AppLocalizations.of(context)!.cancel),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text(AppLocalizations.of(context)!.delete),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await _deleteProfile(context);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
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