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
          children: [_RequestDetails(), _RequestStatusTimeLine()],
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

class _RequestStatusTimeLine extends StatelessWidget {
  const _RequestStatusTimeLine({super.key});

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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                spacing: 10,
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Pending",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 13,
                  ),
                  Container(
                    width: 2.2,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 30, 136, 229),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Approved",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 13,
                  ),
                  Container(
                    width: 2.2,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 30, 136, 229),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 30, 136, 229),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3.0,
                      ),
                      child: Text(
                        "3",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "In Progress",
                        style: TextStyle(
                          color: Color.fromARGB(255, 30, 136, 229),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        "Aid is being prepared or delivered.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 13,
                  ),
                  Container(
                    width: 2.2,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 30, 136, 229),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9.0,
                        vertical: 2.5,
                      ),
                      child: Text(
                        "4",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Completed",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
