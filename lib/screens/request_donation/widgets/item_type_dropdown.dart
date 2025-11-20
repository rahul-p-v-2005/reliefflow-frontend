import 'dart:collection';
// import 'package:iconoir_flutter/iconoir_flutter.dart';
import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item_category.dart';

class ItemTypeDropdown extends StatefulWidget {
  const ItemTypeDropdown({super.key, this.onSelected});

  final void Function(ItemCategory?)? onSelected;

  @override
  State<ItemTypeDropdown> createState() => _ItemTypeDropdownState();
}

typedef MenuEntry = DropdownMenuEntry<ItemCategory>;

class _ItemTypeDropdownState extends State<ItemTypeDropdown> {
  final list = <ItemCategory>[
    ItemCategory(
      categoryName: 'food',
      icon: Icons.restaurant,
    ),
    ItemCategory(
      categoryName: 'medical supplies',
      icon: Icons.medical_services_rounded,
    ),
    ItemCategory(
      categoryName: 'clothes',
      icon: Icons.checkroom,
    ),
    ItemCategory(
      categoryName: 'blankets',
      icon: Icons.bed,
    ),
    ItemCategory(
      categoryName: 'other',
      icon: Icons.grid_view_sharp,
    ),
  ];

  late final menuEntries = UnmodifiableListView<MenuEntry>(
    list.map(_convertItemToMenuEntry),
  );

  static MenuEntry _convertItemToMenuEntry(ItemCategory item) => MenuEntry(
    value: item,
    label: item.categoryName,
    leadingIcon: Icon(item.icon),
  );

  ItemCategory? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<ItemCategory>(
      hintText: 'select item',
      onSelected: (ItemCategory? value) {
        setState(() {
          dropdownValue = value;
          widget.onSelected?.call(value);
        });
      },
      dropdownMenuEntries: menuEntries,
      width: 360,
    );
  }
}
