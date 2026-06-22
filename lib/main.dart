DropdownSearch<(String, Color)>(
  clickProps: ClickProps(borderRadius: BorderRadius.circular(20)),
  mode: Mode.CUSTOM,
  items: (f, cs) => [
    ("Red", Colors.red),
    ("Black", Colors.black),
    ("Yellow", Colors.yellow),
    ('Blue', Colors.blue),
  ],
  compareFn: (item1, item2) => item1.$1 == item2.$1,
  popupProps: PopupProps.menu(
  menuProps: MenuProps(align: MenuAlign.bottomCenter),
    fit: FlexFit.loose,
    itemBuilder: (context, item, isDisabled, isSelected) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(item.$1, style: TextStyle(color: item.$2, fontSize: 16)),
    ),
  ),
  dropdownBuilder: (ctx, selectedItem) => Icon(Icons.face, color: selectedItem?.$2, size: 54),
),
