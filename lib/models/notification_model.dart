/// Model representing a notification from the backend
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? recipientId;
  final String type;
  final String targetUserType;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.recipientId,
    required this.type,
    required this.targetUserType,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      recipientId: json['recipientId'],
      type: json['type'] ?? 'admin_broadcast',
      targetUserType: json['targetUserType'] ?? 'all',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'recipientId': recipientId,
      'type': type,
      'targetUserType': targetUserType,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Returns the notification type as a user-friendly string
  String get typeLabel {
    switch (type) {
      // Aid request notifications
      case 'aid_request_submitted':
        return 'Request Submitted';
      case 'aid_request_accepted':
        return 'Request Accepted';
      case 'aid_request_rejected':
        return 'Request Rejected';
      case 'aid_request_completed':
        return 'Request Completed';
      case 'aid_request_in_progress':
        return 'In Progress';

      // Donation request notifications
      case 'donation_request_submitted':
        return 'Donation Submitted';
      case 'donation_request_accepted':
        return 'Donation Accepted';
      case 'donation_request_rejected':
        return 'Donation Rejected';
      case 'donation_request_completed':
        return 'Donation Completed';
      case 'donation_request_partially_fulfilled':
        return 'Partially Fulfilled';

      // Alert notifications
      case 'weather_alert':
        return 'Weather Alert';
      case 'disaster_alert':
        return 'Disaster Alert';

      // Other notifications
      case 'admin_broadcast':
        return 'Announcement';
      case 'relief_center_update':
        return 'Relief Center Update';
      case 'system_notification':
        return 'System';

      default:
        return 'Notification';
    }
  }

  /// Returns an appropriate icon for the notification type
  String get iconName {
    switch (type) {
      case 'aid_request_submitted':
      case 'aid_request_accepted':
      case 'aid_request_rejected':
      case 'aid_request_completed':
      case 'aid_request_in_progress':
        return 'emergency';

      case 'donation_request_submitted':
      case 'donation_request_accepted':
      case 'donation_request_rejected':
      case 'donation_request_completed':
      case 'donation_request_partially_fulfilled':
        return 'volunteer_activism';

      case 'weather_alert':
        return 'thunderstorm';
      case 'disaster_alert':
        return 'warning';

      case 'relief_center_update':
        return 'location_on';

      case 'admin_broadcast':
        return 'campaign';

      default:
        return 'notifications';
    }
  }

  /// Returns true if this is an alert-type notification
  bool get isAlert {
    return type == 'weather_alert' || type == 'disaster_alert';
  }

  /// Returns true if this is a request status notification
  bool get isRequestStatus {
    return type.startsWith('aid_request_') ||
        type.startsWith('donation_request_');
  }

  /// Returns a relative time string (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
