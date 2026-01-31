import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reliefflow_frontend_public_app/models/notification_model.dart';
import 'package:reliefflow_frontend_public_app/models/notification_payload.dart';
import 'package:reliefflow_frontend_public_app/services/notification_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom sheet to display full notification details
/// Used for notifications that don't navigate to a specific screen
/// (alerts, broadcasts, system notifications, etc.)
class NotificationDetailBottomSheet extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailBottomSheet({
    super.key,
    required this.notification,
  });

  /// Show the bottom sheet
  static Future<void> show(
    BuildContext context,
    NotificationModel notification,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationDetailBottomSheet(
        notification: notification,
      ),
    );
  }

  // Helper getters for volunteer info from notification data
  String? get _volunteerName => notification.data['volunteerName'] as String?;
  String? get _volunteerPhone => notification.data['volunteerPhone'] as String?;
  String? get _volunteerSkill => notification.data['volunteerSkill'] as String?;
  String? get _aidRequestId => notification.data['aidRequestId'] as String?;
  String? get _donationRequestId =>
      notification.data['donationRequestId'] as String?;

  bool get _hasVolunteerInfo =>
      _volunteerName != null || _volunteerPhone != null;
  bool get _canTrackRequest =>
      _aidRequestId != null || _donationRequestId != null;

  @override
  Widget build(BuildContext context) {
    final type = parseNotificationType(notification.type);
    final color = _getTypeColor(type);
    final icon = _getTypeIcon(type);

    return Container(
      margin: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Scrollable content area
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon and type
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Icon container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            notification.typeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Body
                        Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification.timeAgo,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Volunteer info section (if available)
                  if (_hasVolunteerInfo) ...[
                    Divider(height: 1, color: Colors.grey[200]),
                    _buildVolunteerInfoSection(context, color),
                  ],
                ],
              ),
            ),
          ),
          // Divider
          Divider(height: 1, color: Colors.grey[200]),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Track Request button (if we have request ID)
                if (_canTrackRequest) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _trackRequest(context),
                      icon: const Icon(Icons.track_changes, size: 18),
                      label: const Text(
                        'Track Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Dismiss button as secondary
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Just the "Got it" button if no tracking available
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Got it',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Extra padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Build the volunteer information section
  Widget _buildVolunteerInfoSection(BuildContext context, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                Icons.person,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Assigned Volunteer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Volunteer card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                // Volunteer name
                if (_volunteerName != null)
                  _buildInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Name',
                    value: _volunteerName!,
                  ),
                // Volunteer skill/role
                if (_volunteerSkill != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.work_outline,
                    label: 'Role',
                    value: _formatSkill(_volunteerSkill!),
                  ),
                ],
                // Volunteer phone with call button
                if (_volunteerPhone != null) ...[
                  const SizedBox(height: 12),
                  _buildPhoneRow(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.phone_outlined, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          'Phone: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            _volunteerPhone!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        // Call button
        SizedBox(
          height: 32,
          child: OutlinedButton.icon(
            onPressed: () => _makePhoneCall(_volunteerPhone!),
            icon: const Icon(Icons.call, size: 14),
            label: const Text('Call', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Copy button
        SizedBox(
          height: 32,
          width: 32,
          child: IconButton(
            onPressed: () => _copyToClipboard(context, _volunteerPhone!),
            icon: const Icon(Icons.copy, size: 14),
            style: IconButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: EdgeInsets.zero,
            ),
            tooltip: 'Copy number',
          ),
        ),
      ],
    );
  }

  String _formatSkill(String skill) {
    // Convert skill code to display name
    switch (skill.toLowerCase()) {
      case 'police':
        return 'Police';
      case 'nss':
        return 'NSS';
      case 'fire force':
        return 'Fire Force';
      case 'ncc':
        return 'NCC';
      case 'student police':
        return 'Student Police';
      case 'scout':
        return 'Scout';
      case 'other':
        return 'Volunteer';
      default:
        return skill;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone number copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Navigate to track the request
  void _trackRequest(BuildContext context) {
    // Close the bottom sheet first
    Navigator.of(context).pop();

    // Create payload and navigate using NotificationRouter
    final payload = NotificationPayload.fromNotificationModel(notification);
    NotificationRouter().handleNotificationTap(payload);
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      // Alert colors
      case NotificationType.weatherAlert:
        return Colors.orange;
      case NotificationType.disasterAlert:
        return Colors.red;
      // Broadcast/system colors
      case NotificationType.adminBroadcast:
        return const Color(0xFF1E88E5);
      case NotificationType.reliefCenterUpdate:
        return Colors.teal;
      case NotificationType.systemNotification:
        return Colors.blueGrey;
      // Aid request colors
      case NotificationType.aidRequestSubmitted:
      case NotificationType.aidRequestInProgress:
        return const Color(0xFF1E88E5);
      case NotificationType.aidRequestAccepted:
      case NotificationType.aidRequestCompleted:
        return Colors.green;
      case NotificationType.aidRequestRejected:
        return Colors.red;
      // Donation colors
      case NotificationType.donationRequestSubmitted:
      case NotificationType.donationRequestPartiallyFulfilled:
        return const Color(0xFF7C4DFF);
      case NotificationType.donationRequestAccepted:
      case NotificationType.donationRequestCompleted:
        return Colors.green;
      case NotificationType.donationRequestRejected:
        return Colors.red;
      case NotificationType.unknown:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      // Alert icons
      case NotificationType.weatherAlert:
        return Icons.thunderstorm;
      case NotificationType.disasterAlert:
        return Icons.warning_amber_rounded;
      // Broadcast/system icons
      case NotificationType.adminBroadcast:
        return Icons.campaign;
      case NotificationType.reliefCenterUpdate:
        return Icons.location_on;
      case NotificationType.systemNotification:
        return Icons.info_outline;
      // Aid request icons
      case NotificationType.aidRequestSubmitted:
        return Icons.send;
      case NotificationType.aidRequestAccepted:
        return Icons.check_circle;
      case NotificationType.aidRequestRejected:
        return Icons.cancel;
      case NotificationType.aidRequestCompleted:
        return Icons.task_alt;
      case NotificationType.aidRequestInProgress:
        return Icons.hourglass_top;
      // Donation icons
      case NotificationType.donationRequestSubmitted:
        return Icons.volunteer_activism;
      case NotificationType.donationRequestAccepted:
        return Icons.check_circle;
      case NotificationType.donationRequestRejected:
        return Icons.cancel;
      case NotificationType.donationRequestCompleted:
        return Icons.task_alt;
      case NotificationType.donationRequestPartiallyFulfilled:
        return Icons.pie_chart;
      case NotificationType.unknown:
        return Icons.notifications;
    }
  }
}
