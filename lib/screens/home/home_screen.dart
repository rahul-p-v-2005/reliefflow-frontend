import 'package:flutter/material.dart';
// import 'package:icon_forest/icon_forest.dart';
// import 'package:icon_forest/iconoir.dart';
// import 'package:icon_forest/mbi_combi.dart';
// import 'package:icon_forest/mbi_linecons.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/components/layout/header.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/screens/views/request_aid.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/request_donation.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/relief_centers_map.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/request_status.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/weather_card.dart';
import 'package:weather/weather.dart';
import 'package:icon_forest/gala_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              // _RequestButtonsRow(),
              _RequestList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 244, 238, 238),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 9,
            spreadRadius: 1,
            offset: Offset(3, 3),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 9,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Requests',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
              ),
              onPressed: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RequestStatus(),
                  ),
                ),
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [Text("Recents"), Text("Recents")],
                  ),
                  Icon(Icons.arrow_forward_ios),
                ],
              ),
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
