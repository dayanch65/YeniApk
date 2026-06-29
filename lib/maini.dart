import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MaterialApp(home: SesliAramaUygulamasi()));

class SesliAramaUygulamasi extends StatefulWidget {
  const SesliAramaUygulamasi({Key? key}) : super(key: key);

  @override
  State<SesliAramaUygulamasi> createState() => _SesliAramaUygulamasiState();
}

class _SesliAramaUygulamasiState extends State<SesliAramaUygulamasi> {
  // Ses kütüphanesinin yönetim nesneleri
  final RecorderStream _sesKaydedici = RecorderStream();
  final PlayerStream _sesOynatici = PlayerStream();

  // Ağ bağlantı nesneleri
  ServerSocket? _sunucuSoketi;
  Socket? _baglantiSoketi;
  
  final TextEditingController _ipKontrolcu = TextEditingController();
  bool _aramaAktifMi = false;
  String _durumMesaji = "Bağlantı bekleniyor...";

  @override
  void initState() {
    super.initState();
    _izinleriVeSesiHazirla();
  }

  // Cihazdan mikrofon izni alma ve ses motorunu açma adımı
  Future<void> _izinleriVeSesiHazirla() async {
    await Permission.microphone.request();
    await _sesKaydedici.initialize();
    await _sesOynatici.initialize();
  }

  // --- 1. TELEFON: SUNUCU (HOST) OLMA KODLARI ---
  Future<void> _sunucuBaslat() async {
    try {
      // Telefonun Wi-Fi ağındaki her IP'yi dinleyecek şekilde 4444 portundan sunucu açıyoruz
      _sunucuSoketi = await ServerSocket.bind(InternetAddress.anyIPv4, 4444);
      setState(() {
        _durumMesaji = "Sunucu açıldı! Diğer telefondan bu IP'ye bağlanın.";
      });

      // İkinci telefon bağlandığı an burası tetiklenir
      _sunucuSoketi!.listen((Socket istemci) {
        _baglantiSoketi = istemci;
        _aramayiBaslat();
      });
    } catch (e) {
      setState(() => _durumMesaji = "Sunucu başlatılamadı: $e");
    }
  }

  // --- 2. TELEFON: İSTEMCİ (CLIENT) OLMA KODLARI ---
  Future<void> _sunucuyaBaglan() async {
    if (_ipKontrolcu.text.isEmpty) return;
    try {
      // Kutudan yazılan IP adresine ve 4444 portuna bağlantı isteği atıyoruz
      _baglantiSoketi = await Socket.connect(_ipKontrolcu.text, 4444);
      _aramayiBaslat();
    } catch (e) {
      setState(() => _durumMesaji = "Bağlantı hatası: $e");
    }
  }

  // --- ORTAK SES TRANSFER MANTIĞI ---
  void _aramayiBaslat() {
    setState(() {
      _aramaAktifMi = true;
      _durumMesaji = "Arama başladı! Konuşabilirsiniz.";
    });

    // Hoparlörü ve mikrofonu aktif ediyoruz
    _sesKaydedici.start();
    _sesOynatici.start();

    // A) MİKROFONDAN GELEN SESİ KARŞIYA GÖNDERME:
    // Mikrofon ortamdaki sesi yakaladıkça bu dinleyici tetiklenir ve veriyi sokete yazar
    _sesKaydedici.audioStream.listen((Uint8List sesVerisi) {
      _baglantiSoketi?.add(sesVerisi);
    });

    // B) KARŞIDAN GELEN SESİ HOPARLÖRDEN ÇALMA:
    // Soketten (karşı telefondan) ses verisi geldikçe bunu hoparlör akışına yazıp çaldırıyoruz
    _baglantiSoketi!.listen(
      (Uint8List gelenSesVerisi) {
        _sesOynatici.writeChunk(gelenSesVerisi);
      },
      onDone: _aramayiKapat,
      onError: (e) => _aramayiKapat(),
    );
  }

  void _aramayiKapat() {
    _sesKaydedici.stop();
    _sesOynatici.stop();
    _baglantiSoketi?.destroy();
    _sunucuSoketi?.close();
    setState(() {
      _aramaAktifMi = false;
      _durumMesaji = "Arama sonlandırıldı.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("P2P Wi-Fi Sesli Arama")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_durumMesaji, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 40),
            
            if (!_aramaAktifMi) ...[
              // SUNUCU OLMA BUTONU
              ElevatedButton.icon(
                icon: const Icon(Icons.router),
                label: const Text("1. Telefon: Sunucuyu Başlat"),
                onPressed: _sunucuBaslat,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              
              // İSTEMCİ GİRİŞ ALANI
              TextField(
                controller: _ipKontrolcu,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sunucu Telefonun IP Adresini Girin',
                  hintText: 'Örn: 192.168.1.35',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text("2. Telefon: Sunucuya Bağlan"),
                onPressed: _sunucuyaBaglan,
              ),
            ] else ...[
              // ARAMAYI KAPATMA BUTONU
              styleElevatedButtonKapat(),
            ]
          ],
        ),
      ),
    );
  }

  Widget styleElevatedButtonKapat() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      icon: const Icon(Icons.call_end, color: Colors.white),
      label: const Text("Aramayı Kapat", style: TextStyle(color: Colors.white)),
      onPressed: _aramayiKapat,
    );
  }
}
