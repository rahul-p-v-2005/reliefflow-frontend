import 'feature.dart';

class LocationSearchResponse {
  String? type;
  List<Feature>? features;

  LocationSearchResponse({this.type, this.features});

  @override
  String toString() {
    return 'LocationSearchResponse(type: $type, features: $features)';
  }

  factory LocationSearchResponse.fromJson(Map<String, dynamic> json) {
    return LocationSearchResponse(
      type: json['type'] as String?,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => Feature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'features': features?.map((e) => e.toJson()).toList(),
  };
}
