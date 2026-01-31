import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/components/shared/utils/priority_utils.dart';

/// A badge widget that displays priority level with appropriate color.
class PriorityBadge extends StatelessWidget {
  final String priority;
  final bool showBorder;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = PriorityUtils.getPriorityColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: showBorder
            ? Border.all(color: priorityColor.withOpacity(0.5))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, color: priorityColor, size: 14),
          const SizedBox(width: 4),
          Text(
            PriorityUtils.getPriorityDisplayText(priority),
            style: TextStyle(
              fontSize: 12,
              color: priorityColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
