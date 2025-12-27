import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'requests_list_state.dart';

class RequestsListCubit extends Cubit<RequestsListState> {
  RequestsListCubit() : super(RequestsListInitial());

  String? _currentFilter;

  Future<void> loadRequests({String? statusFilter}) async {
    _currentFilter = statusFilter;
    emit(RequestsListLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null) {
        emit(RequestsListError(message: 'Please login to view requests'));
        return;
      }

      // Fetch donation requests
      final donationResponse = await http.get(
        Uri.parse('$kBaseUrl/public/donation/request/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (donationResponse.statusCode == 200) {
        final data = json.decode(donationResponse.body);
        final donationList = (data['message'] as List<dynamic>? ?? [])
            .map((e) => DonationRequest.fromJson(e as Map<String, dynamic>))
            .toList();

        // Apply filter if specified
        List<DonationRequest> filteredList;
        if (statusFilter == null || statusFilter == 'All') {
          filteredList = donationList;
        } else {
          filteredList = donationList
              .where(
                (r) => r.status.toLowerCase() == statusFilter.toLowerCase(),
              )
              .toList();
        }

        // Sort by createdAt (newest first)
        filteredList.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(2000);
          final bDate = b.createdAt ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });

        emit(
          RequestsListLoaded(
            donationRequests: filteredList,
            allDonationRequests: donationList,
          ),
        );
      } else if (donationResponse.statusCode == 401) {
        emit(
          RequestsListError(
            message: 'Session expired. Please login again.',
            statusCode: 401,
          ),
        );
      } else {
        emit(RequestsListError(message: 'Failed to load requests'));
      }
    } catch (e) {
      emit(RequestsListError(message: 'Network error: $e'));
    }
  }

  void filterByStatus(String status) {
    final currentState = state;
    if (currentState is RequestsListLoaded) {
      final allRequests = currentState.allDonationRequests;

      List<DonationRequest> filteredList;
      if (status == 'All') {
        filteredList = allRequests;
      } else {
        filteredList = allRequests
            .where((r) => r.status.toLowerCase() == status.toLowerCase())
            .toList();
      }

      emit(
        RequestsListLoaded(
          donationRequests: filteredList,
          allDonationRequests: allRequests,
        ),
      );
    }
  }

  void refresh() => loadRequests(statusFilter: _currentFilter);
}
