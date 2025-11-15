import 'dart:collection';

import 'package:flutter/material.dart';

class ItemTypeDropdown extends StatefulWidget {
  const ItemTypeDropdown({super.key});

  @override
  State<ItemTypeDropdown> createState() => _ItemTypeDropdownState();
}

const List<String> list = <String>[
  'food',
  'medical supplies',
  'clothes',
  'blankets',
  'other',
];

typedef MenuEntry = DropdownMenuEntry<String>;

class _ItemTypeDropdownState extends State<ItemTypeDropdown> {
  static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    list.map<MenuEntry>(_convertStringToMenuEntry),
  );

  static MenuEntry _convertStringToMenuEntry(String name) =>
      MenuEntry(value: name, label: name);
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      // initialSelection: list.first,
      hintText: 'select item',
      onSelected: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      dropdownMenuEntries: menuEntries,
      width: 320,
    );
  }
}
