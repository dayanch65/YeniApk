// main.dart
import 'Main3.dart'; // Kendi kütüphaneni buraya bağlıyorsun

void main() {
  // runApp yerine kendi takma adımız!
  uygulamayiBaslat(const BenimUygulamam());
}

// StatelessWidget yerine SabitTasarim kullandık
class BenimUygulamam extends SabitTasarim {
  const BenimUygulamam({super.key});

  @override
  // Widget yerine Bilesen, BuildContext yerine Baglam kullandık
  Bilesen build(Baglam context) {
    // MaterialApp yerine AnaUygulama
    return AnaUygulama(
      debugShowCheckedModeBanner: false,
      title: 'Sohbet Uygulamam',
      theme: TemaVerisi(primarySwatch: Renkler.teal), // Colors yerine Renkler
      home: const SohbetEkrani(),
    );
  }
}

class SohbetEkrani extends SabitTasarim {
  const SohbetEkrani({super.key});

  @override
  Bilesen build(Baglam context) {
    // Scaffold yerine Iskelet
    return Iskelet(
      appBar: UstBar( // AppBar yerine UstBar
        title: const Yazi('Mesajlar'), // Text yerine Yazi
        backgroundColor: Renkler.teal,
      ),
      body: Liste( // ListView yerine Liste
        children: const [
          ListeElemani( // ListTile yerine ListeElemani
            leading: YuvarlakProfil( // CircleAvatar yerine YuvarlakProfil
              backgroundColor: Renkler.black87,
              child: Yazi('D', style: YaziStili(color: Renkler.white)), // TextStyle yerine YaziStili
            ),
            title: Yazi('Dayanç'),
            subtitle: Yazi('Sistemi kurdum, APK alıyorum!'),
            trailing: Yazi('Şimdi'),
          ),
          ListeElemani(
            leading: YuvarlakProfil(child: Yazi('A')),
            title: Yazi('Ahmet'),
            subtitle: Yazi('Yarın okulda görüşürüz.'),
            trailing: Yazi('14:30'),
          ),
        ],
      ),
      floatingActionButton: YuvarlakButon( // FloatingActionButton yerine YuvarlakButon
        onPressed: () {},
        backgroundColor: Renkler.teal,
        child: const Simge(Simgeler.add), // Icon yerine Simge, Icons yerine Simgeler
      ),
    );
  }
}
