import 'package:flutter/material.dart';
DropdownSearch<String>(
  items: ['Item 1', 'Item 2', 'Item 3'], // !! Fonksiyon değil, direkt liste ver !!
  suffixProps: DropdownSuffixProps(
    dropdownButtonProps: DropdownButtonProps(
      iconClosed: Icon(Icons.keyboard_arrow_down),
      iconOpened: Icon(Icons.keyboard_arrow_up),
    ),
  ),
  decoratorProps: DropDownDecoratorProps(
    textAlign: TextAlign.center,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      hintText: 'Please select...',
      hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),
    ),
  ),
  popupProps: PopupProps.menu(
    itemBuilder: (context, item, isDisabled, isSelected) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          item,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    },
    constraints: BoxConstraints(maxHeight: 160),
    menuProps: MenuProps(
      margin: EdgeInsets.only(top: 12),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
  ),
),
