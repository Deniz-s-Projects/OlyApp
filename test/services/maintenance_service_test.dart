import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:oly_app/services/maintenance_service.dart';
import 'package:oly_app/models/models.dart';

const apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000',
);

void main() {
  group('MaintenanceService', () {
    test('fetchRequests parses list correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/maintenance');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 1,
                'userId': '1',
                'subject': 'Leak',
                'description': 'Water',
                'createdAt': '1970-01-01T00:00:00.000Z',
                'status': 'open',
              },
            ],
          }),
          200,
        );
      });

      final service = MaintenanceService(client: mockClient);
      final requests = await service.fetchRequests();
      expect(requests, hasLength(1));
      expect(requests.first.subject, 'Leak');
    });

    test('createRequest uses POST', () async {
      final input = MaintenanceRequest(
        userId: '1',
        subject: 'Leak',
        description: 'Water',
        imageUrl: 'path.png',
      );
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/maintenance');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['subject'], input.subject);
        expect(body['imageUrl'], 'path.png');
        return http.Response(
          jsonEncode({
            'data': {'id': 2, ...input.toJson()},
          }),
          201,
        );
      });

      final service = MaintenanceService(client: mockClient);
      final result = await service.createRequest(input);
      expect(result.id, 2);
    });

    test('fetchMessages parses list correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/maintenance/1/messages');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 1,
                'requestId': 1,
                'senderId': '2',
                'content': 'Hi',
                'timestamp': '1970-01-01T00:00:00.000Z',
              },
            ],
          }),
          200,
        );
      });

      final service = MaintenanceService(client: mockClient);
      final messages = await service.fetchMessages(1);
      expect(messages, hasLength(1));
      expect(messages.first.content, 'Hi');
    });

    test('sendMessage posts message', () async {
      final input = Message(requestId: 1, senderId: '2', content: 'Hi');
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/maintenance/1/messages');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['content'], input.content);
        return http.Response(
          jsonEncode({
            'data': {'id': 3, ...input.toJson()},
          }),
          201,
        );
      });

      final service = MaintenanceService(client: mockClient);
      final message = await service.sendMessage(input);
      expect(message.id, 3);
    });

    test('updateStatus uses PUT', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('PUT'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/maintenance/1');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['status'], 'closed');
        return http.Response(
          jsonEncode({
            'id': 1,
            'userId': '1',
            'subject': 'a',
            'description': 'b',
            'createdAt': 0,
            'status': 'closed',
          }),
          200,
        );
      });

      final service = MaintenanceService(client: mockClient);
      final result = await service.updateStatus(1, 'closed');
      expect(result.status, 'closed');
    });

    test('deleteRequest sends DELETE', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('DELETE'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/maintenance/1');
        return http.Response('{}', 200);
      });

      final service = MaintenanceService(client: mockClient);
      await service.deleteRequest(1);
    });

    test('throws on error status', () async {
      final mockClient = MockClient((_) async => http.Response('err', 500));
      final service = MaintenanceService(client: mockClient);
      expect(service.fetchRequests(), throwsException);
    });
  });
}
