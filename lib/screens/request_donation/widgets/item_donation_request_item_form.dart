import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/added_items.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item_category.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/item_type_dropdown.dart';

class ItemDonationRequestItemForm extends StatefulWidget {
  const ItemDonationRequestItemForm({
    super.key,
  });

  @override
  State<ItemDonationRequestItemForm> createState() =>
      _ItemDonationRequestItemFormState();
}

class _ItemDonationRequestItemFormState
    extends State<ItemDonationRequestItemForm> {
  ItemCategory? selectedItemCategory;
  String description = '';
  String qty = '';

  String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Item Category",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 2,
          ),
          ItemTypeDropdown(
            onSelected: (value) {
              print(value);
              setState(() {
                selectedItemCategory = value;
              });
            },
          ),
          SizedBox(
            height: 18,
          ),
          Text(
            "Item Description",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 2,
          ),
          SizedBox(
            // width: 320,
            height: 45,
            child: TextFormField(
              onChanged: (value) {
                description = value;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.withAlpha(40)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.withAlpha(100)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 30, 136, 229),
                  ),
                ),
                hintText: "eg. Rice bags,First aid kits",
                hintStyle: TextStyle(color: Colors.grey.withAlpha(120)),
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 2,
          ),
          SizedBox(
            // width: 320,
            height: 45,
            child: TextFormField(
              onChanged: (value) => qty = value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.withAlpha(40)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.withAlpha(100)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 30, 136, 229),
                  ),
                ),
                hintText: "Number or Quantity of items",
                hintStyle: TextStyle(color: Colors.grey.withAlpha(120)),
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Colors.red),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 30, 136, 229),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  error == null;
                });
                if (selectedItemCategory == null ||
                    description.isEmpty ||
                    qty.isEmpty) {
                  setState(() {
                    error = '*Please fill all the fields';
                  });
                  return;
                }
                addedItems.add(
                  ItemRequestItem(
                    category: selectedItemCategory!,
                    description: description,
                    quantity: qty,
                  ),
                );
                Navigator.of(context).maybePop();
              },
              child: Text(
                'ADD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
