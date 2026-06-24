import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  // Android yerel ağ (Cleartext) güvenlik duvarını aşan kod
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dayanç Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(), // Uygulama artık IP sorma ekranıyla başlıyor
    );
  }
}

// --- 1. EKRAN: IP ADRESİ GİRME EKRANI ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Senin tabletin IP'sini varsayılan olarak kutuya yazdık, istersen silip değiştirebilirsin
  final TextEditingController _ipController = TextEditingController(text: "192.168.1.110");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sunucuya Bağlan")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Tabletteki Termux IP Adresini Girin:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Örn: 192.168.1.110",
                prefixIcon: Icon(Icons.wifi),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                // IP adresini al ve Chat Ekranına geç
                if (_ipController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(ipAddress: _ipController.text),
                    ),
                  );
                }
              },
              child: const Text("Bağlan ve Mesajlaş", style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}

// --- 2. EKRAN: MESAJLAŞMA EKRANI ---
class ChatScreen extends StatefulWidget {
  final String ipAddress;
  const ChatScreen({super.key, required this.ipAddress});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<String> messages = [];
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() {
    try {
      // Bir önceki ekrandan girilen IP adresini kullanarak bağlanıyor
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://${widget.ipAddress}:8000'),
      );

      _channel.stream.listen(
        (message) {
          setState(() {
            messages.add("Arkadaşın: $message");
          });
        },
        onError: (error) {
          setState(() {
            messages.add("⚠️ SİSTEM: Bağlantı hatası! Termux açık mı? Aynı Wi-Fi'de misiniz?");
          });
        },
      );
    } catch (e) {
      setState(() {
        messages.add("⚠️ SİSTEM: Kritik Hata: $e");
      });
    }
  }

  void _sendMessage() {
    if (_msgController.text.isNotEmpty) {
      _channel.sink.add(_msgController.text);
      setState(() {
        messages.add("Sen: ${_msgController.text}");
      });
      _msgController.clear();
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bağlı: ${widget.ipAddress}"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Card(
                  color: messages[index].startsWith("Sen:") ? Colors.blue[100] : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(messages[index], style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: "Mesaj gönder...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
