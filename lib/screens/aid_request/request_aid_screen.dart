import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/models/calamity_type.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/select_location.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/cubit/requests_list_cubit.dart';

class RequestAidScreen extends StatefulWidget {
  const RequestAidScreen({super.key});
  @override
  State<RequestAidScreen> createState() => _RequestAidState();
}

class _RequestAidState extends State<RequestAidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  List<CalamityType> _calamityTypes = [];
  CalamityType? _selectedCalamityType;
  bool _isLoadingTypes = true;
  bool _isSubmitting = false;
  String? _typesError;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
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
    debugPrint('=== IMAGE PICKER DEBUG ===');
    debugPrint('Source: ${source.name}');
    debugPrint('Starting image picker...');

    try {
      debugPrint('Calling _imagePicker.pickImage()...');
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512, // Reduced from 1024 to lower memory usage
        maxHeight: 512, // Reduced from 1024 to lower memory usage
        imageQuality: 50, // Reduced from 80 to lower memory usage
      );

      debugPrint('pickImage() completed');
      debugPrint('pickedFile: ${pickedFile?.path ?? 'null'}');

      if (pickedFile != null && mounted) {
        debugPrint('Setting selected image...');
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        debugPrint('Image set successfully');
      } else {
        debugPrint('No file picked or widget not mounted');
      }
    } on Exception catch (e, stackTrace) {
      debugPrint('=== IMAGE PICKER ERROR ===');
      debugPrint('Exception type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        if (source == ImageSource.camera) {
          _showSnackBar(
            'Camera error. Please check camera permissions.',
            isError: true,
          );
        } else {
          _showSnackBar('Failed to pick image from gallery', isError: true);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('=== IMAGE PICKER UNKNOWN ERROR ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        _showSnackBar('Unknown error picking image', isError: true);
      }
    }
    debugPrint('=== IMAGE PICKER END ===');
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

  Future<void> _submitRequest() async {
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
        _showSnackBar('Please login to submit request', isError: true);
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Use MultipartRequest to support file upload
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$kBaseUrl/public/aid/request/add'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['calamityType'] = _selectedCalamityType!.id!;
      request.fields['address[addressLine1]'] = _addressController.text.trim();

      // Add description if provided
      if (_descriptionController.text.trim().isNotEmpty) {
        request.fields['description'] = _descriptionController.text.trim();
      }

      // Add image file if selected
      if (_selectedImage != null) {
        // Determine the MIME type from the file extension
        final extension = _selectedImage!.path.split('.').last.toLowerCase();
        String mimeType;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          default:
            mimeType = 'image/jpeg'; // Default to jpeg
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _selectedImage!.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      debugPrint('Sending multipart request with fields: ${request.fields}');
      debugPrint(
        'Sending multipart request with files: ${request.files.map((f) => f.filename).toList()}',
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar('Aid request submitted successfully!');
        // Refresh the shared cubit to update home screen and requests list
        if (mounted) {
          try {
            context.read<RequestsListCubit>().loadRequests();
          } catch (e) {
            // Cubit may not be available if navigating from outside MainNavigation
            debugPrint('Could not refresh RequestsListCubit: $e');
          }
        }
        Navigator.pop(context);
      } else {
        final data = json.decode(response.body);
        _showSnackBar(
          data['message'] ?? 'Failed to submit request',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('Error submitting request: $e');
      _showSnackBar('Network error. Please try again.', isError: true);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildImagePicker(),
                        const SizedBox(height: 16),
                        _buildCalamityTypeDropdown(),
                        const SizedBox(height: 16),
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
                  'Request Aid',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Get emergency assistance',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.emergency, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.photo_camera, color: Color(0xFF1E88E5), size: 20),
                SizedBox(width: 8),
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1E88E5).withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_selectedImage!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Color(0xFF1E88E5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Camera or Gallery',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
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
          if (_isLoadingTypes)
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_typesError != null)
            Column(
              children: [
                Text(
                  _typesError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
                TextButton(
                  onPressed: _loadCalamityTypes,
                  child: const Text('Retry'),
                ),
              ],
            )
          else
            DropdownButtonFormField<CalamityType>(
              value: _selectedCalamityType,
              decoration: InputDecoration(
                hintText: 'Select calamity type',
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
                  vertical: 12,
                ),
              ),
              items: _calamityTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.calamityName ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCalamityType = value;
                });
              },
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SelectLocationScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.map,
                  color: Color(0xFF1E88E5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Location on Map',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      'Tap to choose your exact location',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF1E88E5),
              ),
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
        onPressed: _isSubmitting ? null : _submitRequest,
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
                  Icon(Icons.send, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'SUBMIT REQUEST',
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
}
