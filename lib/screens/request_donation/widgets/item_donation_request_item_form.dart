import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/added_items.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/item_type_dropdown.dart';

class ItemDonationRequestItemForm extends StatelessWidget {
  const ItemDonationRequestItemForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Item Category",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2,
        ),
        ItemTypeDropdown(),
        SizedBox(
          height: 16,
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
                borderSide: BorderSide(color: Colors.blue),
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
                borderSide: BorderSide(color: Colors.blue),
              ),
              hintText: "Number or Quantity of items",
              hintStyle: TextStyle(color: Colors.grey.withAlpha(120)),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            addedItems.add(
              ItemRequestItem(
                category: 'fdf',
                description: 'fd',
                quantity: 'ffd',
              ),
            );
            Navigator.of(context).maybePop();
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
