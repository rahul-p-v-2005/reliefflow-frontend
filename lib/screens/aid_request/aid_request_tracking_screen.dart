import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/models/requests/aid_request.dart';
import 'package:reliefflow_frontend_public_app/components/shared/shared.dart';

const _kThemeColor = Color(0xFF1E88E5);

/// A screen that displays the tracking timeline for an aid request.
class AidRequestTrackingScreen extends StatelessWidget {
  final AidRequest request;

  const AidRequestTrackingScreen({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final currentStep = StatusUtils.getStatusStep(request.status);
    final isRejected = request.status.toLowerCase() == 'rejected';
    final priorityColor = PriorityUtils.getPriorityColor(request.priority);

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
            _buildDetailsCard(priorityColor),

            // Photo Evidence Card (if available)
            if (request.imageUrl != null && request.imageUrl!.isNotEmpty)
              _buildPhotoCard(context),

            // Status Timeline
            _buildTimelineCard(currentStep, isRejected),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Color priorityColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.calamityTypeName ?? 'Aid Request',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'ID: ${request.id}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            DetailRow('Type', request.calamityTypeName ?? 'Aid Request'),
            // DetailRow(
            //   'Priority',
            //   '${request.priority[0].toUpperCase()}${request.priority.substring(1)}',
            // ),
            DetailRow(
              'Submitted On',
              request.createdAt != null
                  ? DateFormat('MMM dd, yyyy').format(request.createdAt!)
                  : 'N/A',
            ),
            if (request.description != null && request.description!.isNotEmpty)
              DetailRow('Description', request.description!),
            DetailRow(
              'Current Status',
              StatusUtils.getStatusDisplayText(request.status),
            ),
            if (request.address.isNotEmpty) ...[
              const SizedBox(height: 4),
              DetailRow('Location', request.address, maxValueLines: 3),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context) {
    final imageUrl = ImageUtils.getImageUrl(request.imageUrl!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 18,
                  color: _kThemeColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Photo Evidence',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
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
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(int currentStep, bool isRejected) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
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
                title: 'In Progress',
                subtitle: 'Aid is being arranged',
                isCompleted: currentStep >= 2,
                isCurrent: currentStep == 2,
              ),
              TimelineConnector(isCompleted: currentStep >= 3),
              TimelineItem(
                step: 4,
                title: 'Completed',
                subtitle: 'Aid has been delivered',
                isCompleted: currentStep >= 3,
                isCurrent: currentStep == 3,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
