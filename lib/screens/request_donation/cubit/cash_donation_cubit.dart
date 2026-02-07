import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'cash_donation_state.dart';

class CashDonationCubit extends Cubit<CashDonationState> {
  CashDonationCubit() : super(const CashDonationState());

  final ImagePicker _imagePicker = ImagePicker();

  void updateTitle(String value) => emit(state.copyWith(title: value));
  void updateDescription(String value) =>
      emit(state.copyWith(description: value));
  void updateAmount(String value) => emit(state.copyWith(amount: value));
  void updateUpiId(String value) => emit(state.copyWith(upiId: value));

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
          errorMessage: 'Please fill all required fields correctly',
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

      final url = '$kBaseUrl/public/donation/request/add';
      log('=== DONATION REQUEST DEBUG ===');
      log('URL: $url');
      log('Token: ${token.substring(0, 20)}...');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['title'] = state.title;
      request.fields['description'] = state.description;
      request.fields['donationType'] = 'cash';
      request.fields['amount'] = state.amount;
      request.fields['upiNumber'] = state.upiId;
      if (state.deadline != null) {
        request.fields['deadline'] = state.deadline!.toIso8601String();
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

      log('Sending Multipart Request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Response Status: ${response.statusCode}');
      log('Response Headers: ${response.headers}');
      log('Response Body: ${response.body}');
      log('=== END DEBUG ===');

      if (response.statusCode == 201) {
        emit(state.copyWith(status: DonationSubmitStatus.success));
        return true;
      } else {
        String errorMessage = 'Failed to submit request';
        try {
          final data = json.decode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (e) {
          log('JSON decode error: $e');
          errorMessage =
              'Server error (${response.statusCode}): ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}';
        }
        emit(
          state.copyWith(
            status: DonationSubmitStatus.error,
            errorMessage: errorMessage,
          ),
        );
        return false;
      }
    } catch (e, stack) {
      log('Exception: $e');
      log('Stack: $stack');
      emit(
        state.copyWith(
          status: DonationSubmitStatus.error,
          errorMessage: 'Error: $e',
        ),
      );
      return false;
    }
  }

  void reset() => emit(const CashDonationState());
}
