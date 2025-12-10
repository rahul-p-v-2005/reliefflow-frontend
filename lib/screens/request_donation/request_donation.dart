import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/feature.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/properties.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/added_items.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/item_donation_request_item_form.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/select_location.dart';

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
        child: ListView(
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
              selectedBorderColor: Color.fromARGB(255, 2, 75, 139),
              selectedColor: Colors.white,
              fillColor: Color.fromARGB(255, 30, 136, 229),
              color: Color.fromARGB(255, 30, 136, 229),
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 145,
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

class _ItemsBody extends StatefulWidget {
  const _ItemsBody();

  @override
  State<_ItemsBody> createState() => _ItemsBodyState();
}

class _ItemsBodyState extends State<_ItemsBody> {
  Feature? _selectedLocation;

  Future<void> _selectLocation() async {
    final result = await Navigator.push<Feature>(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectLocationScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });

      // Now you have the selected location with coordinates
      final coords = result.geometry?.coordinates;
      final props = result.properties;

      print('Selected Location:');
      print('Name: ${props?.name}');
      print('Address: ${_formatAddress(props)}');
      print('Coordinates: ${coords?[1]}, ${coords?[0]}'); // lat, lon

      // You can now save this location to your backend
      // or use it in your donation request
    }
  }

  String _formatAddress(Properties? props) {
    if (props == null) return '';

    final parts = <String>[];

    if (props.locality != null && props.locality!.isNotEmpty) {
      parts.add(props.locality!);
    }

    if (props.city != null && props.city!.isNotEmpty) {
      parts.add(props.city!);
    }

    final district = props.district ?? props.county;
    if (district != null && district.isNotEmpty) {
      parts.add(district);
    }

    if (props.state != null && props.state!.isNotEmpty) {
      parts.add(props.state!);
    }

    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        spacing: 18,
        children: [
          SizedBox(
            height: 48,
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: ItemDonationRequestItemForm(),
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withAlpha(100),
                  width: 0.9,
                ),
              ),
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    "Select item type...",
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.grey.withAlpha(220),
                    ),
                  ),
                  Spacer(),
                  Text(
                    "+",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.grey.withAlpha(220),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListenableBuilder(
            listenable: addedItems,
            builder: (context, child) {
              print(addedItems.items);
              // return Text('Number of items = ${addedItems.items.length}');
              return ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final item = addedItems.items[index];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12),
                      side: BorderSide(color: Colors.grey),
                    ),
                    leading: Icon(
                      item.category.icon,
                      color: Color.fromARGB(255, 30, 136, 229),
                    ),
                    title: Text(item.category.categoryName),
                    subtitle: Text(item.description),
                    trailing: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 30, 136, 229),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            item.quantity,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 8,
                  );
                },
                itemCount: addedItems.items.length,
              );
            },
          ),
          SizedBox(
            height: 50,
          ),
          // InkWell(
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) {
          //           return SelectLocationScreen();
          //         },
          //       ),
          //     );
          //   },
          //   child: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(8),
          //       border: Border.all(
          //         color: Colors.grey.withAlpha(100),
          //         width: 0.9,
          //       ),
          //     ),
          //     padding: EdgeInsets.all(12),
          //     child: Row(
          //       children: [
          //         Icon(
          //           Icons.location_on_outlined,
          //           color: Color.fromARGB(255, 30, 136, 229),
          //         ),
          //         Text(
          //           "Select location...",
          //           style: TextStyle(
          //             // fontWeight: FontWeight.bold,
          //             fontSize: 17,
          //             color: Colors.grey.withAlpha(220),
          //           ),
          //         ),
          //         Spacer(),
          //         Icon(
          //           Icons.map_outlined,
          //           color: Color.fromARGB(255, 30, 136, 229),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // Location selector
          InkWell(
            onTap: _selectLocation,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: _selectedLocation != null
                        ? Colors.blue
                        : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedLocation?.properties?.name ??
                              'Select location',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: _selectedLocation != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                        if (_selectedLocation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatAddress(_selectedLocation!.properties),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Display coordinates (for debugging/verification)
          if (_selectedLocation != null) ...[
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Coordinates:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${_selectedLocation!.geometry?.coordinates?[1].toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Lon: ${_selectedLocation!.geometry?.coordinates?[0].toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 30, 136, 229),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
              ),
              child: Text(
                "SUBMIT REQUEST",
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
  const _CashBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 15,
          ),
          Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 2,
          ),
          SizedBox(
            // width: 320,
            height: 45,
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
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 30, 136, 229),
                  ),
                ),
                hintText: "₹ 0.00",
                hintStyle: TextStyle(color: Colors.grey.withAlpha(120)),
              ),
            ),
          ),
          SizedBox(
            height: 15,
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
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 30, 136, 229),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15,
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
                border: Border.all(
                  color: Colors.grey.withAlpha(100),
                  width: 1,
                ),
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
            height: 15,
          ),
          Text(
            "Bank Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 2,
          ),
          SizedBox(
            height: 45,
            // width: 320,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Enter the UPI number",
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
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 30, 136, 229),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 18,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 30, 136, 229),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
              ),
              child: Text(
                "SUBMIT REQUEST",
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
