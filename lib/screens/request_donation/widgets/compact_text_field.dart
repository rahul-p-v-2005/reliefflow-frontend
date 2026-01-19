import 'package:flutter/material.dart';

class CompactTextField extends StatelessWidget {
  final String label;
  final String hint;
  final String value;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const CompactTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          initialValue: value,
          maxLines: maxLines,
          keyboardType: keyboardType,
          focusNode: focusNode,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF1E88E5), size: 20)
                : null,
            filled: true,
            fillColor: Colors.grey[50], // Slightly lighter fill
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14, // Matches RequestAid
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1E88E5),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
