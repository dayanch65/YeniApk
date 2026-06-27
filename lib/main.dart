import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart'; // Eksik import eklendi

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // --- SENİN ORİJİNAL KODUN BURADAN BAŞLIYOR ---
  int _nom1 = 0;
  final List<Widget> _nom2 = [
    Center(child: Text("selam")),
    Center(child: Text("merhaba")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _nom2[_nom1],
      bottomNavigationBar: GNav(
        selectedIndex: _nom1,
        onTabChange: (index) {
          setState(() {
            _nom1 = index;
          });
        },
        tabs: [
          GButton(
            icon: Icons.home,
            text: 'aasayfa',
          ),
          GButton(
            icon: Icons.search,
            text: 'search',
          ),
        ],
      ),
    );
  }
  // --- SENİN ORİJİNAL KODUN BURADA BİTİYOR ---
}
