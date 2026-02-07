import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/models/requests/aid_request.dart';
import 'package:reliefflow_frontend_public_app/components/shared/shared.dart';
import 'package:reliefflow_frontend_public_app/screens/aid_request/aid_request_tracking_screen.dart';

const _kThemeColor = Color(0xFF1E88E5);

/// A bottom sheet that displays detailed information about an aid request.
/// Use [AidRequestBottomSheet.show] to display this bottom sheet.
class AidRequestBottomSheet extends StatelessWidget {
  final AidRequest request;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AidRequestBottomSheet({
    super.key,
    required this.request,
    this.onEdit,
    this.onDelete,
  });

  /// Shows the aid request bottom sheet.
  static void show(
    BuildContext context,
    AidRequest request, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
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
          child: AidRequestBottomSheet(
            request: request,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusUtils.getStatusColor(request.status);
    final priorityColor = PriorityUtils.getPriorityColor(request.priority);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          _buildHeader(context),
          const SizedBox(height: 12),

          // Status & Priority badges
          _buildBadges(statusColor, priorityColor),
          const SizedBox(height: 20),

          // Description
          if (request.description != null &&
              request.description!.isNotEmpty) ...[
            _buildDescription(),
            const SizedBox(height: 20),
          ],

          // Image Section (if available)
          if (request.imageUrl != null && request.imageUrl!.isNotEmpty) ...[
            _buildImageSection(context),
            const SizedBox(height: 20),
          ],

          // Location
          _buildAddressSection(),
          const SizedBox(height: 20),

          // Date & Type row
          _buildInfoRow(),
          const SizedBox(height: 24),

          // Track button
          _buildTrackButton(context),

          // Edit/Delete buttons (only visible when request can be edited/deleted)
          if (request.canEdit || request.canDelete) ...[
            const SizedBox(height: 12),
            _buildActionButtons(context),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (request.canEdit && onEdit != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onEdit!();
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kThemeColor,
                side: const BorderSide(color: _kThemeColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if (request.canEdit &&
            request.canDelete &&
            onEdit != null &&
            onDelete != null)
          const SizedBox(width: 12),
        if (request.canDelete && onDelete != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirmation(context),
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text(
          'Are you sure you want to delete this aid request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              onDelete!();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
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
                color: _kThemeColor.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.emergency_rounded,
                color: _kThemeColor,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.calamityTypeName ?? 'Aid Request',
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

  Widget _buildBadges(Color statusColor, Color priorityColor) {
    return Row(
      children: [
        StatusBadgeLarge(status: request.status, color: statusColor),
        const SizedBox(width: 8),
        // Show "Editable" badge when request can be edited
        if (request.canEdit)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 12, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'Editable',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        // Show "Under Review" badge when admin has viewed but still pending
        if (!request.canEdit && request.status == 'pending' && request.isRead)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.visibility, size: 12, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Under Review',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            request.description!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final imageUrl = ImageUtils.getImageUrl(request.imageUrl!);

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
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FullScreenImageView(imageUrl: imageUrl),
            ),
          ),
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kThemeColor.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
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
                          color: _kThemeColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Tap to enlarge',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
                request.address.isNotEmpty ? request.address : 'No address',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        Expanded(
          child: InfoCard(
            label: 'Requested Date',
            value: request.createdAt != null
                ? DateFormat('MMM dd, yyyy').format(request.createdAt!)
                : 'N/A',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InfoCard(
            label: 'Calamity Type',
            value: request.calamityTypeName ?? 'Aid Request',
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
              builder: (context) => AidRequestTrackingScreen(request: request),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _kThemeColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Track Request',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
