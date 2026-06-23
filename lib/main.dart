import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LAN Messenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚡ LAN Messenger'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.forum, size: 80, color: Colors.teal),
              const SizedBox(height: 10),
              const Text(
                'Aynı Wi-Fi ağındaki arkadaşlarınla anlık mesajlaş!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              _buildMenuButton(
                context,
                title: 'Oda Kur (Sunucu Başlat)',
                icon: Icons.gite,
                color: Colors.teal,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServerPage())),
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context,
                title: 'Odaya Katıl (IP ile Bağlan)',
                icon: Icons.login,
                color: Colors.blueAccent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientPage())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
      ),
    );
  }
}

// ==================== SUNUCU (ODA KURAN) ====================
class ServerPage extends StatefulWidget {
  const ServerPage({super.key});
  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  ServerSocket? _serverSocket;
  final List<Socket> _clients = [];
  final List<Map<String, dynamic>> _messages = [];
  final _msgController = TextEditingController();
  String _serverIp = 'Yükleniyor...';

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    try {
      _serverIp = await _getLocalIp() ?? 'IP Bulunamadı';
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 4545);
      setState(() {});

      _serverSocket!.listen((Socket client) {
        setState(() => _clients.add(client));
        
        // Yeni bir istemci bağlandığında ona hoş geldin de ve dinlemeye başla
        client.listen(
          (data) {
            final msgText = utf8.decode(data);
            _broadcastMessage(msgText, client.remoteAddress.address);
          },
          onDone: () {
            setState(() => _clients.remove(client));
            client.close();
          },
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Future<String?> _getLocalIp() async {
    for (final interface in await NetworkInterface.list()) {
      for (final addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          return addr.address;
        }
      }
    }
    return null;
  }

  void _broadcastMessage(String text, String senderIp) {
    final msgData = {'text': text, 'sender': senderIp, 'isMe': false};
    setState(() => _messages.add(msgData));

    // Gelen mesajı ağdaki diğer her istemciye dağıt (Broadcast)
    for (final client in _clients) {
      try {
        client.write(text);
      } catch (_) {}
    }
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    // Kendimiz (Sunucu) için ekle
    setState(() => _messages.add({'text': 'Sunucu: $text', 'sender': 'Siz', 'isMe': true}));
    
    // Herkese gönder
    for (final client in _clients) {
      try { client.write('Sunucu: $text'); } catch (_) {}
    }
    _msgController.clear();
  }

  @override
  void dispose() {
    for (var c in _clients) { c.close(); }
    _serverSocket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oda Açık | IP: $_serverIp'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ChatUi(messages: _messages, controller: _msgController, onSend: _sendMessage),
    );
  }
}

// ==================== İSTEMCİ (ODAYA KATILAN) ====================
class ClientPage extends StatefulWidget {
  const ClientPage({super.key});
  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final _ipController = TextEditingController();
  Socket? _socket;
  final List<Map<String, dynamic>> _messages = [];
  final _msgController = TextEditingController();
  bool _isConnected = false;
  String _status = 'Bağlanmak için IP girin';

  Future<void> _connect() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;

    setState(() => _status = 'Bağlanılıyor...');
    try {
      _socket = await Socket.connect(ip, 4545, timeout: const Duration(seconds: 5));
      setState(() {
        _isConnected = true;
        _status = 'Bağlandı!';
      });

      _socket!.listen(
        (data) {
          final msgText = utf8.decode(data);
          // Gelen mesaj "Sunucu:" ile başlıyorsa veya bizden değilse
          setState(() {
            _messages.add({'text': msgText, 'sender': 'Oda', 'isMe': false});
          });
        },
        onDone: () {
          setState(() {
            _isConnected = false;
            _status = 'Bağlantı kesildi.';
          });
        },
      );
    } catch (e) {
      setState(() => _status = 'Hata: Odaya bağlanılamadı. IP doğru mu?');
    }
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty || _socket == null) return;

    _socket!.write(text);
    setState(() => _messages.add({'text': text, 'sender': 'Siz', 'isMe': true}));
    _msgController.clear();
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return Scaffold(
        appBar: AppBar(title: const Text('Odaya Katıl')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _ipController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kurucunun IP Adresi',
                  hintText: 'Örn: 192.168.1.X',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wifi),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: _connect,
                child: const Text('Bağlan'),
              ),
              const SizedBox(height: 20),
              Text(_status, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Grup Sohbeti'), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      body: ChatUi(messages: _messages, controller: _msgController, onSend: _sendMessage),
    );
  }
}

// ==================== ORTAK SOHBET ARAYÜZÜ (CHAT UI) ====================
class ChatUi extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatUi({super.key, required this.messages, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final msg = messages[i];
              final bool isMe = msg['isMe'] ?? false;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.teal[400] : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                      bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (!isMe) Text(msg['sender'], style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(msg['text'], style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Mesajınızı yazın...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.send, color: Colors.teal), onPressed: onSend),
            ],
          ),
        ),
      ],
    );
  }
}
