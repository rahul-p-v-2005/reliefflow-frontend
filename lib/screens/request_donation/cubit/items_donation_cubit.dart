import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/feature.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item.dart';
import 'items_donation_state.dart';

class ItemsDonationCubit extends Cubit<ItemsDonationState> {
  ItemsDonationCubit() : super(const ItemsDonationState());

  final ImagePicker _imagePicker = ImagePicker();

  void updateTitle(String value) => emit(state.copyWith(title: value));
  void updateDescription(String value) =>
      emit(state.copyWith(description: value));

  void addItem(ItemRequestItem item) {
    emit(state.copyWith(items: [...state.items, item]));
  }

  void removeItem(int index) {
    final items = [...state.items];
    items.removeAt(index);
    emit(state.copyWith(items: items));
  }

  void setLocation(Feature? location) {
    if (location == null) {
      emit(state.copyWith(clearLocation: true));
    } else {
      emit(state.copyWith(location: location));
    }
  }

  void setDeadline(DateTime? date) {
    if (date == null) {
      emit(state.copyWith(clearDeadline: true));
    } else {
      emit(state.copyWith(deadline: date));
    }
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> picked = await _imagePicker.pickMultiImage();
      if (picked.isNotEmpty) {
        final newImages = [...state.images, ...picked.map((x) => File(x.path))];
        emit(state.copyWith(images: newImages));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to pick images'));
    }
  }

  void removeImage(int index) {
    final images = [...state.images];
    images.removeAt(index);
    emit(state.copyWith(images: images));
  }

  void clearError() => emit(state.copyWith(clearError: true));

  Future<bool> submit() async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: DonationSubmitStatus.error,
          errorMessage:
              'Please fill title, description, and add at least one item',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(status: DonationSubmitStatus.loading, clearError: true),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null) {
        emit(
          state.copyWith(
            status: DonationSubmitStatus.error,
            errorMessage: 'Please login to submit a request',
          ),
        );
        return false;
      }

      final itemDetails = state.items
          .map(
            (item) => {
              'category': item.category.categoryName.toLowerCase(),
              'description': item.description,
              'quantity': item.quantity,
            },
          )
          .toList();

      // Create MultipartRequest
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$kBaseUrl/public/donation/request/add'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['title'] = state.title;
      request.fields['description'] = state.description;
      request.fields['donationType'] = 'item';
      if (state.deadline != null) {
        request.fields['deadline'] = state.deadline!.toIso8601String();
      }

      // Add complex objects as JSON strings
      request.fields['itemDetails'] = json.encode(itemDetails);

      // Add location if selected
      if (state.location != null) {
        final coords = state.location!.geometry?.coordinates;
        if (coords != null && coords.length >= 2) {
          final locationData = {
            'type': 'Point',
            'coordinates': [coords[0], coords[1]],
          };
          request.fields['location'] = json.encode(locationData);
        }

        // Add address details if available
        if (state.location!.properties != null) {
          final props = state.location!.properties!;
          final addressData = {
            'addressLine1': props.name,
            'city': props.city ?? props.locality,
            'state': props.state,
            'pinCode': props.postcode,
          };
          // Filter out null values
          addressData.removeWhere((key, value) => value == null);

          if (addressData.isNotEmpty) {
            request.fields['address'] = json.encode(addressData);
          }
        }
      }

      // Add images
      for (final imageFile in state.images) {
        // Determine mime type (fallback to jpeg)
        final extension = imageFile.path.split('.').last.toLowerCase();
        String mimeType;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          default:
            mimeType = 'image/jpeg';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'proofImages',
            imageFile.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        emit(state.copyWith(status: DonationSubmitStatus.success));
        return true;
      } else {
        final data = json.decode(response.body);
        emit(
          state.copyWith(
            status: DonationSubmitStatus.error,
            errorMessage: data['message'] ?? 'Failed to submit request',
          ),
        );
        return false;
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DonationSubmitStatus.error,
          errorMessage: 'Error: $e',
        ),
      );
      return false;
    }
  }

  void reset() => emit(const ItemsDonationState());
}
