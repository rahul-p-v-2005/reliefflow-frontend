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
    );
  }

  /// Parse address which can be a string or an embedded object
  static String _parseAddress(dynamic addressData) {
    if (addressData == null) return '';
    if (addressData is String) return addressData;
    if (addressData is Map<String, dynamic>) {
      // Build address from addressLine fields
      final parts = <String>[];
      if (addressData['addressLine1'] != null) {
        parts.add(addressData['addressLine1'].toString());
      }
      if (addressData['addressLine2'] != null) {
        parts.add(addressData['addressLine2'].toString());
      }
      if (addressData['addressLine3'] != null) {
        parts.add(addressData['addressLine3'].toString());
      }
      if (addressData['pinCode'] != null) {
        parts.add('– ${addressData['pinCode']}');
      }
      return parts.join(', ');
    }
    return '';
  }
}
