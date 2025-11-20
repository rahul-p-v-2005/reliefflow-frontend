import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ReliefCentersMap extends StatelessWidget {
  const ReliefCentersMap({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(12),
      child: SizedBox(
        height: 100,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(
              51.509364,
              -0.128928,
            ), // Center the map over London
            initialZoom: 9.2,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.maptiler.com/maps/basic/{z}/{x}/{y}.png?key=keaTXGBOhHJFBdz4XJri',
            ),
          ],
        ),
      ),
    );
  }
}
