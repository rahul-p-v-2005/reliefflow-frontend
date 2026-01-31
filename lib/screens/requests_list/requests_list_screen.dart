import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/widgets/widgets.dart';

/// Screen that displays all user requests (aid requests and donation requests).
/// Uses tabs for easy navigation between categories.
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

class _RequestListScreenBodyState extends State<_RequestListScreenBody>
    with SingleTickerProviderStateMixin {
  String currentSelectedStatus = "All";
  late TabController _tabController;

  /// Status filters aligned with backend models:
  /// - AidRequest: pending, accepted, in_progress, completed, rejected
  /// - DonationRequest: pending, accepted, in_progress, partially_fulfilled, completed, rejected
  List<String> get statusFilters => [
    "All",
    "pending",
    "accepted",
    "in_progress",
    "partially_fulfilled",
    "completed",
    "rejected",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            // Separate donation requests by type
            final cashRequests = state.donationRequests
                .where((r) => r.donationType == 'cash')
                .toList();
            final itemRequests = state.donationRequests
                .where((r) => r.donationType == 'item')
                .toList();

            return Column(
              children: [
                // Status Filters
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: StatusFilterChips(
                    statusFilters: statusFilters,
                    currentSelectedStatus: currentSelectedStatus,
                    onStatusSelected: (status) {
                      setState(() => currentSelectedStatus = status);
                      context.read<RequestsListCubit>().filterByStatus(status);
                    },
                  ),
                ),
                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF1E88E5),
                    ),
                    indicatorPadding: const EdgeInsets.all(4),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    tabs: [
                      _buildTab(
                        icon: Icons.emergency,
                        label: 'Aid',
                        count: state.aidRequests.length,
                        color: const Color(0xFF1E88E5),
                      ),
                      _buildTab(
                        icon: Icons.currency_rupee,
                        label: 'Cash',
                        count: cashRequests.length,
                        color: const Color(0xFF43A047),
                      ),
                      _buildTab(
                        icon: Icons.inventory_2,
                        label: 'Items',
                        count: itemRequests.length,
                        color: const Color(0xFF1E88E5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Aid Requests Tab
                      RefreshIndicator(
                        onRefresh: () async =>
                            context.read<RequestsListCubit>().loadRequests(),
                        child: ListView(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom: 100,
                          ),
                          children: [
                            AidRequestsSection(requests: state.aidRequests),
                          ],
                        ),
                      ),
                      // Cash Donations Tab
                      RefreshIndicator(
                        onRefresh: () async =>
                            context.read<RequestsListCubit>().loadRequests(),
                        child: ListView(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom: 100,
                          ),
                          children: [
                            DonationRequestListCard(
                              icon: Icons.currency_rupee,
                              iconColor: const Color(0xFF43A047),
                              title: 'Cash Donation Requests',
                              subtitle: 'Financial assistance requests',
                              requests: cashRequests,
                              isCash: true,
                            ),
                          ],
                        ),
                      ),
                      // Item Donations Tab
                      RefreshIndicator(
                        onRefresh: () async =>
                            context.read<RequestsListCubit>().loadRequests(),
                        child: ListView(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom: 100,
                          ),
                          children: [
                            DonationRequestListCard(
                              icon: Icons.inventory_2,
                              iconColor: const Color(0xFF1E88E5),
                              title: 'Item Donation Requests',
                              subtitle: 'Material & supplies requests',
                              requests: itemRequests,
                              isCash: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(String message, {int statusCode = 0}) {
    final isSessionExpired = statusCode == 401;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSessionExpired ? Icons.lock_outline : Icons.error_outline,
            size: 64,
            color: isSessionExpired ? Colors.orange : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
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
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ] else
            ElevatedButton.icon(
              onPressed: () => context.read<RequestsListCubit>().loadRequests(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
