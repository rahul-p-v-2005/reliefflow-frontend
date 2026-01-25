import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reliefflow_frontend_public_app/firebase_options.dart';
import 'package:reliefflow_frontend_public_app/screens/splash_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/notifications/notification_screen.dart';
import 'package:reliefflow_frontend_public_app/services/fcm_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.getToken().then((token) {
    print('FCM Token: $token');
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize FCM after app starts
    _initFcm();
  }

  Future<void> _initFcm() async {
    await FcmService().initialize();

    // Listen for notification taps
    FcmService().onNotificationTap = (data) {
      final type = data['type'];
      print('Handling notification tap: $type');

      // Navigate based on type
      if (type == 'task_assigned') {
        // navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: data['taskId'])));
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
      } else if (type == 'aid_request_accepted' ||
          type == 'aid_request_submitted') {
        // navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => AidRequestDetailsScreen(id: data['aidRequestId'])));
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
      } else {
        // Default to notification screen/details
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'ReliefFlow',
      theme: _buildTheme(Brightness.light),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      restorationScopeId:
          'reliefflow_app', // Enable state restoration for activity recreation
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final base = ThemeData(
    brightness: brightness,
    primaryColor: Color(0xFF1E88E5),
  );
  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
  );
}
