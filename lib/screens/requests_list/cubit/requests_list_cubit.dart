import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';
import 'package:reliefflow_frontend_public_app/models/requests/aid_request.dart';
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

      // Fetch both donation and aid requests in parallel
      final results = await Future.wait([
        http.get(
          Uri.parse('$kBaseUrl/public/donation/request/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        http.get(
          Uri.parse('$kBaseUrl/public/aid/request/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      ]);

      final donationResponse = results[0];
      final aidResponse = results[1];

      log(donationResponse.body);
      log(aidResponse.body);

      // Check for auth errors
      if (donationResponse.statusCode == 401 || aidResponse.statusCode == 401) {
        emit(
          RequestsListError(
            message: 'Session expired. Please login again.',
            statusCode: 401,
          ),
        );
        return;
      }

      // Parse donation requests
      List<DonationRequest> donationList = [];
      if (donationResponse.statusCode == 200) {
        final data = json.decode(donationResponse.body);
        donationList = (data['message'] as List<dynamic>? ?? [])
            .map((e) => DonationRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Parse aid requests
      List<AidRequest> aidList = [];
      if (aidResponse.statusCode == 200) {
        final data = json.decode(aidResponse.body);

        // Debug logging for aid requests
        final messageList = data['message'] as List<dynamic>? ?? [];

        // if (messageList.isNotEmpty) {
        //   final firstItem = messageList.first as Map<String, dynamic>;
        //   // if (firstItem['calamityType'] is Map) {
        //   //   final calType = firstItem['calamityType'] as Map;
        //   // }
        // }

        aidList = messageList
            .map((e) => AidRequest.fromJson(e as Map<String, dynamic>))
            .toList();

        log('Parsed aidList length: ${aidList.length}');
        if (aidList.isNotEmpty) {
          log('First parsed aid request:');
          log('  id: ${aidList.first.id}');
          log('  calamityTypeName: ${aidList.first.calamityTypeName}');
          log('  createdAt: ${aidList.first.createdAt}');
          log('  status: ${aidList.first.status}');
        }
      }

      // Apply status filter
      List<DonationRequest> filteredDonationList;
      List<AidRequest> filteredAidList;

      if (statusFilter == null || statusFilter == 'All') {
        filteredDonationList = donationList;
        filteredAidList = aidList;
      } else {
        filteredDonationList = donationList
            .where((r) => r.status.toLowerCase() == statusFilter.toLowerCase())
            .toList();
        filteredAidList = aidList
            .where((r) => r.status.toLowerCase() == statusFilter.toLowerCase())
            .toList();
      }

      // Sort by createdAt (newest first)
      filteredDonationList.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      filteredAidList.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      emit(
        RequestsListLoaded(
          donationRequests: filteredDonationList,
          allDonationRequests: donationList,
          aidRequests: filteredAidList,
          allAidRequests: aidList,
        ),
      );
    } catch (e) {
      emit(RequestsListError(message: 'Network error: $e'));
    }
  }

  void filterByStatus(String status) {
    final currentState = state;
    if (currentState is RequestsListLoaded) {
      final allDonationRequests = currentState.allDonationRequests;
      final allAidRequests = currentState.allAidRequests;

      List<DonationRequest> filteredDonationList;
      List<AidRequest> filteredAidList;

      if (status == 'All') {
        filteredDonationList = allDonationRequests;
        filteredAidList = allAidRequests;
      } else {
        filteredDonationList = allDonationRequests
            .where((r) => r.status.toLowerCase() == status.toLowerCase())
            .toList();
        filteredAidList = allAidRequests
            .where((r) => r.status.toLowerCase() == status.toLowerCase())
            .toList();
      }

      emit(
        RequestsListLoaded(
          donationRequests: filteredDonationList,
          allDonationRequests: allDonationRequests,
          aidRequests: filteredAidList,
          allAidRequests: allAidRequests,
        ),
      );
    }
  }

  void refresh() => loadRequests(statusFilter: _currentFilter);
}
