import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/request_status.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/request_screen_elements.dart';

class AidsScreen extends StatefulWidget {
  const AidsScreen({super.key});

  @override
  State<AidsScreen> createState() => _AidsScreenState();
}

class _AidsScreenState extends State<AidsScreen> {
  /// NEW: Add "all" option
  String currentSelectedStatus = "All"; // "all" or AidRequestStatus.name

  /// Build a combined list: ["all", pending, approved, rejected ...]
  List<String> get statusFilters => [
    "All",
    ...RequestStatus.values.map((e) => e.name), //... spread operator
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: const Text(
          "Requests",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 8,
          children: [
            const SearchBox(),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: statusFilters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 4),
                itemBuilder: (context, index) {
                  final label = statusFilters[index];
                  return StatusButton(
                    label: label,
                    isSelected: currentSelectedStatus == label,
                    onSelected: (isSelected) {
                      if (isSelected) {
                        setState(() {
                          currentSelectedStatus = label;
                        });
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
