class AidRequest {
  final String id;
  final String calamityType;
  final String? calamityTypeName;
  final String address;
  final String? imageUrl;
  final String? description;
  final String status;
  final String priority;
  final String aidRequestedBy;
  final String formattedAddress;
  final String name;
  final DateTime? createdAt;
  final bool isRead;
  final Map<String, dynamic>? location;

  AidRequest({
    required this.id,
    required this.calamityType,
    this.calamityTypeName,
    required this.address,
    this.imageUrl,
    this.description,
    required this.status,
    required this.priority,
    required this.aidRequestedBy,
    required this.formattedAddress,
    required this.name,
    this.createdAt,
    this.isRead = false,
    this.location,
  });

  /// Check if this request can be edited by the user
  bool get canEdit => status == 'pending' && !isRead;

  /// Check if this request can be deleted by the user
  bool get canDelete => status == 'pending' && !isRead;

  factory AidRequest.fromJson(Map<String, dynamic> json) {
    // Handle calamityType which could be a string ID or populated object
    String calamityTypeId = '';
    String? calamityTypeName;
    final calamityTypeData = json['calamityType'];
    if (calamityTypeData is String) {
      calamityTypeId = calamityTypeData;
    } else if (calamityTypeData is Map<String, dynamic>) {
      calamityTypeId = calamityTypeData['_id'] ?? '';
      // Backend uses 'calamityName', not 'name' or 'type'
      calamityTypeName =
          calamityTypeData['calamityName'] ??
          calamityTypeData['name'] ??
          calamityTypeData['type'];
    }

    return AidRequest(
      id: json['_id'] ?? '',
      calamityType: calamityTypeId,
      calamityTypeName: calamityTypeName,
      address: _parseAddress(json['address']),
      imageUrl: json['imageUrl'],
      description: json['description'],
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      aidRequestedBy: json['aidRequestedBy'] ?? '',
      formattedAddress: json['formattedAddress'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      isRead: json['isRead'] ?? false,
      location: json['location'] as Map<String, dynamic>?,
    );
  }

  /// Parse address which can be a string or an embedded object
  static String _parseAddress(dynamic addressData) {
    if (addressData == null) return '';
    if (addressData is String) return addressData;
    if (addressData is Map<String, dynamic>) {
      // Build address from addressLine fields
      final parts = <String>[];

      final line1 = addressData['addressLine1']?.toString().trim() ?? '';
      if (line1.isNotEmpty) {
        parts.add(line1);
      }

      final line2 = addressData['addressLine2']?.toString().trim() ?? '';
      if (line2.isNotEmpty) {
        parts.add(line2);
      }

      final line3 = addressData['addressLine3']?.toString().trim() ?? '';
      if (line3.isNotEmpty) {
        parts.add(line3);
      }

      final pinCode = addressData['pinCode'];
      if (pinCode != null && pinCode != 0) {
        parts.add('– $pinCode');
      }

      return parts.join(', ');
    }
    return '';
  }
}
