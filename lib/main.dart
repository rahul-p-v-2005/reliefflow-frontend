import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reliefflow_frontend_public_app/firebase_options.dart';
import 'package:reliefflow_frontend_public_app/screens/splash_screen.dart';
import 'package:reliefflow_frontend_public_app/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
