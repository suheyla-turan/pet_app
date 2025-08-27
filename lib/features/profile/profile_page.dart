import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pati_takip/l10n/app_localizations.dart';
import '../../widgets/email_verification_dialog.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late StreamSubscription<bool> _emailVerificationSubscription;
  
  @override
  void initState() {
    super.initState();
    _setupEmailVerificationListener();
  }
  
  @override
  void dispose() {
    _emailVerificationSubscription.cancel();
    super.dispose();
  }
  
  void _setupEmailVerificationListener() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _emailVerificationSubscription = authProvider.emailVerificationStream.listen((isVerified) {
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final l10n = AppLocalizations.of(context)!;
    
    if (user != null && !user.emailVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authProvider.signOutUnverifiedUser();
      });
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.emailVerificationRequired),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread_outlined, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                l10n.emailVerificationDescription,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                l10n.redirectingToLogin,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }
    
    if (user == null) {
      return Container();
    }
    
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
          size: 28,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      
                      // Üst Kısım - Kullanıcı Bilgileri
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: themeProvider.getReadableCardBackgroundColor(isDark),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: themeProvider.getReadableCardShadow(isDark),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundImage: user.photoURL != null 
                                  ? NetworkImage(user.photoURL!) 
                                  : null,
                              backgroundColor: isDark 
                                  ? Colors.grey.shade700 
                                  : Colors.grey.shade300,
                              child: user.photoURL == null
                                  ? Icon(
                                      Icons.person,
                                      size: 70,
                                      color: isDark ? Colors.white : themeProvider.getPrimaryTextColor(isDark),
                                    )
                                  : null,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            Text(
                              user.displayName ?? l10n.anonymousUser,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.getHighContrastTextColor(isDark),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              user.email ?? l10n.emailNotFound,
                              style: TextStyle(
                                fontSize: 18,
                                color: themeProvider.getHighContrastSecondaryTextColor(isDark),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Butonlar
                      Column(
                        children: [
                          _buildActionButton(
                            icon: Icons.edit,
                            text: l10n.editProfile,
                            color: const Color(0xFF4F46E5),
                            onTap: () => _navigateToEditProfile(context),
                            isDark: isDark,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildActionButton(
                            icon: Icons.delete_forever,
                            text: l10n.deleteProfile,
                            color: const Color(0xFFDC2626),
                            onTap: () => _showDeleteProfileDialog(context),
                            isDark: isDark,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildActionButton(
                            icon: Icons.logout,
                            text: l10n.logout,
                            color: const Color(0xFFEA580C),
                            onTap: () => _showLogoutDialog(context),
                            isDark: isDark,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 26),
        label: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 6,
          shadowColor: color.withOpacity(0.4),
        ),
      ),
    );
  }
  
  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(),
      ),
    );
  }
  
  void _showDeleteProfileDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteProfile),
          content: Text(l10n.deleteProfileConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProfile(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              child: Text(
                l10n.deleteProfile,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.logoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
              ),
              child: Text(
                l10n.logout,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showEmailVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const EmailVerificationDialog(),
    );
  }
  
  Future<void> _deleteProfile(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final l10n = AppLocalizations.of(context)!;
    if (user == null) return;
    
    try {
      await user.delete();
      await authProvider.signOut();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileDeletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileDeleteError(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
      }
    }
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  File? _imageFile;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        l10n.profileEditTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        
                        GestureDetector(
                          onTap: () async {
                            final picked = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 512,
                              maxHeight: 512,
                              imageQuality: 80,
                            );
                            if (picked != null) {
                              setState(() {
                                _imageFile = File(picked.path);
                              });
                            }
                          },
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 80,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null) as ImageProvider?,
                                backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                                child: _imageFile == null && (user?.photoURL == null)
                                    ? Icon(Icons.person, size: 80, color: isDark ? Colors.white : Colors.grey.shade700)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4F46E5),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4F46E5).withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? Colors.white : Colors.grey.shade800).withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            initialValue: user?.displayName ?? '',
                            decoration: InputDecoration(
                              labelText: l10n.nameLabel,
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey.shade600,
                                fontSize: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: const Color(0xFF4F46E5),
                                size: 26,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.grey.shade800,
                              fontSize: 18,
                            ),
                            onChanged: (value) => _name = value,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.nameRequired;
                              }
                              if (value.trim().length < 2) {
                                return l10n.nameMinLengthError;
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? Colors.white : Colors.grey.shade800).withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            initialValue: user?.email ?? '',
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: l10n.email,
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey.shade600,
                                fontSize: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.grey.shade500,
                                size: 26,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey.shade600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => _loading = true);
                                      try {
                                        await authProvider.updateProfile(
                                          displayName: _name?.trim().isNotEmpty == true ? _name!.trim() : user?.displayName,
                                        );
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(l10n.profileUpdatedSuccessfully),
                                              backgroundColor: const Color(0xFF4F46E5),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(l10n.profileUpdateError(e.toString())),
                                                backgroundColor: const Color(0xFFDC2626),
                                              ),
                                            );
                                        }
                                      } finally {
                                        setState(() => _loading = false);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              padding: const EdgeInsets.symmetric(vertical: 22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFF4F46E5).withOpacity(0.4),
                            ),
                            child: _loading 
                                ? SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3, 
                                      color: Colors.white,
                                    )
                                  ) 
                                : Text(
                                    l10n.save,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

