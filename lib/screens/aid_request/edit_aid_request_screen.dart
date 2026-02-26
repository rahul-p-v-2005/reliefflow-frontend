import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/models/calamity_type.dart';
import 'package:reliefflow_frontend_public_app/models/requests/aid_request.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/select_current_location.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/feature.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/geometry.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/properties.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/location_search_response.dart';
import 'package:reliefflow_frontend_public_app/components/shared/utils/image_utils.dart';

class EditAidRequestScreen extends StatefulWidget {
  final AidRequest request;
  final VoidCallback? onUpdated;

  const EditAidRequestScreen({
    super.key,
    required this.request,
    this.onUpdated,
  });

  @override
  State<EditAidRequestScreen> createState() => _EditAidRequestState();
}

class _EditAidRequestState extends State<EditAidRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  List<CalamityType> _calamityTypes = [];
  CalamityType? _selectedCalamityType;
  bool _isLoadingTypes = true;
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  String? _typesError;
  String _priority = 'medium';
  File? _selectedImage;
  Feature? _selectedLocationFeature;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing data
    _descriptionController.text = widget.request.description ?? '';
    _addressController.text = widget.request.address;
    _priority = widget.request.priority;

    // Pre-populate location if available - reverse geocode to get actual name
    if (widget.request.location != null) {
      _initializeLocationFromCoordinates();
    }

    // Debug: Check imageUrl
    print('=== EDIT AID REQUEST DEBUG ===');
    print('Request ID: ${widget.request.id}');
    print('ImageUrl: ${widget.request.imageUrl}');
    print('ImageUrl is null: ${widget.request.imageUrl == null}');
    if (widget.request.imageUrl != null) {
      print(
        'Full image URL: ${ImageUtils.getImageUrl(widget.request.imageUrl!)}',
      );
    }

    _loadCalamityTypes();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCalamityTypes() async {
    setState(() {
      _isLoadingTypes = true;
      _typesError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$kBaseUrl/public/calamity-types'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = (data['message'] as List<dynamic>? ?? [])
            .map((e) => CalamityType.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _calamityTypes = list;
          _isLoadingTypes = false;
          // Pre-select the existing calamity type
          _selectedCalamityType = list.firstWhere(
            (type) => type.id == widget.request.calamityType,
            orElse: () => list.first,
          );
        });
      } else {
        setState(() {
          _isLoadingTypes = false;
          _typesError = 'Failed to load calamity types';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingTypes = false;
        _typesError = 'Network error';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!mounted) return;

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 50,
      );

      if (!mounted) return;

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to pick image', isError: true);
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF1E88E5)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E88E5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCalamityType == null) {
      _showSnackBar('Please select a calamity type', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null) {
        _showSnackBar('Please login again', isError: true);
        setState(() => _isSubmitting = false);
        return;
      }

      // Build the address object
      final addressParts = _addressController.text.split(',');
      final address = {
        'addressLine1': addressParts.isNotEmpty ? addressParts[0].trim() : '',
        'addressLine2': addressParts.length > 1 ? addressParts[1].trim() : '',
        'addressLine3': addressParts.length > 2 ? addressParts[2].trim() : '',
        'pinCode': addressParts.length > 3
            ? int.tryParse(addressParts[3].replaceAll(RegExp(r'[^0-9]'), '')) ??
                  0
            : 0,
      };

      // Build location if available
      Map<String, dynamic>? location;
      if (_selectedLocationFeature != null) {
        final coords = _selectedLocationFeature!.geometry?.coordinates;
        if (coords != null && coords.length >= 2) {
          location = {
            'type': 'Point',
            'coordinates': [coords[0], coords[1]],
          };
        }
      }

      // Use multipart request to handle file upload
      final uri = Uri.parse(
        '$kBaseUrl/public/aid/request/${widget.request.id}',
      );
      final request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields['calamityType'] = _selectedCalamityType!.id ?? '';
      request.fields['priority'] = _priority;
      request.fields['address'] = jsonEncode(address);
      request.fields['description'] = _descriptionController.text;
      if (location != null) {
        request.fields['location'] = jsonEncode(location);
      }

      // Add image if selected
      if (_selectedImage != null) {
        final imageFile = await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(imageFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnackBar('Aid request updated successfully');
        widget.onUpdated?.call();
        Navigator.pop(
          context,
          true,
        ); // Return true to indicate successful update
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(
          data['message'] ?? 'Failed to update request',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Network error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  IconData _getCalamityIcon(String? name) {
    if (name == null) return Icons.emergency_outlined;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('flood')) return Icons.water_drop_outlined;
    if (lowerName.contains('fire')) return Icons.local_fire_department_outlined;
    if (lowerName.contains('earthquake')) return Icons.landscape_outlined;
    if (lowerName.contains('storm') || lowerName.contains('cyclone')) {
      return Icons.cyclone_outlined;
    }
    if (lowerName.contains('drought')) return Icons.wb_sunny_outlined;
    if (lowerName.contains('tsunami')) return Icons.waves_outlined;
    if (lowerName.contains('landslide')) return Icons.terrain_outlined;
    if (lowerName.contains('epidemic') || lowerName.contains('virus')) {
      return Icons.coronavirus_outlined;
    }
    return Icons.emergency_outlined;
  }

  String _formatAddress(Properties? props) {
    if (props == null) return '';
    final parts = <String>[];
    if (props.locality?.isNotEmpty == true) parts.add(props.locality!);
    if (props.city?.isNotEmpty == true) parts.add(props.city!);
    final district = props.district ?? props.county;
    if (district?.isNotEmpty == true) parts.add(district!);
    if (props.state?.isNotEmpty == true) parts.add(props.state!);
    return parts.join(', ');
  }

  /// Initialize location feature by reverse geocoding saved coordinates
  Future<void> _initializeLocationFromCoordinates() async {
    final location = widget.request.location;
    if (location == null) return;

    final coordinates = location['coordinates'] as List<dynamic>?;
    if (coordinates == null || coordinates.length < 2) return;

    final lon = (coordinates[0] as num).toDouble();
    final lat = (coordinates[1] as num).toDouble();

    // Create initial feature with coordinates (name will be updated after geocoding)
    _selectedLocationFeature = Feature(
      type: 'Feature',
      geometry: Geometry(
        type: 'Point',
        coordinates: [lon, lat],
      ),
      properties: Properties(
        name: 'Loading location...',
      ),
    );

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Reverse geocode to get actual location name
      final url = Uri.parse(
        'https://photon.komoot.io/reverse?lon=$lon&lat=$lat',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'ReliefflowApp/1.0'},
      );

      if (response.statusCode == 200 && mounted) {
        final data = LocationSearchResponse.fromJson(jsonDecode(response.body));

        if (data.features != null && data.features!.isNotEmpty) {
          final feature = data.features!.first;
          setState(() {
            _selectedLocationFeature = Feature(
              type: 'Feature',
              geometry: Geometry(
                type: 'Point',
                coordinates: [lon, lat],
              ),
              properties: feature.properties,
            );
          });
        } else {
          // No geocoding result - show coordinates
          setState(() {
            _selectedLocationFeature = Feature(
              type: 'Feature',
              geometry: Geometry(
                type: 'Point',
                coordinates: [lon, lat],
              ),
              properties: Properties(
                name: '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}',
              ),
            );
          });
        }
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
      // Fallback to coordinates on error
      if (mounted) {
        setState(() {
          _selectedLocationFeature = Feature(
            type: 'Feature',
            geometry: Geometry(
              type: 'Point',
              coordinates: [lon, lat],
            ),
            properties: Properties(
              name: '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}',
            ),
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoadingTypes
                    ? const Center(child: CircularProgressIndicator())
                    : _typesError != null
                    ? _buildErrorState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildInfoBanner(),
                              const SizedBox(height: 16),
                              _buildImagePicker(),
                              const SizedBox(height: 16),
                              _buildCalamityTypeDropdown(),
                              const SizedBox(height: 16),
                              // _buildPriorityDropdown(),
                              // const SizedBox(height: 16),
                              _buildDescriptionField(),
                              const SizedBox(height: 16),
                              _buildAddressField(),
                              const SizedBox(height: 16),
                              _buildLocationPicker(),
                              const SizedBox(height: 24),
                              _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Aid Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Update your request details',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_note, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You can edit this request until an admin reviews it.',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _typesError!,
            style: TextStyle(color: Colors.red[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadCalamityTypes,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasExistingImage =
        widget.request.imageUrl != null &&
        widget.request.imageUrl!.isNotEmpty &&
        _selectedImage == null;
    final hasNewImage = _selectedImage != null;
    final hasAnyImage = hasExistingImage || hasNewImage;

    // Debug output
    print(
      'hasExistingImage: $hasExistingImage, imageUrl: ${widget.request.imageUrl}',
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.photo_camera,
                  color: Color(0xFF1E88E5),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Photo Evidence (Optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                if (hasAnyImage)
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 14, color: Color(0xFF1E88E5)),
                          SizedBox(width: 4),
                          Text(
                            'Change',
                            style: TextStyle(
                              color: Color(0xFF1E88E5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: hasAnyImage
                ? _buildImagePreview(hasNewImage, hasExistingImage)
                : _buildImagePickerButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(bool hasNewImage, bool hasExistingImage) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(hasNewImage, hasExistingImage),
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasNewImage)
                Image.file(_selectedImage!, fit: BoxFit.cover)
              else if (hasExistingImage)
                Image.network(
                  ImageUtils.getImageUrl(widget.request.imageUrl!),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        color: const Color(0xFF1E88E5),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _buildImageError(),
                ),
              // Zoom indicator icon
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              // Gradient overlay at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasNewImage ? Icons.photo_library : Icons.cloud_done,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasNewImage
                            ? 'New photo selected'
                            : 'Previously uploaded',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (hasNewImage)
                        GestureDetector(
                          onTap: () => setState(() => _selectedImage = null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Remove',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(bool hasNewImage, bool hasExistingImage) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: hasNewImage
                    ? Image.file(_selectedImage!)
                    : hasExistingImage
                    ? Image.network(
                        ImageUtils.getImageUrl(widget.request.imageUrl!),
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5).withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF1E88E5).withOpacity(0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_a_photo,
                size: 28,
                color: Color(0xFF1E88E5),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add Photo',
              style: TextStyle(
                color: Color(0xFF1E88E5),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Camera or Gallery',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCalamityTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF1E88E5),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Calamity Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CalamityType>(
            initialValue: _selectedCalamityType,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            dropdownColor: Colors.white,
            menuMaxHeight: 250,
            decoration: InputDecoration(
              hintText: 'Select calamity type',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1E88E5),
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: _calamityTypes.map((type) {
              final icon = _getCalamityIcon(type.calamityName);
              return DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: const Color(0xFF1E88E5)),
                    const SizedBox(width: 12),
                    Text(
                      type.calamityName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCalamityType = value),
            validator: (value) => value == null ? 'Please select a type' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: Color(0xFF1E88E5), size: 20),
              SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Describe your situation and what help you need...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1E88E5)),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFF1E88E5), size: 20),
              SizedBox(width: 8),
              Text(
                'Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an address';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter your address',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1E88E5)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          FocusScope.of(context).unfocus();
          final result = await Navigator.of(context).push<Feature>(
            MaterialPageRoute(
              builder: (context) => SelectCurrentLocationScreen(
                preselectedLocation: _selectedLocationFeature,
              ),
            ),
          );
          if (result != null) {
            setState(() {
              _selectedLocationFeature = result;
              if (_addressController.text.isEmpty &&
                  result.properties?.name != null) {
                _addressController.text = result.properties!.name!;
              }
            });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _selectedLocationFeature != null
                      ? Colors.red.withOpacity(0.1)
                      : const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on,
                  color: _selectedLocationFeature != null
                      ? Colors.red
                      : const Color(0xFF1E88E5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoadingLocation)
                      Row(
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Loading location...',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        _selectedLocationFeature?.properties?.name ??
                            'Select Location on Map',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                    if (_selectedLocationFeature != null && !_isLoadingLocation)
                      Text(
                        _formatAddress(_selectedLocationFeature!.properties),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (!_isLoadingLocation)
                      Text(
                        'Tap to choose your exact location',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (_isLoadingLocation)
                const SizedBox(width: 24)
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'UPDATE REQUEST',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Priority',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[700]!, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'low',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Low Priority'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'medium',
                child: Row(
                  children: [
                    Icon(Icons.remove, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Medium Priority'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'high',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('High Priority'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _priority = value);
              }
            },
          ),
        ],
      ),
    );
  }
}
