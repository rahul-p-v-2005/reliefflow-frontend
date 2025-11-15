class CalamityType {
  final String? calamityName;
  final String? id;

  CalamityType({required this.calamityName, required this.id});

  factory CalamityType.fromJson(Map<String, dynamic> json) {
    return CalamityType(
      calamityName: json['calamityName'] as String?,

      id: json['_id'] as String?,
    );
  }
}
