import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/feature.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/properties.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/select_current_location.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final Debouncer<String> _debouncer = Debouncer<String>(
    const Duration(milliseconds: 300),
    initialValue: '',
  );

  List<Feature> _filteredLocations = [];
  bool _isSearching = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _textEditingController.addListener(() {
      _debouncer.value = _textEditingController.text;
    });
    _debouncer.values.listen(_searchLocations);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  /// Get user's current location for distance calculation
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Get distance string for a feature
  String? _getDistanceString(Feature feature) {
    if (_currentPosition == null || feature.geometry?.coordinates == null) {
      return null;
    }

    final coords = feature.geometry!.coordinates!;
    if (coords.length < 2) return null;

    // Photon returns [longitude, latitude]
    final distance = _calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      coords[1], // latitude
      coords[0], // longitude
    );

    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distance.toStringAsFixed(1)} km';
    }
  }

  // Google Maps API Key
  static const String _googleApiKey = 'AIzaSyA-iVr1hsRG4GSLpWksqxlmUAOsR-IRsdw';

  Uri getSearchUrl(String query) {
    // Use Google Places Autocomplete API
    String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&key=$_googleApiKey';

    if (_currentPosition != null) {
      url +=
          '&location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=50000';
    }

    return Uri.parse(url);
  }

  /// Deduplicates and filters location results
  List<Feature> _deduplicateLocations(List<Feature> features) {
    final seen = <String>{};
    final uniqueLocations = <Feature>[];

    for (final feature in features) {
      final props = feature.properties;
      if (props == null) continue;

      final name = props.name ?? '';
      final city = props.city ?? '';
      final district = props.district ?? props.county ?? '';
      final state = props.state ?? '';

      if (name.isEmpty) continue;

      // Create composite key for deduplication
      final key =
          '${name.toLowerCase()}_${city.toLowerCase()}_${district.toLowerCase()}_${state.toLowerCase()}';

      if (!seen.contains(key)) {
        seen.add(key);

        final osmValue = props.osmValue ?? '';

        // Skip very generic administrative boundaries unless they're cities
        if ((osmValue == 'administrative' || osmValue == 'boundary') &&
            props.type != 'city') {
          continue;
        }

        uniqueLocations.add(feature);
      }
    }

    // Sort by distance if we have current position
    if (_currentPosition != null) {
      uniqueLocations.sort((a, b) {
        final distA = _getDistance(a);
        final distB = _getDistance(b);

        if (distA == null && distB == null) return 0;
        if (distA == null) return 1;
        if (distB == null) return -1;

        return distA.compareTo(distB);
      });
    }

    return uniqueLocations;
  }

  /// Get numeric distance for sorting
  double? _getDistance(Feature feature) {
    if (_currentPosition == null || feature.geometry?.coordinates == null) {
      return null;
    }

    final coords = feature.geometry!.coordinates!;
    if (coords.length < 2) return null;

    return _calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      coords[1],
      coords[0],
    );
  }

  /// Gets a readable location type label
  String _getLocationTypeLabel(Properties? props) {
    if (props == null) return 'Location';

    final osmValue = props.osmValue?.toLowerCase() ?? '';
    final type = props.type?.toLowerCase() ?? '';

    if (osmValue == 'city' || type == 'city') return 'City';
    if (osmValue == 'town' || type == 'town') return 'Town';
    if (osmValue == 'village' || type == 'village') return 'Village';
    if (osmValue == 'station') return 'Railway Station';
    if (osmValue == 'aerodrome') return 'Airport';
    if (osmValue == 'university' || osmValue == 'college') {
      return 'Educational Institution';
    }
    if (osmValue == 'stadium') return 'Stadium';
    if (type == 'county') return 'District';

    return 'Location';
  }

  /// Formats the subtitle with available location details
  String _formatSubtitle(Properties? props) {
    if (props == null) return '';

    final parts = <String>[];

    // Add locality/street if available and different from name
    if (props.locality != null &&
        props.locality!.isNotEmpty &&
        props.locality != props.name) {
      parts.add(props.locality!);
    } else if (props.street != null &&
        props.street!.isNotEmpty &&
        props.street != props.name) {
      parts.add(props.street!);
    }

    // Add city if available and different from name
    if (props.city != null &&
        props.city!.isNotEmpty &&
        props.city != props.name) {
      parts.add(props.city!);
    }

    // Add district/county if available
    final district = props.district ?? props.county;
    if (district != null &&
        district.isNotEmpty &&
        district != props.name &&
        district != props.city) {
      parts.add(district);
    }

    // Always add state if available
    if (props.state != null && props.state!.isNotEmpty) {
      parts.add(props.state!);
    }

    return parts.join(', ');
  }

  Future<void> _searchLocations(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredLocations = [];
        _isSearching = false;
      });
      return;
    }

    try {
      setState(() {
        _isSearching = true;
      });

      final res = await http.get(getSearchUrl(query));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List<dynamic>;
          final features = predictions
              .map(
                (p) => Feature(
                  type: 'Feature',
                  properties: Properties(
                    name:
                        p['structured_formatting']?['main_text'] ??
                        p['description']?.toString().split(',').first ??
                        'Unknown',
                    osmType: p['place_id'],
                    locality: p['structured_formatting']?['secondary_text'],
                  ),
                  geometry: null,
                ),
              )
              .toList();

          setState(() {
            _filteredLocations = features;
            _isSearching = false;
          });
        } else {
          debugPrint('Places API error: ${data['status']}');
          setState(() {
            _filteredLocations = [];
            _isSearching = false;
          });
        }
      } else {
        throw Exception('Failed to search locations');
      }
    } catch (e) {
      debugPrint('Error searching locations: $e');
      setState(() {
        _isSearching = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to search locations. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Select a location",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
          children: [
            _buildSearchField(),
            const _SelectFromMapButton(),
            Expanded(
              child: _buildLocationList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 45,
      child: TextFormField(
        controller: _textEditingController,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.withAlpha(100),
            ),
          ),
          hintText: "Search an area",
          hintStyle: TextStyle(
            color: Colors.grey.withAlpha(120),
            fontWeight: FontWeight.bold,
            fontSize: 15.5,
          ),
          prefixIcon: const Icon(Icons.search_rounded),
          prefixIconColor: const Color.fromARGB(255, 30, 136, 229),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: _textEditingController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _textEditingController.clear();
                    setState(() {
                      _filteredLocations = [];
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Colors.grey,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLocationList() {
    if (_isSearching) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(12),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_textEditingController.text.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(12),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Search for your location',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredLocations.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(12),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No locations found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: ListView.separated(
        itemCount: _filteredLocations.length,
        separatorBuilder: (context, index) => const _Separator(),
        itemBuilder: (context, index) {
          final feature = _filteredLocations[index];
          final props = feature.properties;

          return _LocationListItem(
            locationName: props?.name ?? 'Unnamed location',
            locationType: _getLocationTypeLabel(props),
            subtitle: _formatSubtitle(props),
            distance: _getDistanceString(feature),
            onTap: () async {
              // Navigate to map screen for fine-tuning
              final result = await Navigator.push<Feature>(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectCurrentLocationScreen(
                    preselectedLocation: feature,
                  ),
                ),
              );

              // If user confirmed from map, return to previous screen
              if (result != null && mounted) {
                Navigator.pop(context, result);
              }
            },
          );
        },
      ),
    );
  }
}

class _SelectFromMapButton extends StatelessWidget {
  const _SelectFromMapButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<Feature>(
          context,
          MaterialPageRoute(
            builder: (context) => const SelectCurrentLocationScreen(),
          ),
        );

        // If user confirmed a location from map, return it
        if (result != null && context.mounted) {
          Navigator.pop(context, result);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        height: 45,
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Icon(
                Icons.gps_fixed_sharp,
                color: Colors.red,
                size: 26,
              ),
              SizedBox(width: 8),
              Text(
                "Select location from map",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.grey[100],
      thickness: 1,
      height: 1,
    );
  }
}

class _LocationListItem extends StatelessWidget {
  final String locationName;
  final String locationType;
  final String subtitle;
  final String? distance;
  final VoidCallback onTap;

  const _LocationListItem({
    required this.locationName,
    required this.locationType,
    required this.subtitle,
    this.distance,
    required this.onTap,
  });

  IconData _getIconForLocationType(String type) {
    switch (type.toLowerCase()) {
      case 'city':
      case 'town':
      case 'village':
        return Icons.location_city_rounded;
      case 'railway station':
        return Icons.train_rounded;
      case 'airport':
        return Icons.flight_rounded;
      case 'educational institution':
        return Icons.school_rounded;
      case 'stadium':
        return Icons.stadium_rounded;
      case 'district':
        return Icons.map_rounded;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForLocationType(locationType),
                  size: 28,
                  color: const Color.fromARGB(255, 30, 136, 229),
                ),
                if (distance != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    distance!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    locationName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
