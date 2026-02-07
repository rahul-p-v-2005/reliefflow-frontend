import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/models/requests/aid_request.dart';
import 'package:reliefflow_frontend_public_app/screens/aid_request/aid_request_bottom_sheet.dart';
import 'package:reliefflow_frontend_public_app/screens/aid_request/edit_aid_request_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';
import 'package:reliefflow_frontend_public_app/components/shared/shared.dart';

const _kThemeColor = Color(0xFF1E88E5);

/// Section widget displaying a list of aid requests for the requests list screen.
class AidRequestsSection extends StatelessWidget {
  final List<AidRequest> requests;

  const AidRequestsSection({super.key, required this.requests});

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
              const Icon(Icons.emergency, color: _kThemeColor, size: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _kThemeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${requests.length}',
                  style: const TextStyle(
                    color: _kThemeColor,
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
              'No aid requests yet',
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
        children: requests.map((request) {
          return _AidRequestListItem(request: request);
        }).toList(),
      ),
    );
  }
}

class _AidRequestListItem extends StatelessWidget {
  final AidRequest request;

  const _AidRequestListItem({required this.request});

  String _getStatusText() {
    return switch (request.status) {
      'pending' => 'Pending',
      'accepted' => 'Accepted by admin',
      'in_progress' => 'In Progress',
      'rejected' => 'Rejected by admin',
      'completed' => 'Completed',
      _ => 'Unknown',
    };
  }

  void _handleEdit(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditAidRequestScreen(
          request: request,
        ),
      ),
    );

    // Refresh the list if edit was successful
    if (result == true && context.mounted) {
      context.read<RequestsListCubit>().loadRequests();
    }
  }

  void _handleDelete(BuildContext context) async {
    final success = await context.read<RequestsListCubit>().deleteAidRequest(
      request.id,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Request deleted' : 'Failed to delete'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusUtils.getStatusColor(request.status);

    return InkWell(
      onTap: () => AidRequestBottomSheet.show(
        context,
        request,
        onEdit: request.canEdit ? () => _handleEdit(context) : null,
        onDelete: request.canDelete ? () => _handleDelete(context) : null,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: _kThemeColor, width: 4),
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
                  color: _kThemeColor,
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
                            request.calamityTypeName ?? 'Aid Request',
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                StatusUtils.getStatusIcon(request.status),
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _getStatusText(),
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
                    // Editable/Under Review indicator
                    if (request.canEdit ||
                        (request.status == 'pending' && request.isRead)) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (request.canEdit)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 10,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'Editable',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (request.status == 'pending' &&
                              request.isRead)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: 10,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'Under Review',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
  }
}
