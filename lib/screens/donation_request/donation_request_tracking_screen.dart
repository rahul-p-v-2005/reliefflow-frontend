import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';
import 'package:reliefflow_frontend_public_app/components/shared/shared.dart';

const _kThemeColorCash = Color(0xFF43A047);
const _kThemeColorItem = Color(0xFF1E88E5);

/// A screen that displays the tracking timeline for a donation request.
class DonationRequestTrackingScreen extends StatelessWidget {
  final DonationRequest request;
  final bool isCash;

  const DonationRequestTrackingScreen({
    super.key,
    required this.request,
    required this.isCash,
  });

  Color get _themeColor => isCash ? _kThemeColorCash : _kThemeColorItem;

  @override
  Widget build(BuildContext context) {
    final currentStep = StatusUtils.getDonationStatusStep(request.status);
    final isRejected = request.status.toLowerCase() == 'rejected';

    return Scaffold(
      backgroundColor: const Color(0xFFECF6FF),
      appBar: AppBar(
        title: const Text('Track Request'),
        backgroundColor: const Color(0xFFECF6FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Request Details Card
            _buildDetailsCard(),

            // Fulfillment Progress Card (for partially fulfilled requests)
            if (request.status.toLowerCase() == 'partially_fulfilled' ||
                request.status.toLowerCase() == 'in_progress')
              _buildFulfillmentProgressCard(),

            // Photo Evidence Card (if available)
            if (request.proofImages != null && request.proofImages!.isNotEmpty)
              _buildPhotoCard(context),

            // Description Card (if available)
            if (request.description != null && request.description!.isNotEmpty)
              _buildDescriptionCard(),

            // Items Details Card (for item donations)
            if (!isCash &&
                request.itemDetails != null &&
                request.itemDetails!.isNotEmpty)
              _buildItemsCard(),

            // Status Timeline
            _buildTimelineCard(currentStep, isRejected),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _themeColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    isCash ? Icons.currency_rupee : Icons.inventory_2_outlined,
                    color: _themeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title ??
                            (isCash ? 'Cash Donation' : 'Item Donation'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'ID: ${request.id}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            DetailRow('Type', isCash ? 'Cash Donation' : 'Item Donation'),
            DetailRow(
              isCash ? 'Amount' : 'Items',
              isCash
                  ? '₹${request.amount?.toStringAsFixed(0) ?? "0"}'
                  : '${request.itemDetails?.length ?? 0} items',
            ),
            // Show fulfillment summary inline
            if (isCash &&
                request.fulfilledAmount != null &&
                request.fulfilledAmount! > 0)
              DetailRow(
                'Fulfilled',
                '₹${request.fulfilledAmount!.toStringAsFixed(0)} of ₹${request.amount?.toStringAsFixed(0) ?? "0"} (${request.fulfillmentPercentage.toStringAsFixed(0)}%)',
              ),
            if (!isCash && _hasAnyItemFulfillment())
              DetailRow(
                'Fulfilled',
                '${_getFullyFulfilledItemCount()} of ${request.itemDetails?.length ?? 0} items complete',
              ),
            DetailRow(
              'Submitted On',
              request.createdAt != null
                  ? DateFormat('MMM dd, yyyy').format(request.createdAt!)
                  : 'N/A',
            ),
            DetailRow(
              'Deadline',
              request.deadline != null
                  ? DateFormat('MMM dd, yyyy').format(request.deadline!)
                  : 'Not specified',
            ),
            DetailRow(
              'Current Status',
              StatusUtils.getStatusDisplayText(request.status),
            ),
            if (request.address != null &&
                request.address?.addressLine1 != null) ...[
              const SizedBox(height: 2),
              DetailRow('Location', request.address!.addressLine1),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 16,
                  color: _themeColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Photo Evidence',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
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
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageView(
                            imageUrl: imageUrl,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        height: 120,
                        width: request.proofImages!.length > 1 ? 160 : 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 32,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: _themeColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              request.description!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: _themeColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Items Requested',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...request.itemDetails!.map((item) => _buildItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(ItemDetail item) {
    final isFullyFulfilled = item.isFullyFulfilled;
    final hasPartialFulfillment = item.fulfilledQty > 0 && !isFullyFulfilled;
    final fulfillmentPercent = item.fulfillmentPercentage;

    // Determine status icon and color
    IconData statusIcon;
    Color statusColor;
    if (isFullyFulfilled) {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    } else if (hasPartialFulfillment) {
      statusIcon = Icons.pending;
      statusColor = Colors.orange;
    } else {
      statusIcon = Icons.radio_button_unchecked;
      statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isFullyFulfilled
            ? Colors.green.withOpacity(0.05)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFullyFulfilled
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  size: 12,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isFullyFulfilled
                      ? Colors.green.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isFullyFulfilled
                        ? Colors.green.withOpacity(0.3)
                        : _themeColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${item.fulfilledQty}/${item.requestedQty} ${item.unit ?? 'pieces'}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isFullyFulfilled ? Colors.green : _themeColor,
                  ),
                ),
              ),
            ],
          ),
          // Progress bar for fulfillment
          if (item.requestedQty > 0) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fulfillmentPercent / 100,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isFullyFulfilled
                      ? Colors.green
                      : hasPartialFulfillment
                      ? Colors.orange
                      : Colors.grey.shade400,
                ),
                minHeight: 4,
              ),
            ),
          ],
          // Remaining info
          if (item.remainingQty > 0) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                '${item.remainingQty} ${item.unit ?? 'pieces'} remaining',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                item.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineCard(int currentStep, bool isRejected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Timeline',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            if (isRejected)
              const TimelineItem(
                step: 1,
                title: 'Rejected',
                subtitle: 'Your request was not approved',
                isCompleted: true,
                isCurrent: true,
                isRejected: true,
              )
            else ...[
              TimelineItem(
                step: 1,
                title: 'Pending',
                subtitle: 'Request submitted and awaiting review',
                isCompleted: currentStep >= 0,
                isCurrent: currentStep == 0,
              ),
              TimelineConnector(isCompleted: currentStep >= 1),
              TimelineItem(
                step: 2,
                title: 'Accepted',
                subtitle: 'Request has been approved',
                isCompleted: currentStep >= 1,
                isCurrent: currentStep == 1,
              ),
              TimelineConnector(isCompleted: currentStep >= 2),
              TimelineItem(
                step: 3,
                title: isCash ? 'Partially Fulfilled' : 'In Progress',
                subtitle: isCash
                    ? _getCashFulfillmentSubtitle()
                    : _getItemFulfillmentSubtitle(),
                isCompleted: currentStep >= 2,
                isCurrent: currentStep == 2,
              ),
              TimelineConnector(isCompleted: currentStep >= 3),
              TimelineItem(
                step: 4,
                title: 'Completed',
                subtitle: 'Request has been fulfilled',
                isCompleted: currentStep >= 3,
                isCurrent: currentStep == 3,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============ Helper Methods for Fulfillment ============

  /// Build fulfillment progress card for partially fulfilled requests
  Widget _buildFulfillmentProgressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 18,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 8),
                const Text(
                  'Fulfillment Progress',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isCash)
              _buildCashProgressContent()
            else
              _buildItemsProgressContent(),
          ],
        ),
      ),
    );
  }

  /// Build cash donation progress content
  Widget _buildCashProgressContent() {
    final fulfilled = request.fulfilledAmount ?? 0;
    final total = request.amount ?? 0;
    final percentage = request.fulfillmentPercentage;
    final remaining = (total - fulfilled).clamp(0, total);

    return Column(
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 100
                  ? Colors.green
                  : percentage >= 50
                  ? Colors.orange
                  : Colors.orange.shade300,
            ),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 10),
        // Amount details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${fulfilled.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _themeColor,
                  ),
                ),
                Text(
                  'of ₹${total.toStringAsFixed(0)} received',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: percentage >= 100
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 100 ? Colors.green : Colors.orange[700],
                ),
              ),
            ),
          ],
        ),
        if (remaining > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.orange[700]),
                const SizedBox(width: 6),
                Text(
                  '₹${remaining.toStringAsFixed(0)} still needed',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build items donation progress content
  Widget _buildItemsProgressContent() {
    final totalItems = request.itemDetails?.length ?? 0;
    final fulfilledCount = _getFullyFulfilledItemCount();
    final percentage = totalItems > 0
        ? (fulfilledCount / totalItems * 100)
        : 0.0;

    return Column(
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 100
                  ? Colors.green
                  : percentage >= 50
                  ? Colors.orange
                  : Colors.orange.shade300,
            ),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 10),
        // Items count details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$fulfilledCount of $totalItems',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _themeColor,
                  ),
                ),
                Text(
                  'items fully received',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: percentage >= 100
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 100 ? Colors.green : Colors.orange[700],
                ),
              ),
            ),
          ],
        ),
        // Partial items info
        if (_hasPartiallyFulfilledItems()) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pending, size: 14, color: Colors.blue[700]),
                const SizedBox(width: 6),
                Text(
                  '${_getPartiallyFulfilledItemCount()} items partially received',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Check if any item has fulfillment
  bool _hasAnyItemFulfillment() {
    if (request.itemDetails == null) return false;
    return request.itemDetails!.any((item) => item.fulfilledQty > 0);
  }

  /// Get count of fully fulfilled items
  int _getFullyFulfilledItemCount() {
    if (request.itemDetails == null) return 0;
    return request.itemDetails!.where((item) => item.isFullyFulfilled).length;
  }

  /// Check if there are any partially fulfilled items
  bool _hasPartiallyFulfilledItems() {
    if (request.itemDetails == null) return false;
    return request.itemDetails!.any(
      (item) => item.fulfilledQty > 0 && !item.isFullyFulfilled,
    );
  }

  /// Get count of partially fulfilled items
  int _getPartiallyFulfilledItemCount() {
    if (request.itemDetails == null) return 0;
    return request.itemDetails!
        .where((item) => item.fulfilledQty > 0 && !item.isFullyFulfilled)
        .length;
  }

  /// Get subtitle for cash fulfillment in timeline
  String _getCashFulfillmentSubtitle() {
    final fulfilled = request.fulfilledAmount ?? 0;
    final total = request.amount ?? 0;
    if (fulfilled > 0 && total > 0) {
      return '₹${fulfilled.toStringAsFixed(0)} of ₹${total.toStringAsFixed(0)} collected (${request.fulfillmentPercentage.toStringAsFixed(0)}%)';
    }
    return 'Donations are being collected';
  }

  /// Get subtitle for items fulfillment in timeline
  String _getItemFulfillmentSubtitle() {
    if (!_hasAnyItemFulfillment()) {
      return 'Items are being prepared';
    }
    final fulfilledCount = _getFullyFulfilledItemCount();
    final totalCount = request.itemDetails?.length ?? 0;
    return '$fulfilledCount of $totalCount items received';
  }
}
