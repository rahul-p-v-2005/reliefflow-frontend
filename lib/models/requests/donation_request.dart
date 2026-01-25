/// Item detail model for donation request items
class ItemDetail {
  final String? id;
  final String category;
  final String? description;
  final String quantity;
  final String? unit;

  ItemDetail({
    this.id,
    required this.category,
    this.description,
    required this.quantity,
    this.unit,
  });

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    return ItemDetail(
      id: json['_id'] as String?,
      category: json['category'] as String? ?? '',
      description: json['description'] as String?,
      quantity: json['quantity']?.toString() ?? '',
      unit: json['unit'] as String? ?? 'pieces',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'category': category,
      if (description != null) 'description': description,
      'quantity': quantity,
      'unit': unit ?? 'pieces',
    };
  }
}

/// Requested user profile model (populated from userProfile ref)
class RequestedUser {
  final String id;
  final String? name;

  RequestedUser({
    required this.id,
    this.name,
  });

  factory RequestedUser.fromJson(Map<String, dynamic> json) {
    return RequestedUser(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String?,
    );
  }
}

/// Location model for GeoJSON Point
class DonationLocation {
  final String type;
  final List<double> coordinates; // [longitude, latitude]

  DonationLocation({
    this.type = 'Point',
    required this.coordinates,
  });

  factory DonationLocation.fromJson(Map<String, dynamic> json) {
    return DonationLocation(
      type: json['type'] as String? ?? 'Point',
      coordinates:
          (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  double get latitude => coordinates.length > 1 ? coordinates[1] : 0;
  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0;
}

/// Address model
class DonationAddress {
  final String addressLine1;
  final String? addressLine2;
  final String? addressLine3;
  final int pinCode;
  final DonationLocation? location;

  DonationAddress({
    required this.addressLine1,
    this.addressLine2,
    this.addressLine3,
    required this.pinCode,
    this.location,
  });

  factory DonationAddress.fromJson(Map<String, dynamic> json) {
    return DonationAddress(
      addressLine1: json['addressLine1'] as String? ?? '',
      addressLine2: json['addressLine2'] as String?,
      addressLine3: json['addressLine3'] as String?,
      pinCode: json['pinCode'] as int? ?? 0,
      location: json['location'] != null
          ? DonationLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressLine1': addressLine1,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      if (addressLine3 != null) 'addressLine3': addressLine3,
      'pinCode': pinCode,
      if (location != null) 'location': location!.toJson(),
    };
  }
}

/// Donation request model aligned with backend schema
class DonationRequest {
  final String id;
  final String? title;
  final String? description;
  final String requestedBy;
  final RequestedUser? requestedUser;
  final String donationType;
  final double? amount;
  final List<ItemDetail>? itemDetails;
  final String priority;
  final String status;
  final String? upiNumber;
  final DonationLocation? location;
  final DonationAddress? address;
  final DateTime? deadline;
  final List<String>? proofImages;
  final double? fulfilledAmount;
  final List<String>? donations;
  final String? name; // Virtual field computed by backend
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DonationRequest({
    required this.id,
    this.title,
    this.description,
    required this.requestedBy,
    this.requestedUser,
    required this.donationType,
    this.amount,
    this.itemDetails,
    required this.priority,
    required this.status,
    this.upiNumber,
    this.location,
    this.address,
    this.deadline,
    this.proofImages,
    this.fulfilledAmount,
    this.donations,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory DonationRequest.fromJson(Map<String, dynamic> json) {
    return DonationRequest(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      requestedBy: json['requestedBy'] is String
          ? json['requestedBy'] as String
          : (json['requestedBy']?['_id'] as String? ?? ''),
      requestedUser: json['requestedUser'] != null
          ? RequestedUser.fromJson(
              json['requestedUser'] as Map<String, dynamic>,
            )
          : null,
      donationType: json['donationType'] as String? ?? '',
      amount: json['amount'] != null
          ? (json['amount'] as num).toDouble()
          : null,
      itemDetails: json['itemDetails'] != null
          ? (json['itemDetails'] as List<dynamic>)
                .map((e) => ItemDetail.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'pending',
      upiNumber: json['upiNumber'] as String?,
      location: json['location'] != null
          ? DonationLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      address: json['address'] != null
          ? DonationAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'] as String)
          : null,
      proofImages: json['proofImages'] != null
          ? (json['proofImages'] as List<dynamic>)
                .map((e) => e as String)
                .toList()
          : null,
      fulfilledAmount: json['fulfilledAmount'] != null
          ? (json['fulfilledAmount'] as num).toDouble()
          : null,
      donations: json['donations'] != null
          ? (json['donations'] as List<dynamic>)
                .map((e) => e as String)
                .toList()
          : null,
      name: json['name'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      'requestedBy': requestedBy,
      'donationType': donationType,
      if (amount != null) 'amount': amount,
      if (itemDetails != null)
        'itemDetails': itemDetails!.map((e) => e.toJson()).toList(),
      'priority': priority,
      'status': status,
      if (upiNumber != null) 'upiNumber': upiNumber,
      if (location != null) 'location': location!.toJson(),
      if (address != null) 'address': address!.toJson(),
      if (deadline != null) 'deadline': deadline!.toIso8601String(),
      if (proofImages != null) 'proofImages': proofImages,
    };
  }

  /// Get fulfillment percentage for cash donations
  double get fulfillmentPercentage {
    if (donationType != 'cash' || amount == null || amount == 0) return 0;
    return ((fulfilledAmount ?? 0) / amount!) * 100;
  }

  /// Check if the request is fully fulfilled
  bool get isFullyFulfilled {
    if (donationType == 'cash') {
      return (fulfilledAmount ?? 0) >= (amount ?? 0);
    }
    return status == 'completed';
  }
}
