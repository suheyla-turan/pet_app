import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('Destek / Geri Bildirim'),
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
                    const Text('Geri bildiriminiz için teşekkürler!', style: TextStyle(fontSize: 18)),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text('Görüş, öneri veya yaşadığınız bir sorunu bizimle paylaşabilirsiniz.', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _controller,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Mesajınız',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen bir mesaj girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Gönder'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _sent = true;
                            });
                            // Burada backend veya e-posta ile gönderim yapılabilir
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