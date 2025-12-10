class Geometry {
  String? type;
  List<double>? coordinates;

  Geometry({this.type, this.coordinates});

  @override
  String toString() => 'Geometry(type: $type, coordinates: $coordinates)';

  factory Geometry.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'];
    if (coords is List<dynamic>) {
      // Convert dynamic list to List<double>
      final doubleCoords = coords.map((e) => (e as num).toDouble()).toList();
      return Geometry(
        type: json['type'] as String?,
        coordinates: doubleCoords,
      );
    }
    return Geometry(
      type: json['type'] as String?,
      coordinates: json['coordinates'] as List<double>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'coordinates': coordinates,
  };
}
