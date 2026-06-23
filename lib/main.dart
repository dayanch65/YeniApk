import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
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
  
  // !!! BURAYA TABLETİNİN IP ADRESİNİ YAZMALISIN !!!
  // Örnek: ws://192.168.1.5:8000
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.1.X:8000'), 
  );

  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    // Sunucudan gelen mesajları sürekli dinle
    _channel.stream.listen((message) {
      setState(() {
        messages.add("Arkadaşın: $message");
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      // Mesajı sunucuya gönder
      _channel.sink.add(_controller.text);
      
      setState(() {
        messages.add("Sen: ${_controller.text}");
      });
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _channel.sink.close(); // Uygulama kapanırken bağlantıyı güvenli kapat
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dayanç Imo Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mesajların Listelendiği Alan
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
            // Mesaj Yazma ve Gönderme Alanı
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Mesaj yazın...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
