import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reliefflow_frontend_public_app/components/layout/header.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/relief_centers_map.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/weather_card.dart';
import 'package:reliefflow_frontend_public_app/screens/notifications/cubit/notification_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/home/widgets/widgets.dart';

/// The main home screen of the ReliefFlow public app.
/// Displays a dashboard with relief centers map, weather info,
/// and recent aid/donation requests.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 241, 241),
      appBar: Header(),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<RequestsListCubit>().refresh();
        },
        color: const Color(0xFF1E88E5),
        child: ListView(
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
            bottom: 100, // Space for floating bottom navigation bar
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            ReliefCentersMap(),
            SizedBox(height: 8),
            WeatherCard(),
            SizedBox(height: 8),
            AidRequestListWidget(),
            SizedBox(height: 8),
            DonationRequestListWidget(),
          ],
        ),
      ),
    );
  }
}
