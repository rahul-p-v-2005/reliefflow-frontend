import 'package:flutter/material.dart';

enum RequestStatus {
  Pending,
  Approved,
  InProgress,
  Completed,
  Rejected;

  Color get color {
    switch (this) {
      case RequestStatus.Pending:
        return Colors.amber;
      case RequestStatus.Approved:
        return Colors.green;
      case RequestStatus.InProgress:
        return Colors.orange;
      case RequestStatus.Completed:
        return Colors.blue;
      case RequestStatus.Rejected:
        return Colors.red;
    }
  }

  String get displayName {
    switch (this) {
      case RequestStatus.Pending:
        return "Pending";
      case RequestStatus.Approved:
        return "Approved";
      case RequestStatus.InProgress:
        return "In Progress";
      case RequestStatus.Completed:
        return "Completed";
      case RequestStatus.Rejected:
        return "Rejected";
    }
  }

  IconData get displayIcon {
    switch (this) {
      case RequestStatus.Pending:
        return Icons.access_time;
      case RequestStatus.Approved:
        return Icons.check_circle_outline_rounded;
      case RequestStatus.InProgress:
        return Icons.error_outline;
      case RequestStatus.Completed:
        return Icons.task_alt_rounded;
      case RequestStatus.Rejected:
        return Icons.cancel_outlined;
    }
  }
}
