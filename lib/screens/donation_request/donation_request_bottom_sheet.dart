import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';
import 'package:reliefflow_frontend_public_app/components/shared/shared.dart';
import 'package:reliefflow_frontend_public_app/screens/donation_request/donation_request_tracking_screen.dart';

const _kThemeColorCash = Color(0xFF43A047);
const _kThemeColorItem = Color(0xFF1E88E5);

/// A bottom sheet that displays detailed information about a donation request.
/// Use [DonationRequestBottomSheet.show] to display this bottom sheet.
class DonationRequestBottomSheet extends StatelessWidget {
  final DonationRequest request;
  final bool isCash;

  const DonationRequestBottomSheet({
    super.key,
    required this.request,
    required this.isCash,
  });

  Color get _themeColor => isCash ? _kThemeColorCash : _kThemeColorItem;

  /// Shows the donation request bottom sheet.
  static void show(BuildContext context, DonationRequest request, bool isCash) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(24),
          child: DonationRequestBottomSheet(request: request, isCash: isCash),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusUtils.getStatusColor(request.status);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          _buildHeader(context),
          const SizedBox(height: 12),

          // Status & Priority badges
          Row(
            children: [
              StatusBadgeLarge(status: request.status, color: statusColor),
              const SizedBox(width: 8),
              PriorityBadge(priority: request.priority),
            ],
          ),
          const SizedBox(height: 16),

          // Photo Evidence Section
          if (request.proofImages != null && request.proofImages!.isNotEmpty)
            _buildPhotoSection(context),

          // Description (if available)
          if (request.description != null && request.description!.isNotEmpty)
            _buildDescription(),

          // Amount Section (for Cash) or Items Section (for Items)
          if (isCash) _buildAmountSection() else _buildItemsSection(),

          const SizedBox(height: 20),

          // Address Section
          _buildAddressSection(),
          const SizedBox(height: 20),

          // Dates Row
          _buildDatesRow(),
          const SizedBox(height: 24),

          // Track Request Button
          _buildTrackButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _themeColor.withOpacity(0.1),
              ),
              child: Icon(
                isCash ? Icons.currency_rupee : Icons.inventory_2_outlined,
                color: _themeColor,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title ?? (isCash ? 'Cash Donation' : 'Item Donation'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'ID: ${request.id.length > 12 ? '${request.id.substring(0, 12)}...' : request.id}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 18, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo Evidence',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: request.proofImages!.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final imageUrl = ImageUtils.getImageUrl(
                request.proofImages![index],
              );
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        FullScreenImageView(imageUrl: imageUrl),
                  ),
                ),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          request.description!,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount Requested',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '₹${request.amount?.toStringAsFixed(0) ?? "0"}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _themeColor,
              ),
            ),
            if (request.fulfilledAmount != null &&
                request.fulfilledAmount! > 0) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹${request.fulfilledAmount!.toStringAsFixed(0)} fulfilled',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (request.upiNumber != null && request.upiNumber!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                'UPI: ${request.upiNumber}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items Requested',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (request.itemDetails != null && request.itemDetails!.isNotEmpty)
          ...request.itemDetails!.map((item) => _buildItemCard(item))
        else
          const Text(
            'No items specified',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
      ],
    );
  }

  Widget _buildItemCard(ItemDetail item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _themeColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.category_outlined,
                size: 16,
                color: _themeColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Qty: ${item.quantity} ${item.unit ?? 'pieces'}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _themeColor,
                  ),
                ),
              ),
            ],
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.description!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getFullAddress() {
    if (request.address == null) return 'No address provided';

    final parts = <String>[];
    if (request.address!.addressLine1.isNotEmpty) {
      parts.add(request.address!.addressLine1);
    }
    if (request.address!.addressLine2 != null &&
        request.address!.addressLine2!.isNotEmpty) {
      parts.add(request.address!.addressLine2!);
    }
    if (request.address!.addressLine3 != null &&
        request.address!.addressLine3!.isNotEmpty) {
      parts.add(request.address!.addressLine3!);
    }
    if (request.address!.pinCode > 0) {
      parts.add('- ${request.address!.pinCode}');
    }

    return parts.isEmpty ? 'No address provided' : parts.join(', ');
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _getFullAddress(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatesRow() {
    return Row(
      children: [
        Expanded(
          child: InfoCard(
            label: 'Requested Date',
            value: request.createdAt != null
                ? DateFormat('MMM dd, yyyy').format(request.createdAt!)
                : 'Not specified',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InfoCard(
            label: 'Deadline',
            value: request.deadline != null
                ? DateFormat('MMM dd, yyyy').format(request.deadline!)
                : 'Not specified',
          ),
        ),
      ],
    );
  }

  Widget _buildTrackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DonationRequestTrackingScreen(
                request: request,
                isCash: isCash,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _themeColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Track Donation Request',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
