import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

import 'package:oly_app/services/map_service.dart';

void main() {
  group('MapService.fetchRoute', () {
    test('returns decoded coordinates', () async {
      final coords = [
        [0.0, 0.0],
        [1.0, 1.0]
      ];
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.host, 'router.project-osrm.org');
        return http.Response(
          jsonEncode({
            'routes': [
              {
                'geometry': {'coordinates': coords}
              }
            ]
          }),
          200,
        );
      });

      final service = MapService(client: mockClient);
      final route =
          await service.fetchRoute(const LatLng(0, 0), const LatLng(1, 1));

      expect(route, [const LatLng(0, 0), const LatLng(1, 1)]);
    });
  });
}
