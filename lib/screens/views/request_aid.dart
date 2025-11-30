import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/components/layout/header.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/select_location.dart';

class RequestAidScreen extends StatefulWidget {
  const RequestAidScreen({super.key});
  @override
  State<RequestAidScreen> createState() => _RequestAidState();
}

class _RequestAidState extends State<RequestAidScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Aid'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SizedBox(
              //   height: 8,
              // ),
              Center(
                child: SizedBox(
                  height: 100,
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 30, 136, 229),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 38,
                        ),
                        Text(
                          "Add Photo",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // SizedBox(
              //   height: 54,
              // ),
              DropdownMenuExample(),
              // SizedBox(
              //   height: 24,
              // ),
              TextField(
                minLines: 4,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Describe your request",
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
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SelectLocationScreen();
                      },
                    ),
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
                      Icon(
                        Icons.location_on_outlined,
                        color: Color.fromARGB(255, 30, 136, 229),
                      ),
                      Text(
                        "Select location...",
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.grey.withAlpha(220),
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.map_outlined,
                        color: Color.fromARGB(255, 30, 136, 229),
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(
              //   height: 48,
              // ),
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
        ),
      ),
    );
  }
}

class DropdownMenuExample extends StatefulWidget {
  const DropdownMenuExample({super.key});

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

const List<String> list = <String>[
  'Flood',
  'Earthquake',
  'Landslide',
];

typedef MenuEntry = DropdownMenuEntry<String>;

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
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
      hintText: 'select calamity type',
      onSelected: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      dropdownMenuEntries: menuEntries,
      width: 300,
    );
  }
}
