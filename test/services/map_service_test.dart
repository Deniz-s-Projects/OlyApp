import 'package:test/test.dart';
import 'package:oly_app/services/map_service.dart';

void main() {
  group('MapService', () {
    test('fetchPins returns built in pins', () async {
      final service = MapService();
      final pins = await service.fetchPins();

      expect(pins, hasLength(3));
      expect(pins[0].id, 'building1');
      expect(pins[0].lat, 48.1745);
      expect(pins[0].lon, 11.548);

      expect(pins[1].id, 'venue1');
      expect(pins[1].lat, 48.1740);
      expect(pins[1].lon, 11.547);

      expect(pins[2].id, 'amenity1');
      expect(pins[2].lat, 48.1735);
      expect(pins[2].lon, 11.549);
    });
  });
}
