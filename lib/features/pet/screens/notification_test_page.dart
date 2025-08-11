import 'package:flutter/material.dart';
import '../../../services/notification_service.dart';

class NotificationTestPage extends StatelessWidget {
  const NotificationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Test Sayfası'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bildirimleri test etmek için aşağıdaki butonları kullanın:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Kritik durum bildirimi testi
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.showCriticalStatusNotification(
                  'Pamuk',
                  'tokluk',
                );
              },
              icon: const Icon(Icons.warning, color: Colors.red),
              label: const Text('🚨 Kritik Durum Bildirimi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[900],
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Doğum günü bildirimi testi
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.showBirthdayNotification('Pamuk');
              },
              icon: const Icon(Icons.cake, color: Colors.orange),
              label: const Text('🎉 Doğum Günü Bildirimi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[100],
                foregroundColor: Colors.orange[900],
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Aşı vakti bildirimi testi
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.showVaccineDueNotification(
                  'Pamuk',
                  'Kuduz Aşısı',
                );
              },
              icon: const Icon(Icons.medical_services, color: Colors.blue),
              label: const Text('💉 Aşı Vakti Bildirimi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[900],
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Eş sahip mesaj bildirimi testi
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.showCoOwnerMessageNotification(
                  'Pamuk',
                  'Ahmet',
                  'Pamuk bugün çok enerjik görünüyor!',
                );
              },
              icon: const Icon(Icons.message, color: Colors.green),
              label: const Text('💬 Eş Sahip Mesaj Bildirimi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[100],
                foregroundColor: Colors.green[900],
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Düşük değer bildirimi testi
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.showLowValueNotification(
                  'Pamuk',
                  'mutluluk',
                );
              },
              icon: const Icon(Icons.info, color: Colors.amber),
              label: const Text('⚠️ Düşük Değer Bildirimi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[100],
                foregroundColor: Colors.amber[900],
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            
            const Divider(),
            const SizedBox(height: 20),
            
            const Text(
              'Bildirim Türleri:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            _buildNotificationInfo(
              '🚨 Kritik Durum',
              'Evcil hayvan değerleri 1 veya 0 olduğunda',
              Colors.red,
            ),
            _buildNotificationInfo(
              '🎉 Doğum Günü',
              'Evcil hayvanın doğum günü geldiğinde',
              Colors.orange,
            ),
            _buildNotificationInfo(
              '💉 Aşı Vakti',
              'Aşı tarihi geldiğinde',
              Colors.blue,
            ),
            _buildNotificationInfo(
              '💬 Eş Sahip Mesajı',
              'Eş sahiplerden mesaj geldiğinde',
              Colors.green,
            ),
            _buildNotificationInfo(
              '⚠️ Düşük Değer',
              'Evcil hayvan değerleri 2 olduğunda',
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationInfo(String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
