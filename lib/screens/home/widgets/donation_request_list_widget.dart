import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/donation_request/donation_request_bottom_sheet.dart';
import 'package:reliefflow_frontend_public_app/screens/donation_request/edit_donation_request_screen.dart';
import 'package:reliefflow_frontend_public_app/components/shared/shared.dart';

const _kThemeColorCash = Color(0xFF43A047);
const _kThemeColorItem = Color(0xFF1E88E5);

/// Displays a list of recent donation requests on the home screen.
/// Shows up to 3 most recent requests with status indicators.
class DonationRequestListWidget extends StatelessWidget {
  const DonationRequestListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestsListCubit, RequestsListState>(
      builder: (context, state) {
        List<DonationRequest> requests = [];
        bool isLoading = false;
        String? error;
        int statusCode = 0;

        if (state is RequestsListLoading) {
          isLoading = true;
        } else if (state is RequestsListLoaded) {
          requests = state.donationRequests.take(3).toList();
        } else if (state is RequestsListError) {
          error = state.message;
          statusCode = state.statusCode;
        }

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
              if (isLoading)
                _buildLoading()
              else if (error != null)
                _buildError(context, error, statusCode)
              else if (requests.isEmpty)
                _buildEmpty()
              else
                _buildList(context, requests),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Donation Requests",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Text(
            "Requesting financial & item support",
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

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String error, int statusCode) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              statusCode == 401 ? Icons.lock_outline : Icons.error_outline,
              color: statusCode == 401 ? Colors.orange : Colors.grey[400],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: statusCode == 401 ? Colors.orange : Colors.grey[500],
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (statusCode == 401) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: 4),
              Text(
                'Redirecting...',
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ] else
              TextButton(
                onPressed: () {
                  context.read<RequestsListCubit>().loadRequests();
                },
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              'No donation requests yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DonationRequest> requests) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: requests.map((request) {
          return _DonationRequestCard(request: request);
        }).toList(),
      ),
    );
  }
}

class _DonationRequestCard extends StatelessWidget {
  final DonationRequest request;

  const _DonationRequestCard({required this.request});

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
    final isCash = request.donationType == 'cash';
    final statusColor = StatusUtils.getStatusColor(request.status);
    final themeColor = isCash ? _kThemeColorCash : _kThemeColorItem;

    return InkWell(
      onTap: () => DonationRequestBottomSheet.show(
        context,
        request,
        isCash,
        onEdit: request.canEdit ? () => _handleEdit(context) : null,
        onDelete: request.canDelete ? () => _handleDelete(context) : null,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: themeColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Icon(
                  isCash ? Icons.currency_rupee : Icons.inventory_2_outlined,
                  color: themeColor,
                  size: 20,
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
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(
                          status: request.status,
                          color: statusColor,
                          fontSize: 9,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isCash
                              ? '₹${request.amount?.toStringAsFixed(0) ?? "0"}'
                              : '${request.itemDetails?.length ?? 0} items',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (request.createdAt != null)
                          Text(
                            DateFormat(
                              'MMM dd,yyyy',
                            ).format(request.createdAt!),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold,
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
