import 'package:flutter/material.dart';

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
    // return SizedBox(
    //   height: 32,
    //   child: TextField(
    //     decoration: InputDecoration(
    //       fillColor: const Color.fromARGB(
    //         255,
    //         241,
    //         241,
    //         241,
    //       ),
    //       filled: true,
    //       border: OutlineInputBorder(
    //         borderRadius: BorderRadius.circular(8),
    //         borderSide: BorderSide(
    //           color: Colors.grey.withAlpha(40),
    //         ),
    //       ),
    //       enabledBorder: OutlineInputBorder(
    //         borderRadius: BorderRadius.circular(8),
    //         borderSide: BorderSide(
    //           color: Colors.grey.withAlpha(100),
    //         ),
    //       ),
    //       focusedBorder: OutlineInputBorder(
    //         borderRadius: BorderRadius.circular(8),
    //         borderSide: BorderSide(
    //           color: Color.fromARGB(255, 30, 136, 229),
    //         ),
    //       ),
    //       hintText: "Search by ID or type",
    //       hintStyle: TextStyle(
    //         color: Colors.grey,
    //         fontSize: 14,
    //       ),
    //       prefixIcon: Icon(
    //         Icons.search,
    //         color: Colors.grey,
    //       ),
    //       alignLabelWithHint: true,
    //     ),
    //   ),
    // );
    return SizedBox(
      // width: 320,
      height: 45,
      child: TextFormField(
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withAlpha(100),
            ),
          ),
          hintText: "Search by ID or type",
          hintStyle: TextStyle(
            color: Colors.grey.withAlpha(120),
            fontWeight: FontWeight.bold,
            fontSize: 15.5,
          ),
          prefixIcon: Icon(Icons.search_rounded),
          prefixIconColor: Color.fromARGB(255, 30, 136, 229),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: SizedBox(
            width: 16,
            height: 16,
            child: Center(
              child: IconButton(
                onPressed: () {},
                // style: IconButton.styleFrom(
                //   padding: EdgeInsets.zero,
                //   visualDensity: VisualDensity.compact,
                //   fixedSize: Size(16, 16),
                //    backgroundColor: Colors.grey,
                // ),
                icon: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatusButton extends StatefulWidget {
  final String label;
  final bool isSelected;

  final void Function(bool)? onSelected;
  const StatusButton({
    super.key,
    required this.label,
    required this.isSelected,
    this.onSelected,
  });

  @override
  State<StatusButton> createState() => _StatusButtonState();
}

class _StatusButtonState extends State<StatusButton> {
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        widget.label,
        style: TextStyle(
          color: widget.isSelected ? Colors.white : Colors.black,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(24),
      ),
      showCheckmark: false,
      selected: widget.isSelected,
      selectedColor: Colors.blue, // Color when selected
      backgroundColor: Colors.white,

      checkmarkColor: Colors.white, // Tick Color
      onSelected: widget.onSelected,
    );
  }
}
