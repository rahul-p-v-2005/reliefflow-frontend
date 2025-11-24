import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/large_relief_centers_map.dart';
import 'package:url_launcher/url_launcher.dart';

class ReliefCentersMap extends StatelessWidget {
  const ReliefCentersMap({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(24),
        child: Stack(
          children: [
            SizedBox(
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
            Center(
              heightFactor: 4.8,
              child: Text(
                "Relief centers near you",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(
          context,
        ).push(
          MaterialPageRoute(builder: (context) => LargeReliefCentersMap()),
        );
      },
    );
  }
}
