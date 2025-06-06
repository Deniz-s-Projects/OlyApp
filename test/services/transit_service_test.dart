import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:oly_app/services/transit_service.dart';

void main() {
  group('TransitService', () {
    test('searchStops parses results', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/v1/locations');
        return http.Response(
          jsonEncode({
            'stations': [
              {'id': '1', 'name': 'Stop'}
            ]
          }),
          200,
        );
      });
      final service = TransitService(client: mockClient);
      final results = await service.searchStops('stop');
      expect(results, hasLength(1));
      expect(results.first.name, 'Stop');
    });

    test('fetchDepartures parses list', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/v1/stationboard');
        return http.Response(
          jsonEncode({
            'stationboard': [
              {
                'name': 'U1',
                'to': 'Downtown',
                'stop': {'departure': '1970-01-01T00:00:00.000Z'}
              }
            ]
          }),
          200,
        );
      });
      final service = TransitService(client: mockClient);
      final deps = await service.fetchDepartures('1');
      expect(deps, hasLength(1));
      expect(deps.first.line, 'U1');
    });

    test('throws on non-success status', () async {
      final mockClient = MockClient((_) async => http.Response('err', 500));
      final service = TransitService(client: mockClient);
      expect(service.searchStops('a'), throwsException);
    });
  });
}
