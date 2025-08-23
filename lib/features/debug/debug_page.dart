import 'package:flutter/material.dart';
import 'background_service_test_page.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menüsü'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F1419),
              Color(0xFF1A202C), 
              Color(0xFF2D3748),
            ],
          ),
        ),
        child: SafeArea(
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
                    leading: const Icon(Icons.notifications, color: Colors.orange),
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
      ),
    );
  }
}
