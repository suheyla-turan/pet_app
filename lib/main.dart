import 'package:flutter/material.dart';

void main() {
  runApp(const MiniPetApp());
}

class MiniPetApp extends StatelessWidget {
  const MiniPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Pet',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const AnaSayfa(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int aclik = 5;
  int mutluluk = 5;
  int enerji = 5;

  void besle() {
    setState(() {
      aclik = (aclik > 0) ? aclik - 1 : 0;
    });
  }

  void sev() {
    setState(() {
      mutluluk = (mutluluk < 10) ? mutluluk + 1 : 10;
    });
  }

  void uyut() {
    setState(() {
      enerji = (enerji < 10) ? enerji + 1 : 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 Mini Pet'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // 🐶 Evcil Hayvan Görseli
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/golden.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 32),
            // 📊 Göstergeler
            buildGosterge("Açlık", aclik),
            buildGosterge("Mutluluk", mutluluk),
            buildGosterge("Enerji", enerji),
            const SizedBox(height: 24),
            // 🔘 Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: besle,
                  icon: const Icon(Icons.fastfood),
                  label: const Text("Besle"),
                ),
                ElevatedButton.icon(
                  onPressed: sev,
                  icon: const Icon(Icons.favorite),
                  label: const Text("Sev"),
                ),
                ElevatedButton.icon(
                  onPressed: uyut,
                  icon: const Icon(Icons.bedtime),
                  label: const Text("Uyut"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 🔄 Göstergeleri oluşturan fonksiyon
  Widget buildGosterge(String ad, int deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(ad, style: const TextStyle(fontSize: 18))),
          Expanded(
            flex: 5,
            child: LinearProgressIndicator(
              value: deger / 10,
              minHeight: 10,
              color: Colors.teal,
              backgroundColor: Colors.teal.shade100,
            ),
          ),
          const SizedBox(width: 8),
          Text(deger.toString(), style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
