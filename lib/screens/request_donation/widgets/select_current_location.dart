import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/feature.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/geometry.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/location_search_response.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/properties.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/select_location.dart';

class SelectCurrentLocationScreen extends StatefulWidget {
  final Feature? preselectedLocation;

  const SelectCurrentLocationScreen({
    super.key,
    this.preselectedLocation,
  });

  @override
  State<SelectCurrentLocationScreen> createState() =>
      _SelectCurrentLocationScreenState();
}

class _SelectCurrentLocationScreenState
    extends State<SelectCurrentLocationScreen> {
  late MapController _mapController;
  LatLng _currentCenter = LatLng(11.917, 75.335);
  bool _isLoadingAddress = false;
  String _locationName = 'Loading...';
  String _locationAddress = '';
  Feature? _selectedFeature;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // If coming from search screen with preselected location
    if (widget.preselectedLocation != null) {
      _initializeWithPreselectedLocation();
    } else {
      // Start with default location and fetch address
      _fetchAddressForLocation(_currentCenter);
    }
  }

  void _initializeWithPreselectedLocation() {
    final coords = widget.preselectedLocation!.geometry?.coordinates;
    if (coords != null && coords.length >= 2) {
      _currentCenter = LatLng(coords[1], coords[0]); // lat, lon
      _selectedFeature = widget.preselectedLocation;
      _updateLocationDetails(widget.preselectedLocation!);
    }
  }

  void _updateLocationDetails(Feature feature) {
    final props = feature.properties;
    setState(() {
      _locationName = props?.name ?? 'Unknown location';
      _locationAddress = _formatAddress(props);
    });
  }

  String _formatAddress(Properties? props) {
    if (props == null) return '';

    final parts = <String>[];

    if (props.locality != null && props.locality!.isNotEmpty) {
      parts.add(props.locality!);
    } else if (props.street != null && props.street!.isNotEmpty) {
      parts.add(props.street!);
    }

    if (props.city != null && props.city!.isNotEmpty) {
      parts.add(props.city!);
    }

    final district = props.district ?? props.county;
    if (district != null && district.isNotEmpty) {
      parts.add(district);
    }

    if (props.state != null && props.state!.isNotEmpty) {
      parts.add(props.state!);
    }

    if (props.country != null && props.country!.isNotEmpty) {
      parts.add(props.country!);
    }

    return parts.join(', ');
  }

  Future<void> _fetchAddressForLocation(LatLng location) async {
    setState(() {
      _isLoadingAddress = true;
      _locationName = 'Loading...';
      _locationAddress = '';
    });

    log(
      'Fetching address for location: ${location.latitude}, ${location.longitude}',
    );

    try {
      // Photon reverse geocoding endpoint
      final url = Uri.parse(
        'https://photon.komoot.io/reverse?lon=${location.longitude}&lat=${location.latitude}',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'ReliefflowApp/1.0 (contact:alansherhan10@gmail.com)',
        },
      );

      log(
        'Reverse geocoding response status: ${response.statusCode}, url: $url',
      );

      if (response.statusCode == 200) {
        final data = LocationSearchResponse.fromJson(jsonDecode(response.body));

        if (data.features != null && data.features!.isNotEmpty) {
          final feature = data.features!.first;
          _selectedFeature = feature;
          _updateLocationDetails(feature);
        } else {
          setState(() {
            _locationName = 'Unknown location';
            _locationAddress =
                '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
          });
        }
      }
    } catch (e) {
      log('Error fetching address: $e');
      setState(() {
        _locationName = 'Unable to fetch address';
        _locationAddress =
            '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  Timer? _debounceTimer;

  void _onMapMoved() {
    final center = _mapController.camera.center;
    final distance = const Distance().as(
      LengthUnit.Meter,
      _currentCenter,
      center,
    );

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Only check distance if significant move
    if (distance > 100) {
      // Increased to 100m
      _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
        _currentCenter = center;
        _fetchAddressForLocation(center);
      });
    }
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedSnackbar();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedSnackbar();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(newLocation, 15);
      _currentCenter = newLocation;
      _fetchAddressForLocation(newLocation);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get current location'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable location services to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location permission is required'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmLocation() {
    if (_selectedFeature != null) {
      // Return the selected feature with updated coordinates
      final updatedFeature = Feature(
        type: _selectedFeature!.type,
        properties: _selectedFeature!.properties,
        geometry: Geometry(
          type: 'Point',
          coordinates: [_currentCenter.longitude, _currentCenter.latitude],
        ),
      );
      Navigator.pop(context, updatedFeature);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: widget.preselectedLocation != null ? 15 : 12,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  _onMapMoved();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.reliefflow.app',
              ),
            ],
          ),
          // Center marker (fixed position)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 48,
                  color: Colors.red,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
                const SizedBox(height: 48), // Offset to center the pin tip
              ],
            ),
          ),
          // Top bar with back button and search
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Colors.blue,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        readOnly: true,
                        onTap: () async {
                          // Navigate to search screen
                          final result = await Navigator.push<Feature>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SelectLocationScreen(),
                            ),
                          );

                          if (result != null && mounted) {
                            // User selected a location from search
                            final coords = result.geometry?.coordinates;
                            if (coords != null && coords.length >= 2) {
                              final newLocation = LatLng(coords[1], coords[0]);
                              _mapController.move(newLocation, 15);
                              _currentCenter = newLocation;
                              _selectedFeature = result;
                              _updateLocationDetails(result);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom section with current location button and address card
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Current location button
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Center(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _moveToCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      icon: const Icon(Icons.gps_fixed, size: 20),
                      label: const Text(
                        'Current Location',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Address card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.grey[50],
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.blue,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _isLoadingAddress
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _locationName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                            ],
                          ),
                          subtitle: _locationAddress.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    _locationAddress,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            8.0,
                            16.0,
                            12.0,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoadingAddress
                                  ? null
                                  : _confirmLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[300],
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();

    _debounceTimer?.cancel();
    super.dispose();
  }
}
