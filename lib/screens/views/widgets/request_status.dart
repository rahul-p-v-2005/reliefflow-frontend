import 'package:flutter/material.dart';

class RequestStatus extends StatefulWidget {
  const RequestStatus({super.key});

  @override
  State<RequestStatus> createState() => _RequestStatusState();
}

class _RequestStatusState extends State<RequestStatus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 246, 255),
      appBar: AppBar(
        title: Text("Track Request"),
      ),
      body: Container(
        child: Column(
          children: [_RequestDetails()],
        ),
      ),
    );
  }
}

class _RequestDetails extends StatelessWidget {
  const _RequestDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Request ID:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Details:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Submitted On:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Current Status:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
