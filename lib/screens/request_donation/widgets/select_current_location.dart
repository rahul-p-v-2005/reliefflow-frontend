import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:reliefflow_frontend_public_app/models/location_search_response/feature.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/geometry.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/location_search_response.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/properties.dart';

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
  GoogleMapController? _mapController;
  LatLng _currentCenter = const LatLng(
    11.917,
    75.335,
  ); // Default to Kannur/Kerala area
  bool _isLoadingAddress = false;
  String _locationName = 'Loading...';
  String _locationAddress = '';
  Feature? _selectedFeature;
  Timer? _debounceTimer;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Feature> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // If coming from search screen with preselected location
    if (widget.preselectedLocation != null) {
      _initializeWithPreselectedLocation();
    } else {
      // Start with default location and fetch address
      _fetchAddressForLocation(_currentCenter);
      _getCurrentLocation(); // Auto-fetch current location on load
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

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchDebounceTimer?.isActive ?? false) _searchDebounceTimer!.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchLocations(_searchController.text);
      } else {
        setState(() {
          _searchResults = [];
          _showSearchResults = false;
        });
      }
    });
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) return;

    log('_searchLocations called with query: $query');

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      // Use Photon API for search (free, no API key required)
      String url =
          'https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}&limit=5';

      // Bias towards current center
      url += '&lat=${_currentCenter.latitude}&lon=${_currentCenter.longitude}';

      log('Photon API URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'ReliefflowApp/1.0'},
      );
      log('Photon API status: ${response.statusCode}');
      // log(
      //   'Photon API response: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
      // );

      if (response.statusCode == 200) {
        final data = LocationSearchResponse.fromJson(jsonDecode(response.body));
        // log('Parsed features count: ${data.features?.length ?? 0}');
        if (mounted) {
          setState(() {
            _searchResults = data.features ?? [];
            _isSearching = false;
          });
        }
      } else {
        log('Photon API failed with status: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    } catch (e, stackTrace) {
      log('Search error: $e');
      log('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  void _selectSearchResult(Feature feature) {
    final coords = feature.geometry?.coordinates;
    if (coords != null && coords.length >= 2) {
      final lat = coords[1];
      final lng = coords[0];
      final newLocation = LatLng(lat, lng);

      setState(() {
        _currentCenter = newLocation;
        _showSearchResults = false;
        _searchController.text = feature.properties?.name ?? '';
        _selectedFeature = feature;
        _updateLocationDetails(feature);
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newLocation, zoom: 15),
        ),
      );
      _searchFocusNode.unfocus();
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
    if (!mounted) return;
    setState(() {
      _isLoadingAddress = true;
      _locationName = 'Loading...';
      _locationAddress = '';
    });

    log('Fetching address for: ${location.latitude}, ${location.longitude}');

    try {
      // Use Photon reverse geocoding (free, no API key required)
      final url = Uri.parse(
        'https://photon.komoot.io/reverse?lon=${location.longitude}&lat=${location.latitude}',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'ReliefflowApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = LocationSearchResponse.fromJson(jsonDecode(response.body));

        if (data.features != null && data.features!.isNotEmpty) {
          final feature = data.features!.first;
          _selectedFeature = feature;
          if (mounted) _updateLocationDetails(feature);
        } else {
          if (mounted) {
            setState(() {
              _locationName = 'Unknown location';
              _locationAddress =
                  '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
            });
          }
        }
      }
    } catch (e) {
      log('Geocoding error: $e');
      if (mounted) {
        setState(() {
          _locationName = 'Unable to fetch address';
          _locationAddress =
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  void _onCameraIdle() {
    // Debounce address fetching after camera stops moving
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchAddressForLocation(_currentCenter);
    });
  }

  void _onCameraMove(CameraPosition position) {
    _currentCenter = position.target;
    // Dismiss search if moving map
    if (_showSearchResults) {
      setState(() {
        _showSearchResults = false;
      });
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Only show dialog if user explicitly requested (not on init)
        // But here we might want to just return if it's init
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newLocation, zoom: 15),
        ),
      );
      _currentCenter = newLocation;
      _fetchAddressForLocation(newLocation);
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  void _confirmLocation() {
    if (_selectedFeature != null) {
      // Update coordinates to the exact center pin location
      final updatedFeature = Feature(
        type: _selectedFeature!.type,
        properties: _selectedFeature!.properties,
        geometry: Geometry(
          type: 'Point',
          coordinates: [_currentCenter.longitude, _currentCenter.latitude],
        ),
      );
      Navigator.pop(context, updatedFeature);
    } else {
      // Create a basic feature if none selected (e.g. just dragged there)
      final feature = Feature(
        type: 'Feature',
        properties: Properties(
          name: _locationName,
        ),
        geometry: Geometry(
          type: 'Point',
          coordinates: [_currentCenter.longitude, _currentCenter.latitude],
        ),
      );
      Navigator.pop(context, feature);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAP
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 15, // Closer zoom like volunteer app
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            onTap: (_) {
              // Dismiss search
              setState(() {
                _showSearchResults = false;
              });
              _searchFocusNode.unfocus();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Center Pin (Fixed)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 40,
              ), // Adjust for pin height
              child: Icon(
                Icons.location_on,
                size: 50,
                color: Theme.of(context).primaryColor, // Match theme
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // FLOATING SEARCH BAR (Like Volunteer App)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search Input Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.grey[700],
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search for a location...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 16,
                            ),
                          ),
                          onTap: () {
                            if (_searchResults.isNotEmpty) {
                              setState(() {
                                _showSearchResults = true;
                              });
                            }
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _showSearchResults = false;
                            });
                          },
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                // Search Results Dropdown
                if (_showSearchResults)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : _searchResults.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                'No locations found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final result = _searchResults[index];
                                return _buildSearchResultItem(
                                  result,
                                  index == _searchResults.length - 1,
                                );
                              },
                            ),
                          ),
                  ),
              ],
            ),
          ),

          // BOTTOM SECTION (My Location + Confirm)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Go to current location button
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _getCurrentLocation,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.my_location_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Location Details Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF1E88E5),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isLoadingAddress
                                      ? 'Locating...'
                                      : _locationName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (_locationAddress.isNotEmpty)
                                  Text(
                                    _locationAddress,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoadingAddress ? null : _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoadingAddress
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Confirm Location',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                      // Add safe area padding for bottom
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(Feature result, bool isLast) {
    final name = result.properties?.name ?? '';
    final parts = _formatAddress(result.properties).split(', ');
    // remove name from parts if present

    final subtitle = parts.join(', ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectSearchResult(result),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.north_west_rounded,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
