import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';
import 'package:reliefflow_frontend_public_app/screens/donation_request/donation_request_bottom_sheet.dart';
import 'package:reliefflow_frontend_public_app/screens/donation_request/edit_donation_request_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';
import 'package:reliefflow_frontend_public_app/components/shared/shared.dart';

const _kThemeColorCash = Color(0xFF43A047);
const _kThemeColorItem = Color(0xFF1E88E5);

/// Section widget displaying donation requests (cash and item) for the requests list screen.
class DonationRequestsSection extends StatelessWidget {
  final List<DonationRequest> requests;
  final String filter;

  const DonationRequestsSection({
    super.key,
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
        DonationRequestListCard(
          icon: Icons.currency_rupee,
          iconColor: _kThemeColorCash,
          title: 'Cash Donation Requests',
          subtitle: 'Financial assistance requests',
          requests: cashRequests,
          isCash: true,
        ),
        const SizedBox(height: 12),
        // Item Donations
        DonationRequestListCard(
          icon: Icons.inventory_2,
          iconColor: _kThemeColorItem,
          title: 'Item Donation Requests',
          subtitle: 'Material & supplies requests',
          requests: itemRequests,
          isCash: false,
        ),
      ],
    );
  }
}

/// A card widget that displays a list of donation requests.
class DonationRequestListCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<DonationRequest> requests;
  final bool isCash;

  const DonationRequestListCard({
    super.key,
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
          _buildHeader(),
          _buildDivider(),
          if (requests.isEmpty) _buildEmpty() else _buildList(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 2,
      color: const Color.fromARGB(255, 243, 241, 241),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 36, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No ${isCash ? "cash" : "item"} requests',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: requests.map((r) {
          return _DonationRequestListItem(request: r, isCash: isCash);
        }).toList(),
      ),
    );
  }
}

class _DonationRequestListItem extends StatelessWidget {
  final DonationRequest request;
  final bool isCash;

  const _DonationRequestListItem({
    required this.request,
    required this.isCash,
  });

  Color get _themeColor => isCash ? _kThemeColorCash : _kThemeColorItem;

  void _handleEdit(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditDonationRequestScreen(request: request),
      ),
    );

    // Refresh the list if edit was successful
    if (result == true && context.mounted) {
      context.read<RequestsListCubit>().loadRequests();
    }
  }

  void _handleDelete(BuildContext context) async {
    final cubit = context.read<RequestsListCubit>();
    final success = await cubit.deleteDonationRequest(request.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Request deleted successfully'
                : 'Failed to delete request',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusUtils.getStatusColor(request.status);
    final isPending = request.status.toLowerCase() == 'pending';
    final canEdit = request.canEdit;
    final isUnderReview = isPending && !canEdit;

    return InkWell(
      onTap: () => DonationRequestBottomSheet.show(
        context,
        request,
        isCash,
        onEdit: canEdit ? () => _handleEdit(context) : null,
        onDelete: request.canDelete ? () => _handleDelete(context) : null,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: _themeColor, width: 4),
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
                child: Icon(
                  isCash ? Icons.currency_rupee : Icons.inventory_2_outlined,
                  color: _themeColor,
                ),
              ),
              const SizedBox(width: 10),
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
                        Row(
                          children: [
                            if (canEdit)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Editable',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            if (isUnderReview)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Under Review',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            StatusBadge(
                              status: request.status,
                              color: statusColor,
                            ),
                          ],
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
}
