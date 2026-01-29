import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// import 'package:icon_forest/icon_forest.dart';
// import 'package:icon_forest/iconoir.dart';
// import 'package:icon_forest/mbi_combi.dart';
// import 'package:icon_forest/mbi_linecons.dart';
import 'package:reliefflow_frontend_public_app/components/layout/header.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';
import 'package:reliefflow_frontend_public_app/models/requests/aid_request.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/request_status.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/donation_request_type.dart';
import 'package:reliefflow_frontend_public_app/screens/aid_request/aid_request_details_bottom_sheet.dart';
import 'package:reliefflow_frontend_public_app/screens/aid_request/request_aid_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/request_donation.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/requests_list_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/relief_centers_map.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/weather_card.dart';
import 'package:star_menu/star_menu.dart';
import 'package:reliefflow_frontend_public_app/screens/notifications/cubit/notification_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh notifications when app comes to foreground
      // This ensures badge updates after receiving background notifications
      context.read<NotificationCubit>().silentRefresh();
    }
  }

  final StarMenuController controller = StarMenuController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 241, 241),
      appBar: Header(),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<RequestsListCubit>().refresh();
            },
            color: const Color(0xFF1E88E5),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ReliefCentersMap(),
                SizedBox(
                  height: 8,
                ),
                WeatherCard(),
                SizedBox(
                  height: 8,
                ),

                _AidRequestList(),
                SizedBox(
                  height: 8,
                ),
                // _RequestButtonsRow(),
                _DonationRequestList(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
            backgroundColor: Color.fromARGB(255, 30, 136, 229),
            onPressed: () {
              print('FloatingActionButton tapped');
            },
            child: Icon(
              Icons.health_and_safety_sharp,
              color: Colors.white,
            ),
          ).addStarMenu(
            items: [
              ActionChip(
                label: Text(
                  'Request Aid',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return RequestAidScreen();
                      },
                    ),
                  );
                  if (result == true) {
                    if (context.mounted) {
                      context.read<RequestsListCubit>().refresh();
                    }
                  }
                },
              ),
              ActionChip(
                backgroundColor: Colors.blue,
                label: Text(
                  'Request Donation',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute<dynamic>(
                      builder: (context) => const RequestDonation(),
                    ),
                  );
                  if (result == true) {
                    if (context.mounted) {
                      context.read<RequestsListCubit>().refresh();
                    }
                  }
                },
              ),
            ],
            params: StarMenuParameters.arc(
              ArcType.quarterTopLeft,
              radiusY: 50,
              radiusX: 100,
            ),
            controller: controller,
            onItemTapped: (index, controller) {
              controller.closeMenu?.call();
            },
          ),
    );
  }
}

class _AidRequestList extends StatelessWidget {
  const _AidRequestList();

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'approved':
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

  void _showBottomSheet(BuildContext context, AidRequest request) {
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

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF1E88E5);

    return BlocBuilder<RequestsListCubit, RequestsListState>(
      builder: (context, state) {
        // Get data from shared cubit
        List<AidRequest> requests = [];
        bool isLoading = false;
        String? error;
        int statusCode = 0;

        if (state is RequestsListLoading) {
          isLoading = true;
        } else if (state is RequestsListLoaded) {
          requests = state.aidRequests.take(3).toList();
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
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Aid Requests",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Track your active requests",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 2,
                color: const Color.fromARGB(255, 243, 241, 241),
              ),
              if (isLoading)
                Container(
                  padding: const EdgeInsets.all(24),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (error != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          statusCode == 401
                              ? Icons.lock_outline
                              : Icons.error_outline,
                          color: statusCode == 401
                              ? Colors.orange
                              : Colors.grey[400],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error,
                          style: TextStyle(
                            color: statusCode == 401
                                ? Colors.orange
                                : Colors.grey[500],
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
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
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
                )
              else if (requests.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No aid requests yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: requests.map((request) {
                      final statusColor = _getStatusColor(request.status);
                      return InkWell(
                        onTap: () => _showBottomSheet(context, request),
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
                                  child: const Icon(
                                    Icons.emergency_rounded,
                                    color: themeColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    6,
                                                  ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getStatusIcon(
                                                    request.status,
                                                  ),
                                                  color: Colors.white,
                                                  size: 10,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  _getStatusText(request),
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              request.address.isNotEmpty
                                                  ? request.address
                                                  : 'No location',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (request.createdAt != null)
                                            Text(
                                              DateFormat(
                                                'MMM dd',
                                              ).format(request.createdAt!),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[500],
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
      },
    );
  }

  String _getStatusText(AidRequest request) {
    // return request.status[0]
    //                                                     .toUpperCase() +
    //                                                 request.status
    //                                                     .substring(1)
    //                                                     .replaceAll('_', ' ');
    return switch (request.status) {
      'pending' => 'Pending',
      'accepted' => 'Accepted by admin',
      'in_progress' => 'In Progress',
      'rejected' => 'Rejected by admin',
      'completed' => 'Completed',
      _ => 'Unknown',
    };
  }
}

class RequestDetailsItem extends StatelessWidget {
  const RequestDetailsItem({
    super.key,
    // this.icon,
    required this.label,
    required this.id,
    required this.status,
    required this.time,
    required this.location,
    this.type,
  });

  final DonationRequestType? type;

  // final IconData? icon;
  final String label;
  final String id;
  final RequestStatus status;
  final DateTime time;
  final String location;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: (context),
          builder: (context) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              padding: EdgeInsets.all(24),
              child: AidRequestDetailsBottomSheet(),
            );
          },
        );
      },
      child: Container(
        //single list item
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color:
                  //  Colors.blue,
                  type != null
                  ? const Color.fromARGB(255, 1, 130, 6)
                  : Colors.blue,
              width: 4,
            ),
            // right: BorderSide(color: Colors.green, width: 1),
            // bottom: BorderSide(color: Colors.green, width: 1),
            // top: BorderSide(color: Colors.green, width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Container(
              //   color: Color.fromARGB(255, 30, 136, 229),
              //   height: 4,
              //   width: 2,
              // ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Icon(
                  // icon,
                  _getTypeIcon(type),
                  fill: 0,
                  color: type != null
                      ? const Color.fromARGB(255, 1, 130, 6)
                      : Colors.blue,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            //fontSize:
                          ),
                        ),
                        _StatusWidget(
                          status: status,
                        ),
                      ],
                    ),
                    Text(
                      "ID: $id",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BulletList(
                          location: location,
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(time),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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

  IconData _getTypeIcon(DonationRequestType? type) {
    switch (type) {
      case DonationRequestType.Cash:
        return Icons.currency_rupee;
      case DonationRequestType.Items:
        return Icons.inventory_2_outlined;
      default:
        return Icons.emergency_rounded;
    }
  }
}

class _StatusWidget extends StatelessWidget {
  const _StatusWidget({
    required this.status,
  });

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      width: 99,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: status.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 5,
        ),
        child: Row(
          children: [
            Icon(
              status.displayIcon,
              color: Colors.white,
              size: 17,
            ),
            Text(
              status.displayName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final String location;
  const _BulletList({
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Container(
              height: 7,
              width: 7,
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              location,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DonationRequestList extends StatelessWidget {
  const _DonationRequestList();

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

  void _showBottomSheet(BuildContext context, DonationRequest request) {
    final isCash = request.donationType == 'cash';
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestsListCubit, RequestsListState>(
      builder: (context, state) {
        // Get data from shared cubit
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
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
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
              ),
              Container(
                width: double.infinity,
                height: 2,
                color: const Color.fromARGB(255, 243, 241, 241),
              ),
              // Content
              if (isLoading)
                Container(
                  padding: const EdgeInsets.all(24),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (error != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          statusCode == 401
                              ? Icons.lock_outline
                              : Icons.error_outline,
                          color: statusCode == 401
                              ? Colors.orange
                              : Colors.grey[400],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error,
                          style: TextStyle(
                            color: statusCode == 401
                                ? Colors.orange
                                : Colors.grey[500],
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
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
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
                )
              else if (requests.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No donation requests yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: requests.map((request) {
                      final isCash = request.donationType == 'cash';
                      final statusColor = _getStatusColor(request.status);
                      final themeColor = isCash
                          ? const Color(0xFF43A047)
                          : const Color(0xFF1E88E5);

                      return InkWell(
                        onTap: () => _showBottomSheet(context, request),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(
                                color: themeColor,
                                width: 4,
                              ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              request.title ??
                                                  (isCash
                                                      ? 'Cash Request'
                                                      : 'Item Request'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    6,
                                                  ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getStatusIcon(
                                                    request.status,
                                                  ),
                                                  color: Colors.white,
                                                  size: 10,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  request.status[0]
                                                          .toUpperCase() +
                                                      request.status
                                                          .substring(1)
                                                          .replaceAll('_', ' '),
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                'MMM dd',
                                              ).format(request.createdAt!),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[500],
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
      },
    );
  }
}

class _RequestButtonsRow extends StatelessWidget {
  const _RequestButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Expanded(
          child: SizedBox(
            // width: 160,
            height: 140,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return RequestAidScreen();
                    },
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  250,
                  242,
                  66,
                  78,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  Icon(Icons.pan_tool, size: 34, color: Colors.white),
                  Text(
                    'Request Aid',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 24,
        ),
        Expanded(
          child: SizedBox(
            // width: 160,
            height: 140,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const RequestDonation(),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  250,
                  242,
                  66,
                  78,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Icon(
                    Icons.request_quote_sharp,
                    size: 34,
                    color: Colors.white,
                  ),
                  Text(
                    'Request Donation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
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
}

// ==================== AID REQUEST BOTTOM SHEET ====================
class _AidRequestBottomSheet extends StatelessWidget {
  final AidRequest request;
  const _AidRequestBottomSheet({required this.request});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
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
      case 'approved':
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
    final statusColor = _getStatusColor(request.status);
    final priorityColor = _getPriorityColor(request.priority);
    const themeColor = Color(0xFF1E88E5);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        'ID: ${request.id.length > 12 ? request.id.substring(0, 12) : request.id}...',
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

          // Status & Priority badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: priorityColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, color: priorityColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${request.priority[0].toUpperCase()}${request.priority.substring(1)} Priority',
                      style: TextStyle(
                        fontSize: 12,
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Description
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
            const SizedBox(height: 4),
            Text(
              request.description!,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
          ],

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
            const SizedBox(height: 20),
          ],

          // Location
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
          const SizedBox(height: 20),

          // Date & Type row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: themeColor.withOpacity(0.3)),
                    color: themeColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Requested Date',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.createdAt != null
                            ? DateFormat(
                                'MMM dd, yyyy',
                              ).format(request.createdAt!)
                            : 'N/A',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: themeColor.withOpacity(0.3)),
                    color: themeColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calamity Type',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.calamityTypeName ?? 'Aid Request',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Track button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        _AidRequestTrackingScreen(request: request),
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
        builder: (context) => _HomeFullScreenImageView(imageUrl: imageUrl),
      ),
    );
  }
}

// Full Screen Image View for Aid Requests (Home Screen)
class _HomeFullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const _HomeFullScreenImageView({required this.imageUrl});

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
class _AidRequestTrackingScreen extends StatelessWidget {
  final AidRequest request;
  const _AidRequestTrackingScreen({required this.request});

  int _getStatusStep(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'approved':
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
            // Details Card
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
                    _buildDetailRow(
                      'Type',
                      request.calamityTypeName ?? 'Aid Request',
                    ),
                    if (request.description != null &&
                        request.description!.isNotEmpty)
                      _buildDetailRow('Description', request.description!),
                    _buildDetailRow('Priority', request.priority.toUpperCase()),
                    _buildDetailRow(
                      'Submitted On',
                      request.createdAt != null
                          ? DateFormat(
                              'MMM dd, yyyy',
                            ).format(request.createdAt!)
                          : 'N/A',
                    ),
                    _buildDetailRow('Status', request.status.toUpperCase()),
                    if (request.address.isNotEmpty)
                      _buildDetailRow('Address', request.address),
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
                            color: Color(0xFF1E88E5),
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
                              builder: (context) => _HomeFullScreenImageView(
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
            // Timeline
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
                      _buildTimelineItem(
                        1,
                        'Rejected',
                        'Your request was not approved',
                        true,
                        true,
                        isRejected: true,
                      )
                    else ...[
                      _buildTimelineItem(
                        1,
                        'Pending',
                        'Request submitted',
                        currentStep >= 0,
                        currentStep == 0,
                      ),
                      _buildConnector(currentStep >= 1),
                      _buildTimelineItem(
                        2,
                        'Approved',
                        'Request approved',
                        currentStep >= 1,
                        currentStep == 1,
                      ),
                      _buildConnector(currentStep >= 2),
                      _buildTimelineItem(
                        3,
                        'In Progress',
                        'Aid being prepared',
                        currentStep >= 2,
                        currentStep == 2,
                      ),
                      _buildConnector(currentStep >= 3),
                      _buildTimelineItem(
                        4,
                        'Completed',
                        'Aid delivered',
                        currentStep >= 3,
                        currentStep == 3,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    int step,
    String title,
    String subtitle,
    bool isCompleted,
    bool isCurrent, {
    bool isRejected = false,
  }) {
    const themeColor = Color(0xFF1E88E5);
    Color circleColor;
    Widget circleChild;
    if (isRejected) {
      circleColor = Colors.red;
      circleChild = const Icon(Icons.close, color: Colors.white, size: 18);
    } else if (isCompleted && !isCurrent) {
      circleColor = Colors.green;
      circleChild = const Icon(Icons.check, color: Colors.white, size: 18);
    } else if (isCurrent) {
      circleColor = themeColor;
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
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
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
                      ? (isRejected ? Colors.red : themeColor)
                      : (isCompleted ? Colors.grey[700] : Colors.grey),
                ),
              ),
              if (isCurrent)
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isCompleted) {
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
