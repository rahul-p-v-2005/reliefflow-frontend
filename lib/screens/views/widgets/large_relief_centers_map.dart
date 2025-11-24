import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LargeReliefCentersMap extends StatefulWidget {
  const LargeReliefCentersMap({super.key});

  @override
  State<LargeReliefCentersMap> createState() => _LargeReliefCentersMapState();
}

class _LargeReliefCentersMapState extends State<LargeReliefCentersMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Relief Centers"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(24),
          child: SizedBox(
            height: 400,
            child: FlutterMap(
              options: MapOptions(
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
                initialCenter: LatLng(
                  51.509364,
                  -0.128928,
                ), // Center the map over London
                initialZoom: 9.2,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/satellite/{z}/{x}/{y}.png?key=keaTXGBOhHJFBdz4XJri',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
