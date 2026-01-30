import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/models/notification_payload.dart';
import 'package:reliefflow_frontend_public_app/models/requests/aid_request.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';
import 'package:reliefflow_frontend_public_app/screens/notifications/notification_screen.dart';
import 'package:reliefflow_frontend_public_app/screens/notifications/cubit/notification_cubit.dart';
import 'package:reliefflow_frontend_public_app/screens/requests_list/requests_list_screen.dart';

/// Service for handling notification tap navigation
///
/// This router centralizes all notification-based navigation logic,
/// making it easy to add new notification types and their handlers.
class NotificationRouter {
  static final NotificationRouter _instance = NotificationRouter._internal();
  factory NotificationRouter() => _instance;
  NotificationRouter._internal();

  /// Global navigator key - must be set from main.dart
  GlobalKey<NavigatorState>? navigatorKey;

  /// Pending payload to handle after app initialization (from terminated state)
  NotificationPayload? _pendingPayload;

  /// Set pending payload (called when app opens from terminated state)
  void setPendingPayload(NotificationPayload payload) {
    _pendingPayload = payload;
    developer.log(
      'Pending notification payload set: $payload',
      name: 'NotificationRouter',
    );
  }

  /// Check and handle pending navigation (call after app is fully initialized)
  Future<void> handlePendingNavigation() async {
    if (_pendingPayload != null) {
      developer.log(
        'Processing pending notification: ${_pendingPayload!.type}',
        name: 'NotificationRouter',
      );
      final payload = _pendingPayload!;
      _pendingPayload = null;

      // Small delay to ensure navigation stack is ready
      await Future.delayed(const Duration(milliseconds: 500));
      await handleNotificationTap(payload);
    }
  }

  /// Handle notification tap - main entry point
  Future<void> handleNotificationTap(NotificationPayload payload) async {
    developer.log(
      'Handling notification tap: ${payload.type}',
      name: 'NotificationRouter',
    );

    final navigator = navigatorKey?.currentState;
    if (navigator == null) {
      developer.log(
        'Navigator not available, cannot handle notification tap',
        name: 'NotificationRouter',
      );
      return;
    }

    try {
      switch (payload.type) {
        // Aid request notifications - navigate to aid request tracking
        case NotificationType.aidRequestSubmitted:
        case NotificationType.aidRequestAccepted:
        case NotificationType.aidRequestRejected:
        case NotificationType.aidRequestCompleted:
        case NotificationType.aidRequestInProgress:
          await _navigateToAidRequestDetail(navigator, payload);
          break;

        // Donation request notifications - navigate to donation request tracking
        case NotificationType.donationRequestSubmitted:
        case NotificationType.donationRequestAccepted:
        case NotificationType.donationRequestRejected:
        case NotificationType.donationRequestCompleted:
        case NotificationType.donationRequestPartiallyFulfilled:
          await _navigateToDonationRequestDetail(navigator, payload);
          break;

        // Alert notifications - navigate to notifications screen
        case NotificationType.weatherAlert:
        case NotificationType.disasterAlert:
          _navigateToNotifications(navigator);
          break;

        // Broadcast and other notifications - navigate to notifications screen
        case NotificationType.adminBroadcast:
        case NotificationType.reliefCenterUpdate:
        case NotificationType.systemNotification:
        case NotificationType.unknown:
          _navigateToNotifications(navigator);
          break;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error handling notification tap: $e',
        name: 'NotificationRouter',
        error: e,
        stackTrace: stackTrace,
      );
      // Fallback to notifications screen
      _navigateToNotifications(navigator);
    }
  }

  /// Navigate to aid request detail/tracking screen
  Future<void> _navigateToAidRequestDetail(
    NavigatorState navigator,
    NotificationPayload payload,
  ) async {
    final requestId = payload.aidRequestId;

    if (requestId == null || requestId.isEmpty) {
      developer.log(
        'No aidRequestId in payload, falling back to notifications',
        name: 'NotificationRouter',
      );
      _navigateToNotifications(navigator);
      return;
    }

    developer.log(
      'Navigating to aid request: $requestId',
      name: 'NotificationRouter',
    );

    // Fetch the aid request details
    final request = await _fetchAidRequest(requestId);

    if (request != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => AidRequestTrackingScreen(request: request),
        ),
      );
    } else {
      developer.log(
        'Failed to fetch aid request, falling back to notifications',
        name: 'NotificationRouter',
      );
      _navigateToNotifications(navigator);
    }
  }

  /// Navigate to donation request detail/tracking screen
  Future<void> _navigateToDonationRequestDetail(
    NavigatorState navigator,
    NotificationPayload payload,
  ) async {
    final requestId = payload.donationRequestId;

    if (requestId == null || requestId.isEmpty) {
      developer.log(
        'No donationRequestId in payload, falling back to notifications',
        name: 'NotificationRouter',
      );
      _navigateToNotifications(navigator);
      return;
    }

    developer.log(
      'Navigating to donation request: $requestId',
      name: 'NotificationRouter',
    );

    // Fetch the donation request details
    final request = await _fetchDonationRequest(requestId);

    if (request != null) {
      final isCash = request.donationType.toLowerCase() == 'cash';
      navigator.push(
        MaterialPageRoute(
          builder: (_) => DonationRequestTrackingScreen(
            request: request,
            isCash: isCash,
          ),
        ),
      );
    } else {
      developer.log(
        'Failed to fetch donation request, falling back to notifications',
        name: 'NotificationRouter',
      );
      _navigateToNotifications(navigator);
    }
  }

  /// Navigate to notifications screen
  void _navigateToNotifications(NavigatorState navigator) {
    developer.log(
      'Navigating to notifications screen',
      name: 'NotificationRouter',
    );
    navigator.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => NotificationCubit()..loadNotifications(),
          child: const NotificationScreen(),
        ),
      ),
    );
  }

  /// Fetch aid request by ID
  Future<AidRequest?> _fetchAidRequest(String requestId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null) {
        developer.log(
          'No auth token available',
          name: 'NotificationRouter',
        );
        return null;
      }

      // First try to get user's own requests
      final response = await http.get(
        Uri.parse('$kBaseUrl/public/aid/request/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final requests = (data['message'] as List<dynamic>? ?? [])
            .map((e) => AidRequest.fromJson(e as Map<String, dynamic>))
            .toList();

        // Find the specific request
        final request = requests.where((r) => r.id == requestId).firstOrNull;
        if (request != null) {
          return request;
        }
      }

      developer.log(
        'Aid request $requestId not found in user requests',
        name: 'NotificationRouter',
      );
      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching aid request: $e',
        name: 'NotificationRouter',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Fetch donation request by ID
  Future<DonationRequest?> _fetchDonationRequest(String requestId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      if (token == null) {
        developer.log(
          'No auth token available',
          name: 'NotificationRouter',
        );
        return null;
      }

      // First try to get user's own requests
      final response = await http.get(
        Uri.parse('$kBaseUrl/public/donation/request/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final requests = (data['message'] as List<dynamic>? ?? [])
            .map((e) => DonationRequest.fromJson(e as Map<String, dynamic>))
            .toList();

        // Find the specific request
        final request = requests.where((r) => r.id == requestId).firstOrNull;
        if (request != null) {
          return request;
        }
      }

      developer.log(
        'Donation request $requestId not found in user requests',
        name: 'NotificationRouter',
      );
      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching donation request: $e',
        name: 'NotificationRouter',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
