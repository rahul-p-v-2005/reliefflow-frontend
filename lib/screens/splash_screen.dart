import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/screens/auth/login_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/main_navigation/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // check if we have token
    _checkToken();
    super.initState();
  }

  Future<void> _checkToken() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kTokenStorageKey);

    if (token == null || token.isEmpty) {
      // navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
        (r) => false,
      );
    } else {
      // navigate to home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation()),
        (r) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
