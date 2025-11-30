import 'package:flutter/material.dart';

enum AidRequestStatus {
  pending,
  approved,
  inProgress,
  completed,
  rejected;

  Color get color {
    switch (this) {
      case AidRequestStatus.pending:
        return Colors.orange;
      case AidRequestStatus.approved:
        return Colors.green;
      case AidRequestStatus.inProgress:
        return Colors.blue;
      case AidRequestStatus.completed:
        return Colors.grey;
      case AidRequestStatus.rejected:
        return Colors.red;
    }
  }

  String get displayName {
    switch (this) {
      case AidRequestStatus.pending:
        return "Pending";
      case AidRequestStatus.approved:
        return "Approved";
      case AidRequestStatus.inProgress:
        return "In Progress";
      case AidRequestStatus.completed:
        return "Completed";
      case AidRequestStatus.rejected:
        return "Rejected";
    }
  }

  IconData get displayIcon {
    switch (this) {
      case AidRequestStatus.pending:
        return Icons.access_time;
      case AidRequestStatus.approved:
        return Icons.check_circle_outline_rounded;
      case AidRequestStatus.inProgress:
        return Icons.error_outline;

      case AidRequestStatus.completed:
        return Icons.check_circle_outline_rounded;
      case AidRequestStatus.rejected:
        return Icons.cancel_outlined;
    }
  }
}
