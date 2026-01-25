import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item_category.dart';

class ItemTypeDropdown extends StatefulWidget {
  const ItemTypeDropdown({super.key, this.onSelected});

  final void Function(ItemCategory?)? onSelected;

  @override
  State<ItemTypeDropdown> createState() => _ItemTypeDropdownState();
}

class _ItemTypeDropdownState extends State<ItemTypeDropdown> {
  final list = <ItemCategory>[
    ItemCategory(
      categoryName: 'Food',
      icon: Icons.restaurant,
    ),
    ItemCategory(
      categoryName: 'Medical Supplies',
      icon: Icons.medical_services_rounded,
    ),
    ItemCategory(
      categoryName: 'Clothes',
      icon: Icons.checkroom,
    ),
    ItemCategory(
      categoryName: 'Blankets',
      icon: Icons.bed,
    ),
    ItemCategory(
      categoryName: 'Other',
      icon: Icons.grid_view_sharp,
    ),
  ];

  ItemCategory? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ItemCategory>(
      value: dropdownValue,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        hintText: 'Select item category',
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
        ),
      ),
      items: list.map((ItemCategory item) {
        return DropdownMenuItem<ItemCategory>(
          value: item,
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: const Color(0xFF1E88E5)),
              const SizedBox(width: 12),
              Text(
                item.categoryName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (ItemCategory? value) {
        setState(() {
          dropdownValue = value;
        });
        widget.onSelected?.call(value);
      },
    );
  }
}
