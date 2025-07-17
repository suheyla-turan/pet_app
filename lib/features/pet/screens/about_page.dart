import 'package:flutter/material.dart';
import 'package:pet_app/l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patizeka'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A202C), const Color(0xFF2D3748)]
                : [const Color(0xFFF7FAFC), const Color(0xFFEDF2F7)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.pets, color: theme.colorScheme.primary, size: 32),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.aboutDescription,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // TODO: Add 'version' key to localization files and use here
            // Text(AppLocalizations.of(context)!.version, style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            // TODO: Add 'developer' key to localization files and use here
            // Text(AppLocalizations.of(context)!.developer, style: TextStyle(fontSize: 14, color: Colors.grey)),
            const Spacer(),
            // TODO: Add 'copyright' key to localization files and use here
            // Center(
            //   child: Text(AppLocalizations.of(context)!.copyright, style: TextStyle(color: Colors.grey.shade400)),
            // ),
          ],
        ),
      ),
    );
  }
} 