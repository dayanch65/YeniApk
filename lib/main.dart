import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dropdown Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownSearch<String>(
          items: ['Item 1', 'Item 2', 'Item 3'],
          suffixProps: DropdownSuffixProps(
            dropdownButtonProps: DropdownButtonProps(
              iconClosed: const Icon(Icons.keyboard_arrow_down),
              iconOpened: const Icon(Icons.keyboard_arrow_up),
            ),
          ),
          decoratorProps: DropDownDecoratorProps(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'Please select...',
              hintStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),
            ),
          ),
          popupProps: PopupProps.menu(
            itemBuilder: (context, item, isDisabled, isSelected) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  item,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              );
            },
            constraints: const BoxConstraints(maxHeight: 160),
            menuProps: MenuProps(
              margin: const EdgeInsets.only(top: 12),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
        ),
      ),
    );
  }
}
