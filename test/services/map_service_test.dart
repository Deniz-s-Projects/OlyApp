import 'package:test/test.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oly_app/services/map_service.dart';
import 'package:oly_app/models/map_pin.dart';

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

    test('create/update/delete pin uses correct endpoints', () async {
      int step = 0;
      final mockClient = MockClient((request) async {
        if (step == 0) {
          expect(request.method, equals('POST'));
          expect(request.url.path, '/api/pins');
          step++;
          return http.Response(
            jsonEncode({'data': jsonDecode(request.body)}),
            201,
          );
        } else if (step == 1) {
          expect(request.method, equals('POST'));
          expect(request.url.path, '/api/pins/1');
          step++;
          return http.Response(
            jsonEncode({'data': jsonDecode(request.body)}),
            200,
          );
        } else {
          expect(request.method, equals('DELETE'));
          expect(request.url.path, '/api/pins/1');
          return http.Response('{}', 200);
        }
      });

      final service = MapService(client: mockClient);
      final pin = MapPin(
        id: '1',
        title: 't',
        lat: 0,
        lon: 0,
        category: MapPinCategory.building,
      );
      await service.createPin(pin);
      await service.updatePin(pin);
      await service.deletePin('1');
    });
  });
}
