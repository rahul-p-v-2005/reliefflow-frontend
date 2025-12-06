class Geometry {
  String? type;
  List<double>? coordinates;

  Geometry({this.type, this.coordinates});

  @override
  String toString() => 'Geometry(type: $type, coordinates: $coordinates)';

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    type: json['type'] as String?,
    coordinates: json['coordinates'] as List<double>?,
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'coordinates': coordinates,
  };
}
