class AidRequest {
  final String id;
  final String calamityType;
  final String address;
  final String? imageUrl;
  final String status;
  final String priority;
  final String aidRequestedBy;
  final String formattedAddress;
  final String name;

  AidRequest({
    required this.id,
    required this.calamityType,
    required this.address,
    this.imageUrl,
    required this.status,
    required this.priority,
    required this.aidRequestedBy,
    required this.formattedAddress,
    required this.name,
  });

  factory AidRequest.fromJson(Map<String, dynamic> json) {
    return AidRequest(
      id: json['_id'] ?? '',
      calamityType: json['calamityType'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['imageUrl'],
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      aidRequestedBy: json['aidRequestedBy'] ?? '',
      formattedAddress: json['formattedAddress'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
