import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:oly_app/services/lost_found_service.dart';

const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');

void main() {
  group('LostFoundService', () {
    test('fetchItems passes params and parses list', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/lostfound');
        expect(request.url.queryParameters['search'], 'phone');
        expect(request.url.queryParameters['type'], 'lost');
        expect(request.url.queryParameters['resolved'], 'false');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 1,
                'ownerId': '1',
                'title': 'Phone',
                'description': 'Black',
                'type': 'lost',
                'resolved': false,
                'createdAt': '1970-01-01T00:00:00.000Z'
              }
            ]
          }),
          200,
        );
      });

      final service = LostFoundService(client: mockClient);
      final items = await service.fetchItems(search: 'phone', type: 'lost', resolved: false);
      expect(items, hasLength(1));
      expect(items.first.title, 'Phone');
    });

    test('throws on non-success status', () async {
      final mockClient = MockClient((_) async => http.Response('err', 500));
      final service = LostFoundService(client: mockClient);
      expect(service.fetchItems(), throwsException);
    });
  });
}
