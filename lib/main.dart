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
      title: 'LAN Sohbet',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LAN Sohbet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ServerPage()));
              },
              child: const Text('Sunucu Başlat (Bekle)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ClientPage()));
              },
              child: const Text('Bağlan (IP gir)'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- SUNUCU ----------
class ServerPage extends StatefulWidget {
  const ServerPage({super.key});
  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  ServerSocket? _serverSocket;
  String _status = 'Başlatılıyor...';

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    final myIp = await _getLocalIp();
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 4040);
    setState(() => _status = 'Bekleniyor...\nIP: $myIp  Port: 4040');

    _serverSocket!.listen((client) {
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => ChatPage(socket: client)));
    });
  }

  Future<String?> _getLocalIp() async {
    for (final i in await NetworkInterface.list()) {
      for (final addr in i.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          return addr.address;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _serverSocket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sunucu')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

// ---------- İSTEMCİ ----------
class ClientPage extends StatefulWidget {
  const ClientPage({super.key});
  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final _ipController = TextEditingController();
  String _status = '';

  Future<void> _connect() async {
    setState(() => _status = 'Bağlanıyor...');
    try {
      final socket = await Socket.connect(_ipController.text.trim(), 4040);
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => ChatPage(socket: socket)));
    } catch (e) {
      setState(() => _status = 'Bağlanamadı: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bağlan')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Sunucunun IP adresi',
                hintText: 'Örn: 192.168.1.5',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _connect, child: const Text('Bağlan')),
            const SizedBox(height: 16),
            Text(_status),
          ],
        ),
      ),
    );
  }
}

// ---------- SOHBET EKRANI ----------
class ChatPage extends StatefulWidget {
  final Socket socket;
  const ChatPage({super.key, required this.socket});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<String> _messages = [];
  final _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.socket.listen(
      (data) => setState(() => _messages.add('Karşı taraf: ${utf8.decode(data)}')),
      onDone: () => setState(() => _messages.add('Bağlantı kesildi.')),
    );
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    widget.socket.write(text);
    setState(() => _messages.add('Ben: $text'));
    _msgController.clear();
  }

  @override
  void dispose() {
    widget.socket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sohbet')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(_messages[i]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: 'Mesaj yaz...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
