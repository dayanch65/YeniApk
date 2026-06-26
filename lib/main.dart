import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const LocalChatScreen(),
    );
  }
}

class LocalChatScreen extends StatefulWidget {
  const LocalChatScreen({Key? key}) : super(key: key);

  @override
  State<LocalChatScreen> createState() => _LocalChatScreenState();
}

class _LocalChatScreenState extends State<LocalChatScreen> {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  final List<String> _messages = [];
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  bool _isServer = false;
  bool _isConnected = false;
  String _localIp = "Bilinmiyor";
  final int _port = 4545; // Haberleşme portu

  @override
  void initState() {
    super.initState();
    _getOldLocalIp();
  }

  // Telefonun o anki Wi-Fi yerel IP'sini bulur (Örn: 192.168.1.X)
  Future<void> _getOldLocalIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          setState(() {
            _localIp = addr.address;
          });
        }
      }
    }
  }

  // SERVER (SUNUCU) BAŞLATMA
  void _startServer() async {
    try {
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, _port);
      setState(() {
        _isServer = true;
        _isConnected = true;
        _messages.add("Sunucu $_port portunda başlatıldı. Bağlantı bekleniyor...");
      });

      _serverSocket!.listen((Socket client) {
        _clientSocket = client;
        setState(() {
          _messages.add("Bir cihaz bağlandı: ${_clientSocket!.remoteAddress.address}");
        });

        _clientSocket!.listen(
          (data) {
            setState(() {
              _messages.add("Arkadaşın: ${utf8.decode(data)}");
            });
          },
          onDone: () {
            setState(() {
              _messages.add("Arkadaşın bağlantıyı kesti.");
              _isConnected = false;
            });
          },
        );
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  // CLIENT (İSTEMCİ) OLARAK SERVER'A BAĞLANMA
  void _connectToServer() async {
    String serverIp = _ipController.text.trim();
    if (serverIp.isEmpty) return;

    try {
      _clientSocket = await Socket.connect(serverIp, _port);
      setState(() {
        _isServer = false;
        _isConnected = true;
        _messages.add("Sunucuya başarıyla bağlandın!");
      });

      _clientSocket!.listen(
        (data) {
          setState(() {
            _messages.add("Arkadaşın: ${utf8.decode(data)}");
          });
        },
        onDone: () {
          setState(() {
            _messages.add("Sunucu kapandı.");
            _isConnected = false;
          });
        },
      );
    } catch (e) {
      _showError("Bağlantı hatası: IP adresini doğru girdiğinden emin ol.");
    }
  }

  // MESAJ GÖNDERME FONKSİYONU
  void _sendMessage() {
    String text = _messageController.text.trim();
    if (text.isEmpty || _clientSocket == null) return;

    _clientSocket!.write(text);
    setState(() {
      _messages.add("Sen: $text");
      _messageController.clear();
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _serverSocket?.close();
    _clientSocket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Local Imo Messenger'),
        backgroundColor: const Color(0xFF1eb98f),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Üst Kısım: Bağlantı Ayarları
            if (!_isConnected) ...[
              Text("Senin Wi-Fi Yerel IP Adresin: $_localIp", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1eb98f)),
                      onPressed: _startServer,
                      child: const Text("Bu Telefonu SUNUCU Yap", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 2),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ipController,
                      decoration: const InputDecoration(
                        labelText: "Sunucu Telefonun IP Adresini Gir",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: _connectToServer,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text("BAĞLAN", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Bağlantı kurulduğunda durum çubuğu
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.green.shade100,
                width: double.infinity,
                child: Text(
                  _isServer ? "Mod: Sunucu (Bağlantı Aktif)" : "Mod: İstemci (Sunucuya Bağlı)",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Orta Kısım: Mesaj Geçmişi
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(_messages[index], style: const TextStyle(fontSize: 16)),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Alt Kısım: Mesaj Yazma Alanı
            if (_isConnected)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Mesajını yaz...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF1eb98f), size: 30),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
