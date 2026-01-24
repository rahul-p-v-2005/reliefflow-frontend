import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';
import 'package:reliefflow_frontend_public_app/models/requests/aid_request.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';
import 'package:reliefflow_frontend_public_app/env.dart';

class RequestListScreen extends StatelessWidget {
  const RequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RequestsListCubit()..loadRequests(),
      child: const _RequestListScreenBody(),
    );
  }
}

class _RequestListScreenBody extends StatefulWidget {
  const _RequestListScreenBody();

  @override
  State<_RequestListScreenBody> createState() => _RequestListScreenBodyState();
}

class _RequestListScreenBodyState extends State<_RequestListScreenBody> {
  String currentSelectedStatus = "All";

  List<String> get statusFilters => [
    "All",
    "pending",
    "accepted",
    "completed",
    "rejected",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 241, 241),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 241, 241),
        elevation: 0,
        title: const Text(
          "My Requests",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<RequestsListCubit>().refresh(),
            icon: Icon(Icons.refresh, color: Colors.grey[700]),
          ),
        ],
      ),
      body: BlocBuilder<RequestsListCubit, RequestsListState>(
        builder: (context, state) {
          if (state is RequestsListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RequestsListError) {
            return _buildError(state.message, statusCode: state.statusCode);
          }
          if (state is RequestsListLoaded) {
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<RequestsListCubit>().loadRequests(),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                children: [
                  // Status Filters
                  _buildFilters(),
                  const SizedBox(height: 12),
                  // Aid Requests Section
                  _AidRequestsSection(requests: state.aidRequests),
                  const SizedBox(height: 12),
                  // Donation Requests Section
                  _DonationRequestsSection(
                    requests: state.donationRequests,
                    filter: currentSelectedStatus,
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statusFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = statusFilters[index];
          final isSelected = currentSelectedStatus == label;
          return GestureDetector(
            onTap: () {
              setState(() => currentSelectedStatus = label);
              context.read<RequestsListCubit>().filterByStatus(label);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1E88E5)
                      : Colors.grey[300]!,
                ),
              ),
              child: Text(
                label == 'All'
                    ? 'All'
                    : label[0].toUpperCase() + label.substring(1),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String message, {int statusCode = 0}) {
    // For 401 errors, show session expired message (redirect handled by MainNavigation)
    final isSessionExpired = statusCode == 401;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSessionExpired ? Icons.lock_outline : Icons.error_outline,
            size: 48,
            color: isSessionExpired ? Colors.orange : Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: isSessionExpired ? Colors.orange : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (isSessionExpired) ...[
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 8),
            Text(
              'Redirecting to login...',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ] else
            ElevatedButton(
              onPressed: () => context.read<RequestsListCubit>().loadRequests(),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

// ==================== AID REQUESTS SECTION ====================
class _AidRequestsSection extends StatelessWidget {
  final List<AidRequest> requests;

  const _AidRequestsSection({required this.requests});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF1E88E5);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emergency, color: themeColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Aid Requests",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${requests.length}',
                        style: const TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "Emergency assistance requests",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Separator
          Container(
            width: double.infinity,
            height: 2,
            color: const Color.fromARGB(255, 243, 241, 241),
          ),
          // Content
          if (requests.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 36,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No aid requests yet',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                children: requests.map((request) {
                  final statusColor = _getStatusColor(request.status);
                  return InkWell(
                    onTap: () => _showAidRequestDetails(context, request),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(
                          left: BorderSide(color: themeColor, width: 4),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.emergency_rounded,
                                color: themeColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          request.calamityTypeName ??
                                              'Aid Request',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getStatusIcon(request.status),
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              request.status[0].toUpperCase() +
                                                  request.status
                                                      .substring(1)
                                                      .replaceAll('_', ' '),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ID: ${request.id.length > 8 ? '${request.id.substring(0, 8)}...' : request.id}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 6,
                                              width: 6,
                                              decoration: const BoxDecoration(
                                                color: Colors.black45,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                request.address.isNotEmpty
                                                    ? request.address
                                                    : 'No location',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (request.createdAt != null)
                                        Text(
                                          DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(request.createdAt!),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: Colors.black45,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showAidRequestDetails(BuildContext context, AidRequest request) {
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
          child: _AidRequestBottomSheet(request: request),
        );
      },
    );
  }
}

class _AidRequestBottomSheet extends StatelessWidget {
  final AidRequest request;

  const _AidRequestBottomSheet({required this.request});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getImageUrl(String url) {
    if (url.startsWith('http') || url.startsWith('https')) {
      return url;
    }

    // kBaseUrl includes '/api' but uploads are at root '/uploads'
    // We need to use the origin (scheme://host:port)
    final uri = Uri.parse(kBaseUrl);
    final origin = '${uri.scheme}://${uri.host}:${uri.port}';

    // Handle specific relative paths if needed, otherwise assume it's relative to base
    if (url.startsWith('/')) {
      return '$origin$url';
    }
    return '$origin/$url';
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(request.status);
    const themeColor = Color(0xFF1E88E5);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
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
                      color: themeColor.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: themeColor,
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
          ),
          const SizedBox(height: 12),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(request.status),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  request.status[0].toUpperCase() +
                      request.status.substring(1).replaceAll('_', ' '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Image Section (if available)
          if (request.imageUrl != null && request.imageUrl!.isNotEmpty) ...[
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
              onTap: () => _showFullScreenImage(
                context,
                _getImageUrl(request.imageUrl!),
              ),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeColor.withOpacity(0.2),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _getImageUrl(request.imageUrl!),
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
                              color: themeColor,
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
            const SizedBox(height: 16),
          ],

          // Description Section
          if (request.description != null &&
              request.description!.isNotEmpty) ...[
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
            const SizedBox(height: 20),
          ],

          // Location & Date Info Cards Row
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Location',
                  value: request.address.isNotEmpty
                      ? request.address
                      : 'Not specified',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  label: 'Requested Date',
                  value: request.createdAt != null
                      ? DateFormat('MMM dd, yyyy').format(request.createdAt!)
                      : 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Calamity Type Info Card
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Calamity Type',
                  value: request.calamityTypeName ?? 'Aid Request',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Track Request Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        AidRequestTrackingScreen(request: request),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
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
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(imageUrl: imageUrl),
      ),
    );
  }
}

// Full Screen Image View for Aid Requests
class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Photo Evidence',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==================== AID REQUEST TRACKING SCREEN ====================
class AidRequestTrackingScreen extends StatelessWidget {
  final AidRequest request;

  const AidRequestTrackingScreen({super.key, required this.request});

  int _getStatusStep(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'in_progress':
        return 2;
      case 'completed':
        return 3;
      case 'rejected':
        return -1;
      default:
        return 0;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getImageUrl(String url) {
    if (url.startsWith('http') || url.startsWith('https')) {
      return url;
    }

    // kBaseUrl includes '/api' but uploads are at root '/uploads'
    final uri = Uri.parse(kBaseUrl);
    final origin = '${uri.scheme}://${uri.host}:${uri.port}';

    if (url.startsWith('/')) {
      return '$origin$url';
    }
    return '$origin/$url';
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF1E88E5);
    final currentStep = _getStatusStep(request.status);
    final isRejected = request.status.toLowerCase() == 'rejected';
    final priorityColor = _getPriorityColor(request.priority);

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
            Padding(
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
                            color: themeColor.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.emergency_rounded,
                            color: themeColor,
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
                    _DetailRow('Type', 'Aid Request'),
                    _DetailRow(
                      'Priority',
                      '${request.priority[0].toUpperCase()}${request.priority.substring(1)}',
                    ),
                    _DetailRow(
                      'Submitted On',
                      request.createdAt != null
                          ? DateFormat(
                              'MMM dd, yyyy',
                            ).format(request.createdAt!)
                          : 'N/A',
                    ),
                    if (request.description != null &&
                        request.description!.isNotEmpty)
                      _DetailRow('Description', request.description!),
                    _DetailRow('Current Status', request.status.toUpperCase()),
                    if (request.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _DetailRow('Location', request.address),
                    ],
                  ],
                ),
              ),
            ),

            // Photo Evidence Card (if available)
            if (request.imageUrl != null && request.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      const Row(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 18,
                            color: themeColor,
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
                              builder: (context) => _FullScreenImageView(
                                imageUrl: _getImageUrl(request.imageUrl!),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _getImageUrl(request.imageUrl!),
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
              ),

            // Status Timeline
            Padding(
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
                      _TimelineItem(
                        step: 1,
                        title: 'Rejected',
                        subtitle: 'Your request was not approved',
                        isCompleted: true,
                        isCurrent: true,
                        isRejected: true,
                      )
                    else ...[
                      _TimelineItem(
                        step: 1,
                        title: 'Pending',
                        subtitle: 'Request submitted and awaiting review',
                        isCompleted: currentStep >= 0,
                        isCurrent: currentStep == 0,
                      ),
                      _TimelineConnector(isCompleted: currentStep >= 1),
                      _TimelineItem(
                        step: 2,
                        title: 'Accepted',
                        subtitle: 'Request has been approved',
                        isCompleted: currentStep >= 1,
                        isCurrent: currentStep == 1,
                      ),
                      _TimelineConnector(isCompleted: currentStep >= 2),
                      _TimelineItem(
                        step: 3,
                        title: 'In Progress',
                        subtitle: 'Aid is being arranged',
                        isCompleted: currentStep >= 2,
                        isCurrent: currentStep == 2,
                      ),
                      _TimelineConnector(isCompleted: currentStep >= 3),
                      _TimelineItem(
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
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== DONATION REQUESTS SECTION ====================
class _DonationRequestsSection extends StatelessWidget {
  final List<DonationRequest> requests;
  final String filter;

  const _DonationRequestsSection({
    required this.requests,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    // Separate cash and items
    final cashRequests = requests
        .where((r) => r.donationType == 'cash')
        .toList();
    final itemRequests = requests
        .where((r) => r.donationType == 'item')
        .toList();

    return Column(
      children: [
        // Cash Donations
        _RequestListCard(
          icon: Icons.currency_rupee,
          iconColor: const Color(0xFF43A047),
          title: 'Cash Donation Requests',
          subtitle: 'Financial assistance requests',
          requests: cashRequests,
          isCash: true,
        ),
        const SizedBox(height: 12),
        // Item Donations
        _RequestListCard(
          icon: Icons.inventory_2,
          iconColor: const Color(0xFF1E88E5),
          title: 'Item Donation Requests',
          subtitle: 'Material & supplies requests',
          requests: itemRequests,
          isCash: false,
        ),
      ],
    );
  }
}

class _RequestListCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<DonationRequest> requests;
  final bool isCash;

  const _RequestListCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.requests,
    required this.isCash,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${requests.length}',
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Separator
          Container(
            width: double.infinity,
            height: 2,
            color: const Color.fromARGB(255, 243, 241, 241),
          ),
          // List Items
          if (requests.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 36,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No ${isCash ? "cash" : "item"} requests',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                children: requests
                    .map((r) => _RequestItem(request: r, isCash: isCash))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _RequestItem extends StatelessWidget {
  final DonationRequest request;
  final bool isCash;

  const _RequestItem({required this.request, required this.isCash});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(request.status);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: DonationRequestBottomSheet(
                request: request,
                isCash: isCash,
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: isCash ? const Color(0xFF43A047) : const Color(0xFF1E88E5),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Icon(
                  isCash ? Icons.currency_rupee : Icons.inventory_2_outlined,
                  color: isCash
                      ? const Color(0xFF43A047)
                      : const Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(width: 10),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            request.title ??
                                (isCash ? 'Cash Request' : 'Item Request'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusBadge(
                          status: request.status,
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${request.id.substring(0, 8)}...',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Amount or items count
                        Row(
                          children: [
                            Container(
                              height: 6,
                              width: 6,
                              decoration: const BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCash
                                  ? '₹${request.amount?.toStringAsFixed(0) ?? "0"}'
                                  : '${request.itemDetails?.length ?? 0} items',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Date
                        if (request.createdAt != null)
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(request.createdAt!),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'partially_fulfilled':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), color: Colors.white, size: 12),
          const SizedBox(width: 2),
          Text(
            status[0].toUpperCase() + status.substring(1).replaceAll('_', ' '),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

// ==================== DONATION REQUEST BOTTOM SHEET ====================
class DonationRequestBottomSheet extends StatelessWidget {
  final DonationRequest request;
  final bool isCash;

  const DonationRequestBottomSheet({
    super.key,
    required this.request,
    required this.isCash,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'partially_fulfilled':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _getImageUrl(String url) {
    if (url.startsWith('http') || url.startsWith('https')) {
      return url;
    }

    final uri = Uri.parse(kBaseUrl);
    final origin = '${uri.scheme}://${uri.host}:${uri.port}';

    if (url.startsWith('/')) {
      return '$origin$url';
    }
    return '$origin/$url';
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(request.status);
    final themeColor = isCash
        ? const Color(0xFF43A047)
        : const Color(0xFF1E88E5);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
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
                      color: themeColor.withOpacity(0.1),
                    ),
                    child: Icon(
                      isCash
                          ? Icons.currency_rupee
                          : Icons.inventory_2_outlined,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title ??
                            (isCash ? 'Cash Donation' : 'Item Donation'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'ID: ${request.id.substring(0, 12)}...',
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
          ),
          const SizedBox(height: 12),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(request.status),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  request.status[0].toUpperCase() +
                      request.status.substring(1).replaceAll('_', ' '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Photo Evidence Section
          if (request.proofImages != null &&
              request.proofImages!.isNotEmpty) ...[
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
                  final imageUrl = _getImageUrl(request.proofImages![index]);
                  return GestureDetector(
                    onTap: () => _showFullScreenImage(context, imageUrl),
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
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
                                value:
                                    loadingProgress.expectedTotalBytes != null
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

          // Description (if available)
          if (request.description != null &&
              request.description!.isNotEmpty) ...[
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

          // Amount Section (for Cash) or Items Section (for Items)
          if (isCash) ...[
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
                    color: themeColor,
                  ),
                ),
                if (request.fulfilledAmount != null &&
                    request.fulfilledAmount! > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
          ] else ...[
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
              ...request.itemDetails!.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: themeColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: themeColor,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Qty: ${item.quantity}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
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
                ),
              )
            else
              const Text(
                'No items specified',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
          ],
          const SizedBox(height: 20),

          // Location Row (Full Width)
          if (!isCash || (request.address?.addressLine1 != null)) ...[
            SizedBox(
              width: double.infinity,
              child: _InfoCard(
                label: 'Location',
                value: request.address?.addressLine1 ?? 'Not specified',
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Dates Row
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Requested Date',
                  value: request.createdAt != null
                      ? DateFormat('MMM dd, yyyy').format(request.createdAt!)
                      : 'Not specified',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  label: 'Deadline',
                  value: request.deadline != null
                      ? DateFormat('MMM dd, yyyy').format(request.deadline!)
                      : 'Not specified',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Track Request Button
          SizedBox(
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
                backgroundColor: const Color(0xFF1E88E5),
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
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF1E88E5).withOpacity(0.3),
        ),
        color: const Color(0xFF1E88E5).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ==================== DONATION REQUEST TRACKING SCREEN ====================
class DonationRequestTrackingScreen extends StatelessWidget {
  final DonationRequest request;
  final bool isCash;

  const DonationRequestTrackingScreen({
    super.key,
    required this.request,
    required this.isCash,
  });

  int _getStatusStep(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'partially_fulfilled':
        return 2;
      case 'completed':
        return 3;
      case 'rejected':
        return -1; // Special case
      default:
        return 0;
    }
  }

  String _getImageUrl(String url) {
    if (url.startsWith('http') || url.startsWith('https')) {
      return url;
    }

    final uri = Uri.parse(kBaseUrl);
    final origin = '${uri.scheme}://${uri.host}:${uri.port}';

    if (url.startsWith('/')) {
      return '$origin$url';
    }
    return '$origin/$url';
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = isCash
        ? const Color(0xFF43A047)
        : const Color(0xFF1E88E5);
    final currentStep = _getStatusStep(request.status);
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
            Padding(
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
                            color: themeColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            isCash
                                ? Icons.currency_rupee
                                : Icons.inventory_2_outlined,
                            color: themeColor,
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
                                    (isCash
                                        ? 'Cash Donation'
                                        : 'Item Donation'),
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
                    _DetailRow(
                      'Type',
                      isCash ? 'Cash Donation' : 'Item Donation',
                    ),
                    _DetailRow(
                      isCash ? 'Amount' : 'Items',
                      isCash
                          ? '₹${request.amount?.toStringAsFixed(0) ?? "0"}'
                          : '${request.itemDetails?.length ?? 0} items',
                    ),
                    _DetailRow(
                      'Submitted On',
                      request.createdAt != null
                          ? DateFormat(
                              'MMM dd, yyyy',
                            ).format(request.createdAt!)
                          : 'N/A',
                    ),
                    _DetailRow(
                      'Deadline',
                      request.deadline != null
                          ? DateFormat('MMM dd, yyyy').format(request.deadline!)
                          : 'Not specified',
                    ),
                    _DetailRow('Current Status', request.status.toUpperCase()),
                    if (request.address != null &&
                        request.address?.addressLine1 != null) ...[
                      const SizedBox(height: 2),
                      _DetailRow('Location', request.address!.addressLine1),
                    ],
                  ],
                ),
              ),
            ),

            // Photo Evidence Card (if available)
            if (request.proofImages != null && request.proofImages!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
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
                            color: themeColor,
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
                        height: 120, // Reduced from 200
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: request.proofImages!.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final imageUrl = _getImageUrl(
                              request.proofImages![index],
                            );
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => _FullScreenImageView(
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
                                  width: request.proofImages!.length > 1
                                      ? 160
                                      : 200,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
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
              ),

            // Description Card (if available)
            if (request.description != null && request.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
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
                            color: themeColor,
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
              ),

            // Items Details Card (for item donations)
            if (!isCash &&
                request.itemDetails != null &&
                request.itemDetails!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
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
                            color: themeColor,
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
                      // Compact list of items
                      ...request.itemDetails!.map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
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
                                      color: themeColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      size: 12,
                                      color: themeColor,
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: themeColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      'Qty: ${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: themeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.description != null &&
                                  item.description!.isNotEmpty) ...[
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Status Timeline
            Padding(
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
                      _TimelineItem(
                        step: 1,
                        title: 'Rejected',
                        subtitle: 'Your request was not approved',
                        isCompleted: true,
                        isCurrent: true,
                        isRejected: true,
                      )
                    else ...[
                      _TimelineItem(
                        step: 1,
                        title: 'Pending',
                        subtitle: 'Request submitted and awaiting review',
                        isCompleted: currentStep >= 0,
                        isCurrent: currentStep == 0,
                      ),
                      _TimelineConnector(isCompleted: currentStep >= 1),
                      _TimelineItem(
                        step: 2,
                        title: 'Accepted',
                        subtitle: 'Request has been approved',
                        isCompleted: currentStep >= 1,
                        isCurrent: currentStep == 1,
                      ),
                      _TimelineConnector(isCompleted: currentStep >= 2),
                      _TimelineItem(
                        step: 3,
                        title: 'In Progress',
                        subtitle: isCash
                            ? 'Donations are being collected'
                            : 'Items are being prepared',
                        isCompleted: currentStep >= 2,
                        isCurrent: currentStep == 2,
                      ),
                      _TimelineConnector(isCompleted: currentStep >= 3),
                      _TimelineItem(
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
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2), // Reduced from 4
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isRejected;

  const _TimelineItem({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
    this.isRejected = false,
  });

  @override
  Widget build(BuildContext context) {
    Color circleColor;
    Widget circleChild;

    if (isRejected) {
      circleColor = Colors.red;
      circleChild = const Icon(Icons.close, color: Colors.white, size: 18);
    } else if (isCompleted && !isCurrent) {
      circleColor = Colors.green;
      circleChild = const Icon(Icons.check, color: Colors.white, size: 18);
    } else if (isCurrent) {
      circleColor = const Color(0xFF1E88E5);
      circleChild = Text(
        '$step',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      circleColor = Colors.grey[300]!;
      circleChild = Text(
        '$step',
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
          ),
          child: Center(child: circleChild),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isCurrent
                      ? (isRejected ? Colors.red : const Color(0xFF1E88E5))
                      : (isCompleted ? Colors.grey[700] : Colors.grey),
                ),
              ),
              if (isCurrent)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  final bool isCompleted;

  const _TimelineConnector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Container(
        width: 3,
        height: 35,
        color: isCompleted ? const Color(0xFF1E88E5) : Colors.grey[300],
      ),
    );
  }
}
