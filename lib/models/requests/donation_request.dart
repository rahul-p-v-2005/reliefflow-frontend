/// Item detail model for donation request items
class ItemDetail {
  final String? id;
  final String category;
  final String? description;
  final String quantity;

  ItemDetail({
    this.id,
    required this.category,
    this.description,
    required this.quantity,
  });

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    return ItemDetail(
      id: json['_id'] as String?,
      category: json['category'] as String? ?? '',
      description: json['description'] as String?,
      quantity: json['quantity'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'category': category,
      if (description != null) 'description': description,
      'quantity': quantity,
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

/// Donation request model aligned with backend schema
class DonationRequest {
  final String id;
  final String requestedBy;
  final RequestedUser? requestedUser;
  final String donationType;
  final double? amount;
  final List<ItemDetail>? itemDetails;
  final String priority;
  final String status;
  final String? name; // Virtual field computed by backend

  DonationRequest({
    required this.id,
    required this.requestedBy,
    this.requestedUser,
    required this.donationType,
    this.amount,
    this.itemDetails,
    required this.priority,
    required this.status,
    this.name,
  });

  factory DonationRequest.fromJson(Map<String, dynamic> json) {
    return DonationRequest(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      requestedBy: json['requestedBy'] is String
          ? json['requestedBy'] as String
          : (json['requestedBy']?['_id'] as String? ?? ''),
      requestedUser: json['requestedUser'] != null
          ? RequestedUser.fromJson(json['requestedUser'] as Map<String, dynamic>)
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
      priority: json['priority'] as String? ?? 'low',
      status: json['status'] as String? ?? 'pending',
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'requestedBy': requestedBy,
      'donationType': donationType,
      if (amount != null) 'amount': amount,
      if (itemDetails != null)
        'itemDetails': itemDetails!.map((e) => e.toJson()).toList(),
      'priority': priority,
      'status': status,
    };
  }
}
