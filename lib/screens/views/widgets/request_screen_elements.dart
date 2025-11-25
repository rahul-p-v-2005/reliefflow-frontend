import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/screens/views/aid_request_screen.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({
    super.key,
  });

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextField(
        decoration: InputDecoration(
          fillColor: Colors.grey.withAlpha(20),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withAlpha(40),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withAlpha(100),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 30, 136, 229),
            ),
          ),
          hintText: "Search by ID or type",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey,
          ),
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}

class StatusButton extends StatefulWidget {
  final String label;
  const StatusButton({required this.label});

  @override
  State<StatusButton> createState() => _StatusButtonState();
}

class _StatusButtonState extends State<StatusButton> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.label),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(24),
      ),
      selected: isSelected,
      selectedColor: Colors.blue, // Color when selected
      backgroundColor: Colors.grey[300], // Default color
      checkmarkColor: Colors.white, // Tick Color
      onSelected: (value) {
        setState(() {
          isSelected = value;
        });
      },
    );
  }
}
