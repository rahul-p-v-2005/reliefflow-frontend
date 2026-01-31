import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/components/shared/utils/status_utils.dart';

/// A reusable badge widget that displays a status with color and icon.
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.color,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = color ?? StatusUtils.getStatusColor(status);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            StatusUtils.getStatusIcon(status),
            color: Colors.white,
            size: fontSize + 2,
          ),
          const SizedBox(width: 2),
          Text(
            StatusUtils.getStatusDisplayText(status),
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A larger status badge variant with bigger icon and text.
class StatusBadgeLarge extends StatelessWidget {
  final String status;
  final Color? color;

  const StatusBadgeLarge({
    super.key,
    required this.status,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = color ?? StatusUtils.getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            StatusUtils.getStatusIcon(status),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            StatusUtils.getStatusDisplayText(status),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
