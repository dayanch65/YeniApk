import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(const MaterialApp(home: GercekSesliArama()));
}

class GercekSesliArama extends StatefulWidget {
  const GercekSesliArama({super.key});

  @override
  State<GercekSesliArama> createState() => _GercekSesliAramaState();
}

class _GercekSesliAramaState extends State<GercekSesliArama> {
  late IO.Socket socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  String durum = "Santrale Bağlanıyor...";

  @override
  void initState() {
    super.initState();
    _santraleBaglan();
  }

  // === 1. SANTRALE BAĞLANMA VE DİNLEME ===
  void _santraleBaglan() {
    // BURAYA TABLETİNİN IP ADRESİNİ YAZ (Örn: 192.168.1.5)
    socket = IO.io('http://192.168.1.106:8080', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      setState(() => durum = "Santrale Bağlandı 🟢");
    });

    // Biri bizi ararsa (Teklif gelirse) otomatik cevap ver
    socket.on('teklif_geldi', (data) async {
      setState(() => durum = "Arama Geldi, Açılıyor... 📞");
      await _borulariBagla();
      
      // Karşının ses kodunu kaydet
      await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(data['sdp'], data['type']));
      
      // Kendi cevabımızı (Answer) oluştur ve santralden karşıya yolla
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      socket.emit('cevap_gonder', {'sdp': answer.sdp, 'type': answer.type});
      
      setState(() => durum = "Konuşuyorsunuz 🎙️");
    });

    // Aradığımız kişi telefonu açarsa (Cevap gelirse)
    socket.on('cevap_geldi', (data) async {
      await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(data['sdp'], data['type']));
      setState(() => durum = "Konuşuyorsunuz 🎙️");
    });

    // Sanal kablo bağlantıları (ICE) gelirse sisteme ekle
    socket.on('ice_adayi_geldi', (data) {
      if (data != null) {
        _peerConnection!.addCandidate(RTCIceCandidate(
            data['candidate'], data['sdpMid'], data['sdpMLineIndex']));
      }
    });
  }

  // === 2. MİKROFONU VE WEB-RTC MOTORUNU AÇMA (BORULARI BAĞLAMA) ===
  Future<void> _borulariBagla() async {
    // Google'ın bedava ses yönlendirme sunucuları (STUN)
    Map<String, dynamic> ayarlar = {
      "iceServers": [ {"url": "stun:stun.l.google.com:19302"} ]
    };

    _peerConnection = await createPeerConnection(ayarlar);

    // Kendi mikrofonumuzu açıyoruz
    final Map<String, dynamic> mikrofonAyari = {'audio': true, 'video': false};
    _localStream = await navigator.mediaDevices.getUserMedia(mikrofonAyari);

    // Sesi dışarı (Hoparlöre) veriyoruz ki rahat duyulsun
    Helper.setSpeakerphoneOn(true);

    // Mikrofonumuzdan gelen sesi WebRTC borusuna ekliyoruz
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    // Boru hattı (ICE) oluştukça santral üzerinden karşıya gönder
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      socket.emit('ice_adayi_gonder', {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex
      });
    };
  }

  // === 3. ARAMA YAPMA BUTONU FONKSİYONU ===
  Future<void> _aramaYap() async {
    setState(() => durum = "Aranıyor... ⏳");
    await _borulariBagla();

    // Arama teklifi (Offer) oluştur ve santralden yolla
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    
    socket.emit('teklif_gonder', {'sdp': offer.sdp, 'type': offer.type});
  }

  // Kapatma işlemi
  void _aramayiKapat() {
    _localStream?.dispose();
    _peerConnection?.close();
    setState(() => durum = "Arama Kapatıldı 🔴");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DURUM YAZISI
            Text(durum, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 50, width: double.infinity),

            // ARAMA BUTONU
            ElevatedButton.icon(
              onPressed: _aramaYap,
              icon: const Icon(Icons.call, size: 25, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              label: const Text('Ara', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),

            const SizedBox(height: 20),

            // KAPATMA BUTONU
            ElevatedButton.icon(
              onPressed: _aramayiKapat,
              icon: const Icon(Icons.call_end, size: 25, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              label: const Text('Kapat', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
