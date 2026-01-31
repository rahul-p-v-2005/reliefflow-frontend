import 'package:flutter/material.dart';

const _kThemeColor = Color(0xFF1E88E5);

/// A horizontal list of status filter chips for filtering requests.
class StatusFilterChips extends StatelessWidget {
  final List<String> statusFilters;
  final String currentSelectedStatus;
  final ValueChanged<String> onStatusSelected;

  const StatusFilterChips({
    super.key,
    required this.statusFilters,
    required this.currentSelectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statusFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = statusFilters[index];
          final isSelected = currentSelectedStatus == label;
          return GestureDetector(
            onTap: () => onStatusSelected(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _kThemeColor : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? _kThemeColor : Colors.grey[300]!,
                ),
              ),
              child: Text(
                _formatLabel(label),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatLabel(String label) {
    if (label == 'All') return 'All';
    return label[0].toUpperCase() + label.substring(1).replaceAll('_', ' ');
  }
}
