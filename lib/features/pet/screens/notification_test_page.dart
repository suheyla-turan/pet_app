import 'package:flutter/material.dart';
import '../../../services/notification_service.dart';

class NotificationTestPage extends StatelessWidget {
  const NotificationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PatiTakip'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    // Pati ikonu
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pets, // Pati ikonu
                        color: Color(0xFF3B82F6),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bildirim Test Sayfası',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tüm bildirimlerde mavi arka plan üzerinde pati ikonu ve uygulama ikonu görünecek',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              const Text(
                'Bildirimleri test etmek için aşağıdaki butonları kullanın:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              
              // Test butonları
              _buildTestButton(
                onPressed: () {
                  NotificationService.showCriticalStatusNotification(
                    'Pamuk',
                    'tokluk',
                  );
                },
                icon: Icons.warning,
                label: '🚨 Kritik Durum Bildirimi',
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              
              _buildTestButton(
                onPressed: () {
                  NotificationService.showBirthdayNotification('Pamuk');
                },
                icon: Icons.cake,
                label: '🎉 Doğum Günü Bildirimi',
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              
              _buildTestButton(
                onPressed: () {
                  NotificationService.showVaccineDueNotification(
                    'Pamuk',
                    'Kuduz Aşısı',
                  );
                },
                icon: Icons.medical_services,
                label: '💉 Aşı Vakti Bildirimi',
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              
              _buildTestButton(
                onPressed: () {
                  NotificationService.showCoOwnerMessageNotification(
                    'Pamuk',
                    'Ahmet',
                    'Pamuk bugün çok enerjik görünüyor!',
                  );
                },
                icon: Icons.message,
                label: '💬 Eş Sahip Mesaj Bildirimi',
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              
              _buildTestButton(
                onPressed: () {
                  NotificationService.showLowValueNotification(
                    'Pamuk',
                    'mutluluk',
                  );
                },
                icon: Icons.info,
                label: '⚠️ Düşük Değer Bildirimi',
                color: Colors.amber,
              ),
              const SizedBox(height: 30),
              
              const Divider(color: Colors.white30, thickness: 1),
              const SizedBox(height: 25),
              
              const Text(
                'Bildirim Özellikleri:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              _buildNotificationInfo(
                '🔵 Mavi Arka Plan',
                'Tüm bildirimlerde mavi renk kullanılıyor',
                const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 12),
              
              _buildNotificationInfo(
                '🐾 Pati İkonu',
                'Bildirim ikonu olarak mavi arka plan üzerinde beyaz pati izi',
                const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 12),
              
              _buildNotificationInfo(
                '📱 Uygulama İkonu',
                'Büyük ikon olarak uygulama logosu gösteriliyor',
                const Color(0xFF3B82F6),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTestButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 28),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
  
  Widget _buildNotificationInfo(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
