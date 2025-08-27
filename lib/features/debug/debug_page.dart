import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'background_service_test_page.dart';
import '../../providers/theme_provider.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Provider.of<ThemeProvider>(context).getBackgroundGradient(
            Theme.of(context).brightness == Brightness.dark
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Debug Menüsü',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.settings_system_daydream, color: Colors.blue),
                          title: const Text('Background Service Test'),
                          subtitle: const Text('Background service durumunu test et'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BackgroundServiceTestPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.pets, color: Colors.orange),
                          title: const Text('Bildirim Test'),
                          subtitle: const Text('Farklı bildirim türlerini test et'),
                          onTap: () {
                            // TODO: Bildirim test sayfası ekle
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yakında eklenecek!')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.pets, color: Colors.green),
                          title: const Text('Pet Değer Test'),
                          subtitle: const Text('Pet değerlerini test et'),
                          onTap: () {
                            // TODO: Pet değer test sayfası ekle
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yakında eklenecek!')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.settings, color: Colors.purple),
                          title: const Text('Sistem Ayarları'),
                          subtitle: const Text('Sistem ayarlarını görüntüle'),
                          onTap: () {
                            // TODO: Sistem ayarları sayfası ekle
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yakında eklenecek!')),
                            );
                          },
                        ),
                      ),
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
}
