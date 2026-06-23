import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const VideoApp());
}

class VideoApp extends StatelessWidget {
  const VideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '⚡ Flutter Video Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Videolar karanlık temada daha iyi görünür
      home: const VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    // 1. SEÇENEK: İnternetteki bir video linkini oynatmak için (Şu an bu aktif):
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    );

    // 2. SEÇENEK: APK içine koyduğun videoyu oynatmak için (Üsttekini kapatıp bunu açabilirsin):
    // _controller = VideoPlayerController.asset('assets/video.mp4');

    // Videoyu yükle ve hazır hale getir
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Video yüklendiğinde ekranı güncelle ve otomatik döngüye al
      _controller.setLooping(true);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Ekrandan çıkıldığında video işlemcisini kapat (Hafıza kartını yormasın)
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 Video Oynatıcı'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Video başarıyla yüklendiyse ekranda göster
            return Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    // Alt kısma ilerleme çubuğu ekleyelim
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true, // Elle ileri sarma izni
                      colors: const VideoProgressColors(
                        playedColor: Colors.red,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Video henüz yükleniyorsa loading dönen çemberi göster
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }
        },
      ),
      // Oynat / Durdur Butonu
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          setState(() {
            // Video oynatılıyorsa durdur, duruyorsa oynat
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }
}
