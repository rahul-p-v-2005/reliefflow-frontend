import 'package:flutter/material.dart';

/// A row widget for displaying label-value pairs in a simple format.
/// Commonly used in detail views and tracking screens.
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final double verticalPadding;

  /// Number of lines allowed for the `value` text. Default 1 (keeps existing
  /// ellipsis behaviour). Set >1 to allow wrapping for long values (e.g. address).
  final int maxValueLines;

  const DetailRow(
    this.label,
    this.value, {
    super.key,
    this.verticalPadding = 2,
    this.maxValueLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSingleLine = maxValueLines == 1;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        // align to top so multi-line values line up neatly with the label
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.end,
              softWrap: true,
              maxLines: maxValueLines,
              overflow: isSingleLine
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
