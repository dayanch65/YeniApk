import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YerelIletisimUygulamasi());
}

class YerelIletisimUygulamasi extends StatelessWidget {
  const YerelIletisimUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF141415)),
      ),
      home: const AnaIletisimEkrani(),
    );
  }
}

class AnaIletisimEkrani extends StatefulWidget {
  const AnaIletisimEkrani({super.key});

  @override
  State<AnaIletisimEkrani> createState() => _AnaIletisimEkraniState();
}

class _AnaIletisimEkraniState extends State<AnaIletisimEkrani> {
  final SoundStreamRecorder _sesKaydedici = SoundStreamRecorder();
  final SoundStreamPlayer _sesOynatici = SoundStreamPlayer();
  
  ServerSocket? _tcpMesajSunucusu;
  RawDatagramSocket? _udpSesSoketi;
  
  String _cihazIpAdresi = "Yükleniyor...";
  bool _sesliAramaAktifMi = false;

  final TextEditingController _hedefIpController = TextEditingController();
  final TextEditingController _mesajController = TextEditingController();
  final List<String> _mesajGecmisi = [];

  @override
  void initState() {
    super.initState();
    _sistemiVeIzinleriKur();
  }

  void _sistemiVeIzinleriKur() async {
    await [Permission.microphone, Permission.phone].request();

    await _sesKaydedici.initialize();
    await _sesOynatici.initialize();

    final info = NetworkInfo();
    String? ip = await info.getWifiIP();
    
    if (ip == null || ip.isEmpty) {
      ip = "192.168.43.1 (Veya Wi-Fi Bağlanın)";
    }

    setState(() {
      _cihazIpAdresi = ip!;
    });

    try {
      _tcpMesajSunucusu = await ServerSocket.bind(InternetAddress.anyIPv4, 4444);
      _tcpMesajSunucusu!.listen((Socket istemci) {
        istemci.listen((List<int> veri) {
          String gelenMesaj = utf8.decode(veri);
          setState(() {
            _mesajGecmisi.add("Karşı Taraf: $gelenMesaj");
          });
        });
      });
    } catch (e) {
      debugPrint("TCP Sunucu Hatası: $e");
    }

    try {
      _udpSesSoketi = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5555);
      _udpSesSoketi!.listen((RawSocketEvent etkinlik) {
        if (etkinlik == RawSocketEvent.read) {
          Datagram? paket = _udpSesSoketi!.receive();
          if (paket != null) {
            _sesOynatici.writeChunk(paket.data);
          }
        }
      });
    } catch (e) {
      debugPrint("UDP Soket Hatası: $e");
    }

    _sesKaydedici.audioStream.listen((List<int> sesVerisi) {
      if (_sesliAramaAktifMi && _hedefIpController.text.isNotEmpty) {
        try {
          _udpSesSoketi?.send(
            sesVerisi,
            InternetAddress(_hedefIpController.text.trim()),
            5555,
          );
        } catch (e) {
          debugPrint("Ses Paketi Gönderim Hatası: $e");
        }
      }
    });
  }

  void _mesajGonder() async {
    String hedefIp = _hedefIpController.text.trim();
    String mesaj = _mesajController.text.trim();

    if (hedefIp.isEmpty || mesaj.isEmpty) return;

    try {
      Socket soket = await Socket.connect(hedefIp, 4444, timeout: const Duration(seconds: 2));
      soket.write(mesaj);
      await soket.flush();
      await soket.close();

      setState(() {
        _mesajGecmisi.add("Ben: $mesaj");
        _mesajController.clear();
      });
    } catch (e) {
      setState(() {
        _mesajGecmisi.add("❌ Sistem: Mesaj gönderilemedi. IP'yi kontrol edin.");
      });
    }
  }

  void _sesliAramayiDegistir() async {
    if (_hedefIpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen önce Hedef IP adresini girin!")),
      );
      return;
    }

    if (_sesliAramaAktifMi) {
      await _sesKaydedici.stop();
      await _sesOynatici.stop();
      setState(() {
        _sesliAramaAktifMi = false;
      });
    } else {
      await _sesKaydedici.start();
      await _sesOynatici.start();
      setState(() {
        _sesliAramaAktifMi = true;
      });
    }
  }

  @override
  void dispose() {
    _tcpMesajSunucusu?.close();
    _udpSesSoketi?.close();
    _sesKaydedici.stop();
    _sesOynatici.stop();
    _hedefIpController.dispose();
    _mesajController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yerel Ağ Telsizi & SMS", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Text("Senin IP Adresin: $_cihazIpAdresi", 
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text("Not: Konuşmak için iki cihazın da aynı ağda olması gerekir.", 
                      style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hedefIpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Bağlanılacak Cihazın IP Adresi",
                hintText: "Örn: 192.168.43.25",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.router, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _sesliAramaAktifMi ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _sesliAramayiDegistir,
              icon: Icon(_sesliAramaAktifMi ? Icons.call_end : Icons.call),
              label: Text(_sesliAramaAktifMi ? "Sesi Kapat (Bağlantıyı Kes)" : "Sesli Aramayı Başlat (Telsiz Modu)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 20),
            const Text("SMS / Mesaj geçmişi", style: TextStyle(color: Colors.white54, fontSize: 14)),
            const Divider(color: Colors.white10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141415),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _mesajGecmisi.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(_mesajGecmisi[index], 
                          style: TextStyle(
                            color: _mesajGecmisi[index].startsWith("Ben:") ? Colors.blue.shade300 : Colors.green.shade300,
                            fontSize: 15
                          )),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mesajController,
                    decoration: InputDecoration(
                      hintText: "Mesajınızı yazın...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _mesajGonder,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
