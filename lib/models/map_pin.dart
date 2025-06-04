class MapPin {
  final String id;
  final String title;
  final double lat;
  final double lon;
  final String type;

  MapPin({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.type,
  });

  factory MapPin.fromMap(Map<String, dynamic> map) => MapPin(
        id: map['id'] as String,
        title: map['title'] as String,
        lat: (map['lat'] as num).toDouble(),
        lon: (map['lon'] as num).toDouble(),
        type: map['type'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'lat': lat,
        'lon': lon,
        'type': type,
      };
}
