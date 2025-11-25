import 'package:flutter/material.dart';
// import 'package:icon_forest/icon_forest.dart';
// import 'package:icon_forest/iconoir.dart';
// import 'package:icon_forest/mbi_combi.dart';
// import 'package:icon_forest/mbi_linecons.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/components/layout/header.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/screens/main_navigation/main_navigation.dart';
import 'package:reliefflow_frontend_public_app/screens/views/aid_request_details.dart';
import 'package:reliefflow_frontend_public_app/screens/views/request_aid.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/request_donation.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/relief_centers_map.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/request_status.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/weather_card.dart';
import 'package:star_menu/star_menu.dart';
import 'package:weather/weather.dart';
import 'package:icon_forest/gala_icons.dart';

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
  const _AidRequestList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 9,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Aid Requests',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(
              color: const Color.fromARGB(255, 243, 241, 241),
              thickness: 2.5,
            ),
            ListTile(
              title: Text("Flood Relief Aid"),
              subtitle: Text(
                "Request ID:",
                style: TextStyle(color: Colors.grey),
              ),
              trailing: SizedBox(
                width: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        // spacing: 4,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),

                            child: Text(
                              "Approved",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "2024-11-20",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationRequestList extends StatelessWidget {
  const _DonationRequestList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 9,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Donation Requests',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(
              color: const Color.fromARGB(255, 243, 241, 241),
              thickness: 2.5,
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag_outlined),
              title: Text("Food Supply"),
              subtitle: Text(
                "Request ID:",
                style: TextStyle(color: Colors.grey),
              ),
              trailing: SizedBox(
                width: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        // spacing: 4,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),

                            child: Text(
                              "Approved",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "2024-11-20",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
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
            ),
            Divider(
              color: const Color.fromARGB(255, 243, 241, 241),
              thickness: 2.5,
            ),
            ListTile(
              leading: Icon(Icons.currency_rupee_rounded),
              title: Text("Cash for Rehabilation"),
              subtitle: Text(
                "Request ID:",
                style: TextStyle(color: Colors.grey),
              ),
              trailing: SizedBox(
                width: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        // spacing: 4,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),

                            child: Text(
                              "Approved",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "2024-11-20",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestButtonsRow extends StatelessWidget {
  const _RequestButtonsRow({
    super.key,
  });

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
