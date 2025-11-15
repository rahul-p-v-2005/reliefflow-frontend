import 'dart:collection';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/added_items.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/item_donation_request_item_form.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/item_type_dropdown.dart';

enum DonationRequestType { Cash, Items }

class RequestDonation extends StatefulWidget {
  const RequestDonation({super.key});

  @override
  State<RequestDonation> createState() => _RequestDonationState();
}

// const List<Widget> donationRequestType = <Widget>[
//   Text('Cash'),
//   Text('Essential Items'),
// ];

class _RequestDonationState extends State<RequestDonation> {
  DonationRequestType _selectedDonationRequestType = DonationRequestType.Cash;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Request Donation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            ToggleButtons(
              direction: Axis.horizontal,
              onPressed: (int index) {
                print('index $index');
                setState(() {
                  _selectedDonationRequestType =
                      DonationRequestType.values[index];
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.blue[700],
              selectedColor: Colors.white,
              fillColor: Colors.blue[200],
              color: Colors.blue[400],
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 160.0,
              ),
              isSelected: DonationRequestType.values.map(
                (e) {
                  return e == _selectedDonationRequestType;
                },
              ).toList(),
              children: DonationRequestType.values.map(
                (e) {
                  return Text(
                    e.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ).toList(),
            ),
            _selectedDonationRequestType == DonationRequestType.Cash
                ? _CashBody()
                : _ItemsBody(),
          ],
        ),
      ),
    );
  }
}

class _ItemsBody extends StatelessWidget {
  const _ItemsBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 48,
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(16),
                    child: ItemDonationRequestItemForm(),
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.black.withAlpha(200),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    "+",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          ListenableBuilder(
            listenable: addedItems,
            builder: (context, child) {
              print(addedItems.items);
              return Text('Number of items = ${addedItems.items.length}');
            },
          ),
          SizedBox(
            height: 50,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[200],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
              ),
              child: Text(
                "Submit Request",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CashBody extends StatelessWidget {
  const _CashBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
          ),
          Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 2,
          ),
          SizedBox(
            // width: 320,
            height: 48,
            child: TextFormField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                hintText: "₹ 0.00",
                hintStyle: TextStyle(color: Colors.grey.withAlpha(120)),
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Text(
            "Short description",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 2,
          ),
          SizedBox(
            // width: 320,
            child: TextField(
              minLines: 3,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Explain breifly why you need assistance",
                hintStyle: TextStyle(color: Colors.grey.withAlpha(120)),
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
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Text(
            "Upload a photo",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 2,
          ),
          InkWell(
            onTap: () {},
            child: Container(
              // width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withAlpha(100), width: 1),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    Icons.image,
                    color: Colors.grey.withAlpha(100),
                  ),
                  Text(
                    "Upload a photo",
                    style: TextStyle(color: Colors.grey.withAlpha(100)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 56,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[200],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
              ),
              child: Text(
                "Submit Request",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
