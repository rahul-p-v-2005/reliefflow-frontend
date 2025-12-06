import 'package:flutter/material.dart';

class SelectCurrentLocationScreen extends StatefulWidget {
  const SelectCurrentLocationScreen({super.key});

  @override
  State<SelectCurrentLocationScreen> createState() =>
      _SelectCurrentLocationScreenState();
}

class _SelectCurrentLocationScreenState
    extends State<SelectCurrentLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          child: Text("MAP"),
        ),
      ),
    );
  }
}
