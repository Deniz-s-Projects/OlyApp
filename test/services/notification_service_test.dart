import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:oly_app/services/notification_service.dart';

const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');

void main() {
  group('NotificationService', () {
    test('registerToken posts token', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/notifications/register');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['token'], 'abc');
        return http.Response('{}', 200);
      });

      final service = NotificationService(client: mockClient);
      await service.registerToken('abc');
    });

    test('sendNotification posts data and returns count', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/notifications/send');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['tokens'], ['t1']);
        expect((body['notification'] as Map)['title'], 'hi');
        return http.Response(jsonEncode({'successCount': 1}), 200);
      });

      final service = NotificationService(client: mockClient);
      final count = await service.sendNotification(tokens: ['t1'], title: 'hi', body: 'b');
      expect(count, 1);
    });

    test('broadcastNotification posts alert to broadcast route', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/notifications/broadcast');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['title'], 'urgent');
        return http.Response(jsonEncode({'successCount': 5}), 200);
      });

      final service = NotificationService(client: mockClient);
      final count = await service.broadcastNotification(title: 'urgent', body: 'now');
      expect(count, 5);
    });
  });
}
