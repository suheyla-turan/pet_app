import 'package:flutter/material.dart';
import 'package:pati_takip/l10n/app_localizations.dart';
import 'package:pati_takip/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      // Klavye açılırken performans optimizasyonu
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('PatiTakip'),
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
        child: _sent
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.feedbackThanks, style: TextStyle(fontSize: 18)),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(AppLocalizations.of(context)!.feedbackDescription, style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _controller,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.yourMessage,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.enterMessage;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: Text(AppLocalizations.of(context)!.send),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final user = FirebaseAuth.instance.currentUser;
                            await FirestoreService.sendFeedbackMessage(
                              _controller.text.trim(),
                              userId: user?.uid,
                              userEmail: user?.email,
                            );
                            setState(() {
                              _sent = true;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
} 