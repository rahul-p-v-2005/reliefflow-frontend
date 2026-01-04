import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LargeReliefCentersMap extends StatefulWidget {
  const LargeReliefCentersMap({super.key});

  @override
  State<LargeReliefCentersMap> createState() => _LargeReliefCentersMapState();
}

class _LargeReliefCentersMapState extends State<LargeReliefCentersMap> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relief Centers"),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(11.917, 75.335), // Kerala region
          zoom: 9.2,
        ),
        mapType: MapType
            .normal, // Changed from satellite - much lighter on resources
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
        buildingsEnabled: false, // Reduces rendering load
        trafficEnabled: false,
      ),
    );
  }
}
