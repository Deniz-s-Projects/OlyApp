import '../models/map_pin.dart';

class MapService {
  Future<List<MapPin>> fetchPins() async {
    // In real implementation, fetch from API
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      MapPin(
        id: 'building1',
        title: 'Dormitory',
        lat: 48.1745,
        lon: 11.548,
        type: 'building',
      ),
      MapPin(
        id: 'venue1',
        title: 'Event Hall',
        lat: 48.1740,
        lon: 11.547,
        type: 'venue',
      ),
      MapPin(
        id: 'amenity1',
        title: 'Laundry',
        lat: 48.1735,
        lon: 11.549,
        type: 'amenity',
      ),
    ];
  }
}
