import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/map_pin.dart';
import 'api_service.dart';

class MapService {
  MapService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  Future<List<MapPin>> fetchPins() async {
    final uri = ApiService().buildUri('/pins');
    final res = await _client.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => MapPin.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return [];
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
