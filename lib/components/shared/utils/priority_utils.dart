import 'package:flutter/material.dart';

/// Utility class for priority-related helper functions.
///
/// Backend Priority Values: low, medium, high
class PriorityUtils {
  PriorityUtils._();

  /// Returns the color associated with a priority level.
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Returns the icon associated with a priority level.
  static IconData getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.help_outline;
    }
  }

  /// Returns a human-readable display text for a priority.
  static String getPriorityDisplayText(String priority) {
    if (priority.isEmpty) return 'Unknown';
    return '${priority[0].toUpperCase()}${priority.substring(1)} Priority';
  }
}
