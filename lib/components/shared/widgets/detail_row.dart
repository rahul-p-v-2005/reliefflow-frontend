import 'package:flutter/material.dart';

/// A row widget for displaying label-value pairs in a simple format.
/// Commonly used in detail views and tracking screens.
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final double verticalPadding;

  const DetailRow(
    this.label,
    this.value, {
    super.key,
    this.verticalPadding = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
