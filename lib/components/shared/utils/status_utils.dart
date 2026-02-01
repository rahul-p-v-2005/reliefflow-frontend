import 'package:flutter/material.dart';

/// Utility class for status-related helper functions.
/// Centralized to avoid duplication across screens.
///
/// Backend Status Values:
/// - Aid Request: pending, accepted, rejected, completed, in_progress
/// - Donation Request: pending, accepted, rejected, completed, partially_fulfilled, in_progress
class StatusUtils {
  StatusUtils._();

  /// Returns the color associated with a status.
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.teal;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'partially_fulfilled':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  /// Returns the icon associated with a status.
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'in_progress':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'partially_fulfilled':
        return Icons.pie_chart_outline;
      default:
        return Icons.info_outline;
    }
  }

  /// Returns a human-readable display text for a status.
  static String getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted by admin';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected by admin';
      case 'partially_fulfilled':
        return 'Partially Fulfilled';
      default:
        return status.isNotEmpty
            ? status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ')
            : 'Unknown';
    }
  }

  /// Returns the step number for timeline tracking.
  /// Returns -1 for rejected status (special case).
  static int getStatusStep(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'in_progress':
        return 2;
      case 'partially_fulfilled':
        return 2; // Same step as in_progress for donation requests
      case 'completed':
        return 3;
      case 'rejected':
        return -1;
      default:
        return 0;
    }
  }

  /// Returns the step number specifically for donation requests.
  static int getDonationStatusStep(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'partially_fulfilled':
        return 2;
      case 'completed':
        return 3;
      case 'rejected':
        return -1;
      default:
        return 0;
    }
  }
}
