import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/request_screen_elements.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Donation Requests"),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SearchBox(),
              Wrap(
                spacing: 3,
                children: [
                  StatusButton(label: "All"),
                  StatusButton(label: "Pending"),
                  StatusButton(label: "Approved"),
                  StatusButton(label: "In Progress"),
                  StatusButton(label: "Completed"),
                  StatusButton(label: "Rejected"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
