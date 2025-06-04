enum MapPinCategory { building, venue, amenity, recreation, food }

class MapPin {
  final String id;
  final String title;
  final double lat;
  final double lon;
  final MapPinCategory category;

  MapPin({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.category,
  });

  factory MapPin.fromMap(Map<String, dynamic> map) => MapPin(
        id: map['id'] as String,
        title: map['title'] as String,
        lat: (map['lat'] as num).toDouble(),
        lon: (map['lon'] as num).toDouble(),
        category: MapPinCategory.values.firstWhere(
          (e) => e.name == map['category'],
          orElse: () => MapPinCategory.amenity,
        ),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'lat': lat,
        'lon': lon,
        'category': category.name,
      };
}
