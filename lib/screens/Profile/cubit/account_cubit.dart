import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/models/user/user_data_response/user.dart';
import 'package:reliefflow_frontend_public_app/models/user/user_data_response/user_data_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(AccountInitial());

  final _url = Uri.parse('$kBaseUrl/public/profile');

  void loadAccountDetails() async {
    emit(AccountLoading());

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kTokenStorageKey);

    if (token == null || token.isEmpty) {
      emit(AccountError(message: 'Authentication token not found.'));
      return;
    }

    try {
      final response = await get(
        _url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserDataResponse.fromJson(data);
        if (user.data == null) {
          emit(AccountError(message: 'Unexpected error occurred.'));
          return;
        }
        emit(AccountLoaded(user: user.data!));
      } else if (response.statusCode == 401) {
        emit(AccountError(message: 'Unauthorized access.', statusCode: 401));
      } else {
        emit(AccountError(message: 'Failed to load account details.'));
      }
    } catch (e) {
      emit(
        AccountError(
          message: 'An error occurred while loading account details.',
        ),
      );
    }
  }

  void editAccountDetails({
    required String name,
    required String email,
    required String address,
    required String phoneNumber,
    File? profileImage,
  }) async {
    emit(AccountLoading());

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kTokenStorageKey);

    if (token == null || token.isEmpty) {
      emit(AccountError(message: 'Authentication token not found.'));
      return;
    }

    try {
      // Use multipart request if there's an image to upload
      if (profileImage != null) {
        var request = MultipartRequest(
          'PUT',
          Uri.parse('$kBaseUrl/public/update'),
        );

        request.headers.addAll({
          'Authorization': 'Bearer $token',
        });

        // Add text fields
        request.fields['name'] = name;
        request.fields['email'] = email;
        request.fields['address'] = address;
        request.fields['phoneNumber'] = phoneNumber;

        // Add image file
        var multipartFile = await MultipartFile.fromPath(
          'profile_image',
          profileImage.path,
        );
        request.files.add(multipartFile);

        var streamedResponse = await request.send();
        var response = await Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final parsedBody = jsonDecode(response.body) as Map<String, dynamic>;
          final user = User.fromJson(parsedBody['data']);
          emit(AccountLoaded(user: user));
        } else if (response.statusCode == 401) {
          emit(AccountError(message: 'Unauthorized access.', statusCode: 401));
        } else {
          emit(AccountError(message: 'Failed to update account details.'));
        }
      } else {
        // Regular JSON request without image
        var body = jsonEncode({
          "email": email,
          "name": name,
          "address": address,
          "phoneNumber": phoneNumber,
        });

        final response = await put(
          Uri.parse('$kBaseUrl/public/update'),
          headers: {
            "Accept": "/",
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: body,
        );

        if (response.statusCode == 200) {
          final parsedBody = jsonDecode(response.body) as Map<String, dynamic>;
          final user = User.fromJson(parsedBody['data']);
          emit(AccountLoaded(user: user));
        } else if (response.statusCode == 401) {
          emit(AccountError(message: 'Unauthorized access.', statusCode: 401));
        } else {
          emit(AccountError(message: 'Failed to update account details.'));
        }
      }
    } catch (e) {
      emit(
        AccountError(
          message: 'An error occurred while updating account details.',
        ),
      );
    }
  }
}
