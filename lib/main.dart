import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  // Android yerel ağ (HTTP/WS) bağlantı engelini KOD İÇİNDEN tamamen kaldırıyoruz
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

// Güvenlik duvarını ve cleartext engelini aşan sınıf
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [];
  
  late WebSocketChannel _channel;
  bool isConnected = false;
  String connectionStatus = "Bağlanıyor...";

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  // Sunucuya bağlanma fonksiyonu
  void _connectToServer() {
    try {
      // Senin tabletinin IP adresi ve portu
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.1.110:8000'),
      );

      // Gelen mesajları dinle
      _channel.stream.listen(
        (message) {
          setState(() {
            messages.add("Arkadaşın: $message");
          });
        },
        onError: (error) {
          setState(() {
            connectionStatus = "Hata Oluştu! Tekrar deneniyor...";
            isConnected = false;
          });
          // Hata olursa 3 saniye sonra otomatik tekrar bağlanmayı dene
          Future.delayed(const Duration(seconds: 3), _connectToServer);
        },
        onDone: () {
          setState(() {
            connectionStatus = "Bağlantı Kesildi! Tekrar bağlanıyor...";
            isConnected = false;
          });
          Future.delayed(const Duration(seconds: 3), _connectToServer);
        },
      );

      setState(() {
        isConnected = true;
        connectionStatus = "Bağlantı Başarılı!";
      });
    } catch (e) {
      setState(() {
        connectionStatus = "Bağlantı Başarısız: $e";
        isConnected = false;
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && isConnected) {
      // Mesajı ağ üzerinden sunucuya gönderir
      _channel.sink.add(_controller.text);
      
      setState(() {
        messages.add("Sen: ${_controller.text}");
      });
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dayanç Imo Chat'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // Bağlantı durumunu gösteren küçük bir ışık/yazı
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 12,
                ),
                const SizedBox(width: 5),
                Text(
                  connectionStatus,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mesaj Listesi
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.startsWith("Sen:");
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            // Giriş Alanı
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Mesaj yazın...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: isConnected ? _sendMessage : null, // Bağlı değilse buton basmaz
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
