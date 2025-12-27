import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/feature.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/properties.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/cubit/items_donation_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/cubit/items_donation_state.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/donation_card.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/compact_text_field.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/item_donation_request_item_form.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/select_location.dart';

class ItemsDonationForm extends StatelessWidget {
  const ItemsDonationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ItemsDonationCubit(),
      child: const _ItemsDonationFormBody(),
    );
  }
}

class _ItemsDonationFormBody extends StatelessWidget {
  const _ItemsDonationFormBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ItemsDonationCubit, ItemsDonationState>(
      listener: (context, state) {
        if (state.status == DonationSubmitStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Request submitted!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state.status == DonationSubmitStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          context.read<ItemsDonationCubit>().clearError();
        }
      },
      builder: (context, state) {
        final cubit = context.read<ItemsDonationCubit>();
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            // Basic Info
            DonationCard(
              icon: Icons.info_outline,
              iconColor: Color(0xFF1E88E5),
              title: 'Basic Information',
              child: Column(
                children: [
                  CompactTextField(
                    label: 'Title',
                    hint: 'e.g., Need supplies for flood relief',
                    value: state.title,
                    onChanged: cubit.updateTitle,
                  ),
                  SizedBox(height: 12),
                  CompactTextField(
                    label: 'Description',
                    hint: 'Explain what items you need and why...',
                    value: state.description,
                    maxLines: 3,
                    onChanged: cubit.updateDescription,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Items
            DonationCard(
              icon: Icons.inventory_2,
              iconColor: Color(0xFF43A047),
              title: 'Items Needed',
              child: Column(
                children: [
                  _ItemsList(items: state.items, onRemove: cubit.removeItem),
                  SizedBox(height: 10),
                  _AddItemButton(onAdd: cubit.addItem),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Location
            DonationCard(
              icon: Icons.location_on,
              iconColor: Color(0xFFE53935),
              title: 'Pickup/Delivery Location',
              child: _LocationPicker(
                location: state.location,
                onSelect: cubit.setLocation,
              ),
            ),
            SizedBox(height: 12),

            // Photos
            DonationCard(
              icon: Icons.camera_alt,
              iconColor: Color(0xFFFF7043),
              title: 'Situation Photos (Optional)',
              child: _ImagePicker(
                images: state.images,
                onPick: cubit.pickImages,
                onRemove: cubit.removeImage,
              ),
            ),
            SizedBox(height: 12),

            // Deadline
            DonationCard(
              icon: Icons.calendar_today,
              iconColor: Color(0xFF7B1FA2),
              title: 'Deadline (Optional)',
              child: _DeadlinePicker(
                deadline: state.deadline,
                onSelect: cubit.setDeadline,
              ),
            ),
            SizedBox(height: 24),

            // Submit
            _SubmitButton(
              isLoading: state.status == DonationSubmitStatus.loading,
              onPressed: cubit.submit,
            ),
            SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _ItemsList extends StatelessWidget {
  final List<ItemRequestItem> items;
  final Function(int) onRemove;

  const _ItemsList({required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 36, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              'No items added',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        return Container(
          margin: EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ListTile(
            dense: true,
            leading: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xFF1E88E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                item.category.icon,
                color: Color(0xFF1E88E5),
                size: 18,
              ),
            ),
            title: Text(
              item.category.categoryName,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: Text(
              item.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'x${item.quantity}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                GestureDetector(
                  onTap: () => onRemove(i),
                  child: Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AddItemButton extends StatelessWidget {
  final Function(ItemRequestItem) onAdd;

  const _AddItemButton({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(12),
            child: ItemDonationRequestItemForm(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF1E88E5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFF1E88E5), size: 18),
            SizedBox(width: 8),
            Text(
              'Add Item',
              style: TextStyle(
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPicker extends StatelessWidget {
  final Feature? location;
  final Function(Feature?) onSelect;

  const _LocationPicker({required this.location, required this.onSelect});

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
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<Feature>(
          context,
          MaterialPageRoute(builder: (_) => const SelectLocationScreen()),
        );
        if (result != null) onSelect(result);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: location != null ? Color(0xFFE53935) : Colors.grey,
              size: 22,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location?.properties?.name ?? 'Select location',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: location != null
                          ? Colors.grey[800]
                          : Colors.grey[500],
                    ),
                  ),
                  if (location != null) ...[
                    SizedBox(height: 2),
                    Text(
                      _formatAddress(location!.properties),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  final List<File> images;
  final VoidCallback onPick;
  final Function(int) onRemove;

  const _ImagePicker({
    required this.images,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (images.isNotEmpty) ...[
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (_, i) => Container(
                margin: EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        images[i],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => onRemove(i),
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
        ],
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: Color(0xFF1E88E5),
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  images.isEmpty ? 'Upload Photos' : 'Add More',
                  style: TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DeadlinePicker extends StatelessWidget {
  final DateTime? deadline;
  final Function(DateTime?) onSelect;

  const _DeadlinePicker({required this.deadline, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (date != null) onSelect(date);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(
              Icons.event,
              color: deadline != null ? Color(0xFF7B1FA2) : Colors.grey,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              deadline != null
                  ? '${deadline!.day}/${deadline!.month}/${deadline!.year}'
                  : 'Select deadline',
              style: TextStyle(
                color: deadline != null ? Colors.grey[800] : Colors.grey[500],
                fontSize: 14,
              ),
            ),
            Spacer(),
            if (deadline != null)
              GestureDetector(
                onTap: () => onSelect(null),
                child: Icon(Icons.close, color: Colors.grey, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send, size: 18),
                SizedBox(width: 8),
                Text(
                  'SUBMIT REQUEST',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
    );
  }
}
