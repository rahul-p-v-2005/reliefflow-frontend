import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/request_status.dart';
import 'package:reliefflow_frontend_public_app/screens/views/aid_request_details.dart';

class RequestDetails extends StatefulWidget {
  final IconData? icon;
  final String label;
  final String id;
  final RequestStatus status;
  final DateTime time;

  const RequestDetails({
    super.key,
    this.icon,
    required this.label,
    required this.id,
    required this.status,
    required this.time,
  });

  @override
  State<RequestDetails> createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity(horizontal: 0, vertical: -1),
      leading: widget.icon != null ? Icon(widget.icon) : null,
      title: Text(
        widget.label,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        "Request ID: $Widget.id",
        style: TextStyle(color: Colors.grey, fontSize: 13),
      ),
      trailing: SizedBox(
        width: 74,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatusWidget(
              status: widget.status,
            ),
            Text(
              DateFormat('yyyy-MM-dd').format(widget.time),
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      onTap: () {
        showModalBottomSheet(
          context: (context),
          builder: (context) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              padding: EdgeInsets.all(24),
              child: AidRequestDetails(),
            );
          },
        );
      },
    );
  }
}

class _StatusWidget extends StatelessWidget {
  const _StatusWidget({
    required this.status,
  });

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        // spacing: 4,
        children: [
          Icon(
            status.displayIcon,
            color: Colors.white,
            size: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),

            child: Text(
              status.displayName,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
