import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('DropdownSearch Örneği')),
        body: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: ColorDropdown(),
          ),
        ),
      ),
    );
  }
}

class ColorItem {
  final String name;
  final Color color;
  ColorItem(this.name, this.color);

  @override
  String toString() => name;
}

class ColorDropdown extends StatelessWidget {
  const ColorDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <ColorItem>[
      ColorItem("Red", Colors.red),
      ColorItem("Black", Colors.black),
      ColorItem("Yellow", Colors.yellow),
      ColorItem("Blue", Colors.blue),
    ];

    return DropdownSearch<ColorItem>(
      items: items,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, item, isSelected) => Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: item?.color ?? Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item?.name ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
      compareFn: (item1, item2) => item1?.name == item2?.name,
      dropdownBuilder: (ctx, selectedItem) => Icon(
        Icons.face,
        color: selectedItem?.color ?? Colors.grey,
        size: 54,
      ),
      onChanged: (v) {},
      // Eğer seçili öğeyi yazdırmak isterseniz itemAsString da ekleyebilirsiniz:
      // itemAsString: (ColorItem? c) => c?.name ?? '',
    );
  }
}
