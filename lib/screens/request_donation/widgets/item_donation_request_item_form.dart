import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/added_items.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item_category.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/item_type_dropdown.dart';

class ItemDonationRequestItemForm extends StatefulWidget {
  const ItemDonationRequestItemForm({super.key});

  @override
  State<ItemDonationRequestItemForm> createState() =>
      _ItemDonationRequestItemFormState();
}

class _ItemDonationRequestItemFormState
    extends State<ItemDonationRequestItemForm> {
  ItemCategory? selectedItemCategory;
  String description = '';
  String qty = '';
  String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color(0xFF43A047).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add_box,
                        color: Color(0xFF43A047),
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Add Item",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Category Dropdown
            _buildLabel("Item Category"),
            SizedBox(height: 4),
            ItemTypeDropdown(
              onSelected: (value) {
                setState(() => selectedItemCategory = value);
              },
            ),
            SizedBox(height: 12),

            // Description
            _buildLabel("Description"),
            SizedBox(height: 4),
            _buildTextField(
              hint: "e.g., Rice bags, First aid kits",
              onChanged: (v) => description = v,
            ),
            SizedBox(height: 12),

            // Quantity
            _buildLabel("Quantity"),
            SizedBox(height: 4),
            _buildTextField(
              hint: "Number of items",
              keyboardType: TextInputType.number,
              onChanged: (v) => qty = v,
            ),
            SizedBox(height: 16),

            // Error
            if (error != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  error!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() => error = null);
                  if (selectedItemCategory == null ||
                      description.isEmpty ||
                      qty.isEmpty) {
                    setState(() => error = 'Please fill all fields');
                    return;
                  }
                  addedItems.add(
                    ItemRequestItem(
                      category: selectedItemCategory!,
                      description: description,
                      quantity: qty,
                    ),
                  );
                  Navigator.of(context).maybePop();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'ADD ITEM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
        fontSize: 12,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF1E88E5), width: 1.5),
        ),
      ),
    );
  }
}
