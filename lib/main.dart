import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @key
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('DropdownSearch Örneği')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ColorDropdown(),
          ),
        ),
      ),
    );
  }
}

class ColorDropdown extends StatelessWidget {
  const ColorDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    // Tip tanımı: (String, Color) Record yapısı
    return DropdownSearch<(String, Color)>(
      // Yeni sürümlerde clickProps yerine decoratorProps veya açılır menü özellikleri kullanılır
      popupProps: PopupProps.menu(
        menuProps: const MenuProps(
          align: MenuAlign.bottom,
          backgroundColor: Colors.white,
        ),
        fit: FlexFit.loose,
        itemBuilder: (context, item, isDisabled, isSelected) => Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: item.$2,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item.$1,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
      items: (filter, loadProps) => [
        ("Red", Colors.red),
        ("Black", Colors.black),
        ("Yellow", Colors.yellow),
        ("Blue", Colors.blue),
      ],
      compareFn: (item1, item2) => item1.$1 == item2.$1,
      dropdownBuilder: (ctx, selectedItem) => Icon(
        Icons.face,
        color: selectedItem?.$2 ?? Colors.grey,
        size: 54,
      ),
    );
  }
}
