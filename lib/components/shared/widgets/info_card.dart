import 'package:flutter/material.dart';
import 'timeline_widgets.dart' show kThemeColor;

/// A card widget for displaying label-value pairs in a styled container.
class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? borderColor;
  final Color? backgroundColor;

  const InfoCard({
    super.key,
    required this.label,
    required this.value,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? kThemeColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        color: backgroundColor ?? color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
