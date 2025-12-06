class Properties {
  String? osmType;
  int? osmId;
  String? osmKey;
  String? osmValue;
  String? type;
  String? countrycode;
  String? name;
  String? country;
  String? state;
  String? county;
  List<double>? extent;

  Properties({
    this.osmType,
    this.osmId,
    this.osmKey,
    this.osmValue,
    this.type,
    this.countrycode,
    this.name,
    this.country,
    this.state,
    this.county,
    this.extent,
  });

  @override
  String toString() {
    return 'Properties(osmType: $osmType, osmId: $osmId, osmKey: $osmKey, osmValue: $osmValue, type: $type, countrycode: $countrycode, name: $name, country: $country, state: $state, county: $county, extent: $extent)';
  }

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
    osmType: json['osm_type'] as String?,
    osmId: json['osm_id'] as int?,
    osmKey: json['osm_key'] as String?,
    osmValue: json['osm_value'] as String?,
    type: json['type'] as String?,
    countrycode: json['countrycode'] as String?,
    name: json['name'] as String?,
    country: json['country'] as String?,
    state: json['state'] as String?,
    county: json['county'] as String?,
    extent: json['extent'] as List<double>?,
  );

  Map<String, dynamic> toJson() => {
    'osm_type': osmType,
    'osm_id': osmId,
    'osm_key': osmKey,
    'osm_value': osmValue,
    'type': type,
    'countrycode': countrycode,
    'name': name,
    'country': country,
    'state': state,
    'county': county,
    'extent': extent,
  };
}
