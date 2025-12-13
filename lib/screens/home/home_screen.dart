import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:icon_forest/icon_forest.dart';
// import 'package:icon_forest/iconoir.dart';
// import 'package:icon_forest/mbi_combi.dart';
// import 'package:icon_forest/mbi_linecons.dart';
import 'package:reliefflow_frontend_public_app/components/layout/header.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/request_status.dart';
import 'package:reliefflow_frontend_public_app/screens/views/aid_request_details.dart';
import 'package:reliefflow_frontend_public_app/screens/views/request_aid.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/request_donation.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/relief_centers_map.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/request_details_item.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/weather_card.dart';
import 'package:star_menu/star_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          child: ListView(
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return RequestAidScreen();
                      },
                    ),
                  );
                },
              ),
              ActionChip(
                backgroundColor: Colors.blue,
                label: Text(
                  'Request Donation',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const RequestDonation(),
                    ),
                  );
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
          Container(
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recent Aid Requests",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
            //separator
            width: double.infinity,
            height: 2,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 243, 241, 241),
            ),
          ),
          Container(
            //list of request items
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              spacing: 4,
              children: [
                RequestDetailsItem(
                  // icon: Icons.emergency_rounded,
                  label: "Flood Relief",
                  id: "AID-001",
                  time: DateTime.now(),
                  location: "Azhikode",
                  status: RequestStatus.Approved,
                ),
                RequestDetailsItem(
                  // icon: Icons.emergency_rounded,
                  label: "Flood Relief",
                  id: "AID-002",
                  status: RequestStatus.Completed,
                  time: DateTime.now(),
                  location: "Kannur",
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              child: AidRequestDetails(),
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
          Container(
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recent Donation Requests",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
            //separator
            width: double.infinity,
            height: 2,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 243, 241, 241),
            ),
          ),
          Container(
            //list of request items
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              spacing: 4,
              children: [
                RequestDetailsItem(
                  // icon: Icons.emergency_rounded,
                  label: "Cash Donation",
                  id: "AID-001",
                  time: DateTime.now(),
                  location: "Azhikode",
                  status: RequestStatus.Approved,
                  type: DonationRequestType.Cash,
                ),
                RequestDetailsItem(
                  // icon: Icons.emergency_rounded,
                  label: "Item Donation",
                  id: "AID-002",
                  status: RequestStatus.Completed,
                  time: DateTime.now(),
                  location: "Kannur",
                  type: DonationRequestType.Items,
                ),
              ],
            ),
          ),
        ],
      ),
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
