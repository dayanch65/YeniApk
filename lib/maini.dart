import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF141415)),
      ),
      home: const AnaEkran(),
    );
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  int _secilenIndeks = 0;

  // Sayfalar arası geçiş yapabilmen için basit içerik listesi
  final List<Widget> _sayfalar = [
    const Center(child: Text('Ana Sayfa İçeriği', style: TextStyle(fontSize: 20, color: Colors.white))),
    const Center(child: Text('Yüklenenler Sayfası İçeriği', style: TextStyle(fontSize: 20, color: Colors.white))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dayanc GNav Projesi'),
        centerTitle: true,
      ),
      body: _sayfalar[_secilenIndeks],
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12), // BB_hova_galdyr_san.12
          decoration: BoxDecoration(
            color: Colors.red, // DD_butona_renk_ber.red
            borderRadius: BorderRadius.circular(20), // DD_butonu_tegelek_et.20
          ),
          child: GNav(
            mainAxisAlignment: MainAxisAlignment.center, // GG_butonlara_yer_bermek_center_left.center
            color: Colors.white, // GG_secilmedik_buton_renk.white
            activeColor: Colors.black, // GG_secilen_buton_renk.black
            gap: 10, // GG_ikon_ile_yazi_arasinda_bosluk.10
            padding: const EdgeInsets.all(10), // GG_butonlarda_yokardan_asak_genislik.10
            selectedIndex: _secilenIndeks,
            onTabChange: (index) {
              setState(() {
                _secilenIndeks = index;
              });
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'ana sayfa', // buton(home, ana sayfa)
              ),
              GButton(
                icon: Icons.download,
                text: 'yuklenenler sayfasi', // buton(downloads, yuklenenler sayfasi)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
