import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:url_launcher/url_launcher.dart';

class LargeReliefCentersMap extends StatefulWidget {
  const LargeReliefCentersMap({super.key});

  @override
  State<LargeReliefCentersMap> createState() => _LargeReliefCentersMapState();
}

class _LargeReliefCentersMapState extends State<LargeReliefCentersMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchReliefCenters();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 12.0,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _fetchReliefCenters() async {
    try {
      final response = await http.get(
        Uri.parse('$kBaseUrl/public/relief-centers'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List centers = data['message'];
          final Set<Marker> loadedMarkers = {};

          for (var center in centers) {
            // Check if location and coordinates exist
            // Backend schema: location: { type: 'Point', coordinates: [lon, lat] }
            if (center['address'] != null &&
                center['address']['location'] != null &&
                center['address']['location']['coordinates'] != null) {
              final coordinates = center['address']['location']['coordinates'];
              final double lon = (coordinates[0] as num).toDouble();
              final double lat = (coordinates[1] as num).toDouble();

              loadedMarkers.add(
                Marker(
                  markerId: MarkerId(center['_id'] ?? center['shelterName']),
                  position: LatLng(lat, lon),
                  infoWindow: InfoWindow(
                    title: center['shelterName'],
                    snippet: "Tap for details", // Updated prompt
                  ),
                  onTap: () => _showReliefCenterDetails(center, lat, lon),
                ),
              );
            }
          }

          setState(() {
            _markers = loadedMarkers;
          });
        }
      } else {
        debugPrint('Failed to load relief centers: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching relief centers: $e');
    }
  }

  Future<void> _launchMaps(double lat, double lon, String? name) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon${name != null ? '($name)' : ''}',
    );
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch maps');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps application')),
      );
    }
  }

  Future<void> _launchDialer(String number) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  void _showReliefCenterDetails(
    Map<String, dynamic> center,
    double lat,
    double lon,
  ) {
    final address = center['address'] ?? {};
    final parts = [
      address['addressLine1'],
      address['addressLine2'],
      address['addressLine3'],
    ].where((s) => s != null && s.toString().trim().isNotEmpty).join(', ');
    final pin = address['pinCode'] != null ? ' - ${address['pinCode']}' : '';
    final fullAddress = '$parts$pin';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              center['shelterName'] ?? 'Relief Center',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF1565C0),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      fullAddress.isNotEmpty
                          ? fullAddress
                          : 'Address details not available',
                      style: const TextStyle(
                        color: Color(0xFF424242),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: center['coordinatorNumber'] != null
                      ? () => _launchDialer(center['coordinatorNumber'])
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COORDINATOR',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                center['coordinatorName'] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              if (center['coordinatorNumber'] != null)
                                Text(
                                  center['coordinatorNumber'],
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (center['coordinatorNumber'] != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9), // Light green
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.phone_rounded,
                              color: Color(0xFF2E7D32), // Green
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _launchMaps(lat, lon, center['shelterName']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF265AE6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                icon: const Icon(Icons.directions_outlined, size: 20),
                label: const Text(
                  'Get Directions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

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
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
        buildingsEnabled: false,
        trafficEnabled: false,
      ),
    );
  }
}
