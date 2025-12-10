import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reliefflow_frontend_public_app/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReliefFlow',
      theme: _buildTheme(Brightness.light),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final base = ThemeData(brightness: brightness);
  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
  );
}
