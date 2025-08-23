import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/pet_provider.dart';
import '../../../services/background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundServiceTestPage extends StatefulWidget {
  const BackgroundServiceTestPage({super.key});

  @override
  State<BackgroundServiceTestPage> createState() => _BackgroundServiceTestPageState();
}

class _BackgroundServiceTestPageState extends State<BackgroundServiceTestPage> {
  bool _isServiceRunning = false;
  String _lastUpdateTime = 'Henüz güncellenmedi';

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    // SharedPreferences'dan son güncelleme zamanını kontrol et
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('last_background_update');
    if (lastUpdate != null) {
      setState(() {
        _lastUpdateTime = DateTime.parse(lastUpdate).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Service Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Background Service Durumu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isServiceRunning ? Icons.check_circle : Icons.cancel,
                          color: _isServiceRunning ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isServiceRunning ? 'Çalışıyor' : 'Çalışmıyor',
                          style: TextStyle(
                            color: _isServiceRunning ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Son Güncelleme: $_lastUpdateTime'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await context.read<PetProvider>().startBackgroundService();
                  setState(() {
                    _isServiceRunning = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Background service başlatıldı!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Background Service Başlat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await context.read<PetProvider>().stopBackgroundService();
                  setState(() {
                    _isServiceRunning = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Background service durduruldu!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.stop),
              label: const Text('Background Service Durdur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await BackgroundService.startBackgroundTask();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Manuel task başlatıldı!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  await _checkServiceStatus();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.schedule),
              label: const Text('Manuel Task Başlat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bilgi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Background service 15 dakikada bir çalışır\n'
                      '• Evcil hayvan değerleri otomatik güncellenir\n'
                      '• Kritik değerler için bildirim gönderilir\n'
                      '• Uygulama kapalıyken de çalışır',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
