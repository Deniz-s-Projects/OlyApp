import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:oly_app/services/event_service.dart';
import 'package:oly_app/models/models.dart';

void main() {
  group('EventService', () {
    test('fetchEvents parses list correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, '/api/events');
        return http.Response(jsonEncode([
          {
            'id': 1,
            'title': 'Party',
            'date': 0,
            'description': 'fun'
          }
        ]), 200);
      });

      final service = EventService(client: mockClient);
      final events = await service.fetchEvents();
      expect(events, hasLength(1));
      expect(events.first.title, 'Party');
    });

    test('createEvent sends POST and parses event', () async {
      final input = CalendarEvent(title: 'Meet', date: DateTime.fromMillisecondsSinceEpoch(0));
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, '/api/events');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['title'], input.title);
        return http.Response(
          jsonEncode({
            'id': 2,
            ...input.toJson(),
          }),
          201,
        );
      });

      final service = EventService(client: mockClient);
      final event = await service.createEvent(input);
      expect(event.id, 2);
      expect(event.title, 'Meet');
    });

    test('fetchEvents throws on error', () async {
      final mockClient = MockClient((_) async => http.Response('err', 404));
      final service = EventService(client: mockClient);
      expect(service.fetchEvents(), throwsException);
    });
  });
}
