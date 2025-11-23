import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ReliefCentersMap extends StatelessWidget {
  const ReliefCentersMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey,
        //     blurRadius: 3,
        //     // blurStyle: BlurStyle.normal,
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 3,
        children: [
          Text(
            "  Relief Centers Near You",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(8),
            child: SizedBox(
              height: 100,
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
        ],
      ),
    );
  }
}
