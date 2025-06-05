import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/map_pin.dart';

class MapService {
  MapService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  Future<List<MapPin>> fetchPins() async {
    // In real implementation, fetch from API
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      MapPin(
        id: 'building1',
        title: 'Dormitory',
        lat: 48.1745,
        lon: 11.548,
        category: MapPinCategory.building,
      ),
      MapPin(
        id: 'venue1',
        title: 'Event Hall',
        lat: 48.1740,
        lon: 11.547,
        category: MapPinCategory.venue,
      ),
      MapPin(
        id: 'amenity1',
        title: 'Laundry',
        lat: 48.1735,
        lon: 11.549,
        category: MapPinCategory.amenity,
      ),
      MapPin(
        id: 'rec1',
        title: 'Basketball Court',
        lat: 48.1742,
        lon: 11.546,
        category: MapPinCategory.recreation,
      ),
      MapPin(
        id: 'food1',
        title: 'Cafeteria',
        lat: 48.1738,
        lon: 11.5485,
        category: MapPinCategory.food,
      ),
    ];
  }

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    final url =
        'https://router.project-osrm.org/route/v1/foot/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
    final res = await _client.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final coords = (data['routes'][0]['geometry']['coordinates'] as List)
          .cast<List>();
      return coords
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
    }
    return [];
  }
}
