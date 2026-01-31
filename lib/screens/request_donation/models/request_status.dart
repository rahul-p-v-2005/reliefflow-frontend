import 'package:flutter/material.dart';

/// Status values matching backend models:
/// - AidRequest: pending, accepted, in_progress, completed, rejected
/// - DonationRequest: pending, accepted, in_progress, partially_fulfilled, completed, rejected
enum RequestStatus {
  pending,
  accepted,
  inProgress, // For tasks that have been assigned but not completed
  completed,
  rejected,
  partiallyFulfilled; // For donation requests with partial fulfillment

  /// Parse status from backend API response string
  static RequestStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'accepted':
      case 'approved': // Handle legacy/alternate naming
        return RequestStatus.accepted;
      case 'in_progress':
      case 'assigned': // Task assigned = in progress
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'rejected':
        return RequestStatus.rejected;
      case 'partially_fulfilled':
        return RequestStatus.partiallyFulfilled;
      default:
        return RequestStatus.pending; // Default to pending for unknown
    }
  }

  Color get color {
    switch (this) {
      case RequestStatus.pending:
        return Colors.amber;
      case RequestStatus.accepted:
        return Colors.blue;
      case RequestStatus.inProgress:
        return Colors.orange;
      case RequestStatus.completed:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.partiallyFulfilled:
        return Colors.teal;
    }
  }

  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return "Pending";
      case RequestStatus.accepted:
        return "Accepted";
      case RequestStatus.inProgress:
        return "In Progress";
      case RequestStatus.completed:
        return "Completed";
      case RequestStatus.rejected:
        return "Rejected";
      case RequestStatus.partiallyFulfilled:
        return "Partial";
    }
  }

  IconData get displayIcon {
    switch (this) {
      case RequestStatus.pending:
        return Icons.access_time;
      case RequestStatus.accepted:
        return Icons.check_circle_outline_rounded;
      case RequestStatus.inProgress:
        return Icons.sync;
      case RequestStatus.completed:
        return Icons.task_alt_rounded;
      case RequestStatus.rejected:
        return Icons.cancel_outlined;
      case RequestStatus.partiallyFulfilled:
        return Icons.pie_chart_outline_rounded;
    }
  }
}
