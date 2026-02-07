import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/select_current_location.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/feature.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/properties.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item_category.dart';
import 'package:reliefflow_frontend_public_app/components/shared/utils/image_utils.dart';

class EditDonationRequestScreen extends StatefulWidget {
  final DonationRequest request;
  final VoidCallback? onUpdated;

  const EditDonationRequestScreen({
    super.key,
    required this.request,
    this.onUpdated,
  });

  @override
  State<EditDonationRequestScreen> createState() => _EditDonationRequestState();
}

class _EditDonationRequestState extends State<EditDonationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _upiController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSubmitting = false;
  String _priority = 'medium';
  Feature? _selectedLocationFeature;
  DateTime? _deadline;
  List<String> _proofImages = [];

  // For item-type donations
  List<EditableItem> _items = [];
  int? _expandedItemIndex;

  // Category list with icons
  final List<ItemCategory> _categories = [
    ItemCategory(categoryName: 'Food', icon: Icons.restaurant),
    ItemCategory(
      categoryName: 'Medical Supplies',
      icon: Icons.medical_services_rounded,
    ),
    ItemCategory(categoryName: 'Clothes', icon: Icons.checkroom),
    ItemCategory(categoryName: 'Blankets', icon: Icons.bed),
    ItemCategory(categoryName: 'Other', icon: Icons.grid_view_sharp),
  ];

  final List<String> _units = [
    'pieces',
    'kg',
    'liters',
    'boxes',
    'packets',
    'sets',
  ];

  bool get isCash => widget.request.donationType == 'cash';
  Color get _themeColor =>
      isCash ? const Color(0xFF43A047) : const Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing data
    _titleController.text = widget.request.title ?? '';
    _descriptionController.text = widget.request.description ?? '';
    _amountController.text = widget.request.amount?.toString() ?? '';
    _upiController.text = widget.request.upiNumber ?? '';
    _priority = widget.request.priority;
    _deadline = widget.request.deadline;
    _proofImages = widget.request.proofImages ?? [];

    // Debug: Log proof images
    print('Edit screen - Proof images count: ${_proofImages.length}');
    if (_proofImages.isNotEmpty) {
      print('Edit screen - Proof images: $_proofImages');
    }

    // Initialize items for item-type donations
    if (!isCash && widget.request.itemDetails != null) {
      _items = widget.request.itemDetails!
          .map(
            (item) => EditableItem(
              id: item.id,
              category: item.category,
              description: item.description ?? '',
              quantity: item.quantity,
              unit: item.unit ?? 'pieces',
            ),
          )
          .toList();
    }

    // Build address string from address object
    final addr = widget.request.address;
    if (addr != null) {
      final parts = <String>[];
      if (addr.addressLine1.isNotEmpty) parts.add(addr.addressLine1);
      if (addr.addressLine2 != null && addr.addressLine2!.isNotEmpty) {
        parts.add(addr.addressLine2!);
      }
      if (addr.addressLine3 != null && addr.addressLine3!.isNotEmpty) {
        parts.add(addr.addressLine3!);
      }
      if (addr.pinCode > 0) parts.add(addr.pinCode.toString());
      _addressController.text = parts.join(', ');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _upiController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate items for item-type donations
    if (!isCash && _items.isEmpty) {
      _showSnackBar('Please add at least one item', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null) {
        _showSnackBar('Please login again', isError: true);
        setState(() => _isSubmitting = false);
        return;
      }

      // Build the update body
      final body = <String, dynamic>{
        'title': _titleController.text,
        'description': _descriptionController.text,
        'priority': _priority,
        'donationType': widget.request.donationType,
        if (_deadline != null) 'deadline': _deadline!.toIso8601String(),
      };

      if (isCash) {
        body['amount'] = double.tryParse(_amountController.text) ?? 0;
        body['upiNumber'] = _upiController.text;
      } else {
        // Add items for item-type donations
        body['itemDetails'] = _items
            .map(
              (item) => {
                'category': item.category,
                'description': item.description,
                'quantity': item.quantity,
                'unit': item.unit,
              },
            )
            .toList();
      }

      // Build address if provided
      if (_addressController.text.isNotEmpty) {
        final addressParts = _addressController.text.split(',');
        body['address'] = {
          'addressLine1': addressParts.isNotEmpty ? addressParts[0].trim() : '',
          'addressLine2': addressParts.length > 1 ? addressParts[1].trim() : '',
          'addressLine3': addressParts.length > 2 ? addressParts[2].trim() : '',
          'pinCode': addressParts.length > 3
              ? int.tryParse(
                      addressParts[3].replaceAll(RegExp(r'[^0-9]'), ''),
                    ) ??
                    0
              : 0,
        };

        // Add location if available
        if (_selectedLocationFeature != null) {
          final coords = _selectedLocationFeature!.geometry?.coordinates;
          if (coords != null && coords.length >= 2) {
            body['location'] = {
              'type': 'Point',
              'coordinates': [coords[0], coords[1]],
            };
          }
        }
      }

      final response = await http.put(
        Uri.parse(
          '$kBaseUrl/public/donation/update-donation/${widget.request.id}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnackBar('Donation request updated successfully');
        widget.onUpdated?.call();
        Navigator.pop(
          context,
          true,
        ); // Return true to indicate successful update
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(
          data['message'] ?? 'Failed to update request',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Network error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatAddress(Properties? props) {
    if (props == null) return '';
    final parts = <String>[];
    if (props.locality?.isNotEmpty == true) parts.add(props.locality!);
    if (props.city?.isNotEmpty == true) parts.add(props.city!);
    final district = props.district ?? props.county;
    if (district?.isNotEmpty == true) parts.add(district!);
    if (props.state?.isNotEmpty == true) parts.add(props.state!);
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isCash ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD),
              const Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInfoBanner(),
                        const SizedBox(height: 16),
                        _buildTitleField(),
                        const SizedBox(height: 16),
                        _buildDescriptionField(),
                        const SizedBox(height: 16),
                        if (isCash) ...[
                          _buildAmountField(),
                          const SizedBox(height: 16),
                          _buildUpiField(),
                          const SizedBox(height: 16),
                        ] else ...[
                          _buildItemsSection(),
                          const SizedBox(height: 16),
                        ],
                        _buildPriorityDropdown(),
                        const SizedBox(height: 16),
                        _buildDeadlinePicker(),
                        const SizedBox(height: 16),
                        _buildProofImagesSection(),
                        const SizedBox(height: 16),
                        _buildAddressField(),
                        const SizedBox(height: 16),
                        _buildLocationPicker(),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCash
              ? [const Color(0xFF43A047), const Color(0xFF66BB6A)]
              : [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit ${isCash ? 'Cash' : 'Item'} Request',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Update your donation request',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            isCash ? Icons.currency_rupee : Icons.inventory_2_outlined,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You can edit this request until an admin reviews it.',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.title, color: _themeColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter a title for your request',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                borderSide: BorderSide(color: _themeColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: _themeColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe why you need assistance...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                borderSide: BorderSide(color: _themeColor),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.currency_rupee, color: _themeColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Amount Needed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '0.00',
              prefixIcon: Icon(Icons.currency_rupee, color: _themeColor),
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                borderSide: BorderSide(color: _themeColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpiField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: _themeColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'UPI ID',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _upiController,
            decoration: InputDecoration(
              hintText: 'yourname@upi',
              prefixIcon: Icon(
                Icons.account_balance_wallet_outlined,
                color: _themeColor,
              ),
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                borderSide: BorderSide(color: _themeColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your UPI ID';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: _themeColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Priority',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _priority,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _themeColor, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'low',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Low Priority'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'medium',
                child: Row(
                  children: [
                    Icon(Icons.remove, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Medium Priority'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'high',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('High Priority'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _priority = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: _themeColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Address (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Enter your address',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                borderSide: BorderSide(color: _themeColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          FocusScope.of(context).unfocus();
          final result = await Navigator.of(context).push<Feature>(
            MaterialPageRoute(
              builder: (context) => const SelectCurrentLocationScreen(),
            ),
          );
          if (result != null) {
            setState(() {
              _selectedLocationFeature = result;
              if (_addressController.text.isEmpty &&
                  result.properties?.name != null) {
                _addressController.text = result.properties!.name!;
              }
            });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _selectedLocationFeature != null
                      ? Colors.red.withOpacity(0.1)
                      : _themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on,
                  color: _selectedLocationFeature != null
                      ? Colors.red
                      : _themeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedLocationFeature?.properties?.name ??
                          'Select Location on Map',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                    if (_selectedLocationFeature != null)
                      Text(
                        _formatAddress(_selectedLocationFeature!.properties),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Tap to choose your exact location',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCash
              ? [const Color(0xFF43A047), const Color(0xFF66BB6A)]
              : [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'UPDATE REQUEST',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, color: _themeColor, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Items Needed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _addNewItem,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: _themeColor),
                      const SizedBox(width: 4),
                      Text(
                        'Add Item',
                        style: TextStyle(
                          color: _themeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No items added yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Add Item" to add items you need',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _buildItemCard(_items[index], index),
            ),
        ],
      ),
    );
  }

  void _addNewItem() {
    setState(() {
      _items.add(
        EditableItem(
          category: 'Food',
          description: '',
          quantity: '1',
          unit: 'pieces',
        ),
      );
      _expandedItemIndex = _items.length - 1;
    });
  }

  Widget _buildItemCard(EditableItem item, int index) {
    final isExpanded = _expandedItemIndex == index;
    final categoryIcon = _getCategoryIcon(item.category);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isExpanded
            ? _themeColor.withOpacity(0.03)
            : _themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? _themeColor.withOpacity(0.5)
              : _themeColor.withOpacity(0.2),
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Collapsed header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                _expandedItemIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(categoryIcon, color: _themeColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.quantity} ${item.unit}${item.description.isNotEmpty ? " • ${item.description}" : ""}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: _themeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded edit form
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: _themeColor.withOpacity(0.2)),
                  const SizedBox(height: 8),
                  // Category Dropdown
                  _buildLabel('Category'),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value:
                        _categories.any((c) => c.categoryName == item.category)
                        ? item.category
                        : _categories.first.categoryName,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    dropdownColor: Colors.white,
                    decoration: _inputDecoration(),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.categoryName,
                        child: Row(
                          children: [
                            Icon(cat.icon, size: 20, color: _themeColor),
                            const SizedBox(width: 12),
                            Text(
                              cat.categoryName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _items[index] = item.copyWith(category: value);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Description field
                  _buildLabel('Description (Optional)'),
                  const SizedBox(height: 4),
                  TextFormField(
                    initialValue: item.description,
                    decoration: _inputDecoration(
                      hint: 'e.g., Rice, blankets, etc.',
                    ),
                    onChanged: (value) {
                      _items[index] = item.copyWith(description: value);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Quantity and Unit row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Quantity'),
                            const SizedBox(height: 4),
                            TextFormField(
                              initialValue: item.quantity,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(hint: '10'),
                              onChanged: (value) {
                                _items[index] = item.copyWith(quantity: value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Unit'),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: _units.contains(item.unit)
                                  ? item.unit
                                  : _units.first,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                              dropdownColor: Colors.white,
                              decoration: _inputDecoration(),
                              items: _units
                                  .map(
                                    (u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(u),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _items[index] = item.copyWith(unit: value);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _removeItem(index),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Remove'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (item.quantity.isEmpty ||
                                item.category.isEmpty) {
                              _showSnackBar(
                                'Please fill all required fields',
                                isError: true,
                              );
                              return;
                            }
                            setState(() {
                              _expandedItemIndex = null;
                            });
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Done'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _themeColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
        borderSide: BorderSide(color: _themeColor, width: 1.5),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    for (final cat in _categories) {
      if (cat.categoryName.toLowerCase() == category.toLowerCase()) {
        return cat.icon;
      }
    }
    return Icons.inventory_2;
  }

  void _removeItem(int index) {
    if (_items.length == 1) {
      _showSnackBar('At least one item is required', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Remove Item', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${_items[index].category}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _items.removeAt(index);
                _expandedItemIndex = null;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlinePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate:
                _deadline ?? DateTime.now().add(const Duration(days: 7)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: _themeColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() => _deadline = picked);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _deadline != null
                      ? const Color(0xFF7B1FA2).withOpacity(0.1)
                      : _themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: _deadline != null
                      ? const Color(0xFF7B1FA2)
                      : _themeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deadline (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      _deadline != null
                          ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                          : 'Tap to select a deadline',
                      style: TextStyle(
                        color: _deadline != null
                            ? Colors.grey[700]
                            : Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_deadline != null)
                GestureDetector(
                  onTap: () {
                    setState(() => _deadline = null);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
                ),
              if (_deadline == null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProofImagesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: _themeColor, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Proof Images (Optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Images uploaded during request creation',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          if (_proofImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _proofImages.map((url) {
                // Build full URL using ImageUtils
                final imageUrl = ImageUtils.getImageUrl(url);

                return GestureDetector(
                  onTap: () {
                    // Show full screen image
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.black,
                        child: Stack(
                          children: [
                            Center(
                              child: InteractiveViewer(
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              color: Colors.grey[400],
                                              size: 48,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Failed to load image',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _themeColor.withOpacity(0.3)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $imageUrl');
                              print('Error details: $error');
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      color: Colors.grey[400],
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Error',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _themeColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Tap to view indicator
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No proof images uploaded',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Model for editable item in the form
class EditableItem {
  final String? id;
  final String category;
  final String description;
  final String quantity;
  final String unit;

  EditableItem({
    this.id,
    required this.category,
    required this.description,
    required this.quantity,
    required this.unit,
  });

  EditableItem copyWith({
    String? id,
    String? category,
    String? description,
    String? quantity,
    String? unit,
  }) {
    return EditableItem(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}
