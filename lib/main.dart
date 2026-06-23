DropdownSearch<String>(
  items: ['Item 1', 'Item 2', 'Item 3'],
  dropdownButtonProps: DropdownButtonProps(
    icon: const Icon(Icons.keyboard_arrow_down),
  ),
  dropdownDecoratorProps: DropDownDecoratorProps(
    textAlign: TextAlign.center,
    baseStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    dropdownSearchDecoration: InputDecoration(
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
  ),
)
