import 'package:test/test.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oly_app/services/map_service.dart';

void main() {
  group('MapService', () {
    test('fetchPins retrieves pins from API', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/pins');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': '1',
                'title': 'Dorm',
                'lat': 0,
                'lon': 0,
                'category': 'building'
              }
            ]
          }),
          200,
        );
      });

      final service = MapService(client: mockClient);
      final pins = await service.fetchPins();

      expect(pins, hasLength(1));
      expect(pins.first.id, '1');
      expect(pins.first.title, 'Dorm');
    });
  });
}
