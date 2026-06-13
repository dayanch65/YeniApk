import 'package:flutter/material.dart';

void main() => runApp(const FilmUygulamam());

class FilmUygulamam extends StatelessWidget {
  const FilmUygulamam({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const AnaGezinti(),
    );
  }
}

class AnaGezinti extends StatefulWidget {
  const AnaGezinti({super.key});

  @override
  State<AnaGezinti> createState() => _AnaGezintiState();
}

class _AnaGezintiState extends State<AnaGezinti> {
  int _index = 0;
  final List<Widget> _sayfalar = [
    const AnaSayfa(),
    const GözlegSayfasi(),
    const YuklenenlerSayfasi(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sayfalar[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Gözleg'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Ýüklenenler'),
        ],
      ),
    );
  }
}

// 1. ANA SAYFA
class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(height: 400, color: Colors.grey[900], child: const Center(child: Text("Büyük Poster Resmi"))),
        const Padding(padding: EdgeInsets.all(8.0), child: Text("Dowamyny serediň", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        SizedBox(height: 150, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 5, itemBuilder: (c, i) => Container(width: 100, margin: const EdgeInsets.all(5), color: Colors.grey))),
      ],
    );
  }
}

// 2. GÖZLEG SAYFASI
class GözlegSayfasi extends StatelessWidget {
  const GözlegSayfasi({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(16.0), child: TextField(decoration: InputDecoration(hintText: "Atlar, adamlary gözlemek...", filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.7),
            itemCount: 9,
            itemBuilder: (c, i) => Container(margin: const EdgeInsets.all(5), color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}

// 3. YÜKLENENLER SAYFASI
class YuklenenlerSayfasi extends StatelessWidget {
  const YuklenenlerSayfasi({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ýüklenenler"), backgroundColor: Colors.transparent),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (c, i) => ListTile(
          leading: Container(width: 60, height: 80, color: Colors.grey),
          title: const Text("Film Adı"),
          subtitle: const Text("2s 49m · 1.87 GB"),
          trailing: const Icon(Icons.download_done),
        ),
      ),
    );
  }
}
