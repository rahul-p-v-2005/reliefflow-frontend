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
            IgnorePointer(
              child: SizedBox(
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
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Relief centers near you",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
