import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';

class RequestListScreen extends StatelessWidget {
  const RequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RequestsListCubit()..loadRequests(),
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
            return _buildError(state.message);
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
                  // Aid Requests Section (placeholder for now)
                  _AidRequestsSection(),
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

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
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
  const _AidRequestsSection();

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
                    Icon(Icons.emergency, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Aid Requests",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
          // Placeholder
          Container(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 36, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No aid requests yet',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
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

    return Container(
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
                      _StatusBadge(status: request.status, color: statusColor),
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
                          DateFormat('MMM dd, yyyy').format(request.createdAt!),
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
