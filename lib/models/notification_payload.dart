/// Enum representing all supported notification types
enum NotificationType {
  // Aid request notifications
  aidRequestSubmitted,
  aidRequestAccepted,
  aidRequestRejected,
  aidRequestCompleted,
  aidRequestInProgress,

  // Donation request notifications
  donationRequestSubmitted,
  donationRequestAccepted,
  donationRequestRejected,
  donationRequestCompleted,
  donationRequestPartiallyFulfilled,

  // Alert notifications
  weatherAlert,
  disasterAlert,

  // Other notifications
  adminBroadcast,
  reliefCenterUpdate,
  systemNotification,

  // Unknown/fallback
  unknown,
}

/// Extension to convert string type to enum
extension NotificationTypeExtension on NotificationType {
  /// Convert notification type to backend string format
  String toBackendString() {
    switch (this) {
      case NotificationType.aidRequestSubmitted:
        return 'aid_request_submitted';
      case NotificationType.aidRequestAccepted:
        return 'aid_request_accepted';
      case NotificationType.aidRequestRejected:
        return 'aid_request_rejected';
      case NotificationType.aidRequestCompleted:
        return 'aid_request_completed';
      case NotificationType.aidRequestInProgress:
        return 'aid_request_in_progress';
      case NotificationType.donationRequestSubmitted:
        return 'donation_request_submitted';
      case NotificationType.donationRequestAccepted:
        return 'donation_request_accepted';
      case NotificationType.donationRequestRejected:
        return 'donation_request_rejected';
      case NotificationType.donationRequestCompleted:
        return 'donation_request_completed';
      case NotificationType.donationRequestPartiallyFulfilled:
        return 'donation_request_partially_fulfilled';
      case NotificationType.weatherAlert:
        return 'weather_alert';
      case NotificationType.disasterAlert:
        return 'disaster_alert';
      case NotificationType.adminBroadcast:
        return 'admin_broadcast';
      case NotificationType.reliefCenterUpdate:
        return 'relief_center_update';
      case NotificationType.systemNotification:
        return 'system_notification';
      case NotificationType.unknown:
        return 'unknown';
    }
  }

  /// Check if this notification type relates to aid requests
  bool get isAidRequest {
    return this == NotificationType.aidRequestSubmitted ||
        this == NotificationType.aidRequestAccepted ||
        this == NotificationType.aidRequestRejected ||
        this == NotificationType.aidRequestCompleted ||
        this == NotificationType.aidRequestInProgress;
  }

  /// Check if this notification type relates to donation requests
  bool get isDonationRequest {
    return this == NotificationType.donationRequestSubmitted ||
        this == NotificationType.donationRequestAccepted ||
        this == NotificationType.donationRequestRejected ||
        this == NotificationType.donationRequestCompleted ||
        this == NotificationType.donationRequestPartiallyFulfilled;
  }

  /// Check if this notification type is an alert
  bool get isAlert {
    return this == NotificationType.weatherAlert ||
        this == NotificationType.disasterAlert;
  }
}

/// Parse backend notification type string to enum
NotificationType parseNotificationType(String? type) {
  switch (type) {
    case 'aid_request_submitted':
      return NotificationType.aidRequestSubmitted;
    case 'aid_request_accepted':
      return NotificationType.aidRequestAccepted;
    case 'aid_request_rejected':
      return NotificationType.aidRequestRejected;
    case 'aid_request_completed':
      return NotificationType.aidRequestCompleted;
    case 'aid_request_in_progress':
      return NotificationType.aidRequestInProgress;
    case 'donation_request_submitted':
      return NotificationType.donationRequestSubmitted;
    case 'donation_request_accepted':
      return NotificationType.donationRequestAccepted;
    case 'donation_request_rejected':
      return NotificationType.donationRequestRejected;
    case 'donation_request_completed':
      return NotificationType.donationRequestCompleted;
    case 'donation_request_partially_fulfilled':
      return NotificationType.donationRequestPartiallyFulfilled;
    case 'weather_alert':
      return NotificationType.weatherAlert;
    case 'disaster_alert':
      return NotificationType.disasterAlert;
    case 'admin_broadcast':
      return NotificationType.adminBroadcast;
    case 'relief_center_update':
      return NotificationType.reliefCenterUpdate;
    case 'system_notification':
      return NotificationType.systemNotification;
    default:
      return NotificationType.unknown;
  }
}

/// Model representing a notification payload from FCM
class NotificationPayload {
  /// The type of notification
  final NotificationType type;

  /// The notification ID from backend (for marking as read)
  final String? notificationId;

  /// Aid request ID (for aid request notifications)
  final String? aidRequestId;

  /// Donation request ID (for donation request notifications)
  final String? donationRequestId;

  /// Portal donation ID (for portal donation notifications)
  final String? portalDonationId;

  /// Task ID (for volunteer task notifications - not used in public app)
  final String? taskId;

  /// Raw data map for any additional fields
  final Map<String, dynamic> rawData;

  NotificationPayload({
    required this.type,
    this.notificationId,
    this.aidRequestId,
    this.donationRequestId,
    this.portalDonationId,
    this.taskId,
    this.rawData = const {},
  });

  /// Create a payload from FCM data map
  factory NotificationPayload.fromMap(Map<String, dynamic> data) {
    return NotificationPayload(
      type: parseNotificationType(data['type'] as String?),
      notificationId: data['notificationId'] as String?,
      aidRequestId: data['aidRequestId'] as String?,
      donationRequestId: data['donationRequestId'] as String?,
      portalDonationId: data['portalDonationId'] as String?,
      taskId: data['taskId'] as String?,
      rawData: data,
    );
  }

  /// Create a payload from NotificationModel (for notification screen taps)
  factory NotificationPayload.fromNotificationModel(dynamic notification) {
    // Import the data from notification.data map + type
    final Map<String, dynamic> data = {};

    // Get the type
    final String typeStr = notification.type as String? ?? 'unknown';

    // Get the data map from notification
    if (notification.data != null && notification.data is Map) {
      data.addAll(Map<String, dynamic>.from(notification.data));
    }

    // Add type and notificationId
    data['type'] = typeStr;
    data['notificationId'] = notification.id;

    return NotificationPayload.fromMap(data);
  }

  /// Convert payload to map (for storage/serialization)
  Map<String, dynamic> toMap() {
    return {
      'type': type.toBackendString(),
      if (notificationId != null) 'notificationId': notificationId,
      if (aidRequestId != null) 'aidRequestId': aidRequestId,
      if (donationRequestId != null) 'donationRequestId': donationRequestId,
      if (portalDonationId != null) 'portalDonationId': portalDonationId,
      if (taskId != null) 'taskId': taskId,
      ...rawData,
    };
  }

  /// Get the target ID based on notification type
  String? get targetId {
    if (type.isAidRequest) return aidRequestId;
    if (type.isDonationRequest) return donationRequestId;
    return null;
  }

  /// Check if this payload has enough data to navigate to detail screen
  bool get canNavigateToDetail {
    if (type.isAidRequest && aidRequestId != null) return true;
    if (type.isDonationRequest && donationRequestId != null) return true;
    return false;
  }

  @override
  String toString() {
    return 'NotificationPayload(type: $type, aidRequestId: $aidRequestId, '
        'donationRequestId: $donationRequestId, notificationId: $notificationId)';
  }
}
