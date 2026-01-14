import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reliefflow_frontend_public_app/screens/views/widgets/large_relief_centers_map.dart';

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
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(11.917, 75.335), // Kerala region
                  zoom: 9.2,
                ),
                mapType: MapType.normal,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
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
