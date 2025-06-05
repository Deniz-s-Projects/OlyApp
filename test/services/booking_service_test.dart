import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:oly_app/services/booking_service.dart';

const apiUrl =
    String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');

void main() {
  group('BookingService', () {
    test('fetchAvailableTimes parses datetimes', () async {
      final isoTimes = [
        '2024-01-01T12:00:00.000Z',
        '2024-01-01T13:00:00.000Z',
      ];
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/bookings/slots');
        return http.Response(jsonEncode({'data': isoTimes}), 200);
      });

      final service = BookingService(client: mockClient);
      final times = await service.fetchAvailableTimes();
      expect(times, hasLength(2));
      expect(times[0], DateTime.parse(isoTimes[0]));
      expect(times[1], DateTime.parse(isoTimes[1]));
    });

    test('createBooking posts body and succeeds', () async {
      final time = DateTime.parse('2024-01-01T14:00:00.000Z');
      const name = 'Jane';
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/bookings');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['time'], time.toIso8601String());
        expect(body['name'], name);
        return http.Response(jsonEncode({'data': {}}), 200);
      });

      final service = BookingService(client: mockClient);
      await service.createBooking(time, name);
    });

    test('fetchMyBookings parses list', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, '/api/bookings/my');
        return http.Response(
          jsonEncode({
            'data': [
              {
                '_id': '1',
                'time': '2024-01-02T10:00:00.000Z',
                'name': 'Me'
              }
            ]
          }),
          200,
        );
      });

      final service = BookingService(client: mockClient);
      final result = await service.fetchMyBookings();
      expect(result, hasLength(1));
      expect(result.first['_id'], '1');
      expect(result.first['time'], DateTime.parse('2024-01-02T10:00:00.000Z'));
    });

    test('cancelBooking uses DELETE', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('DELETE'));
        expect(request.url.path, '/api/bookings/1');
        return http.Response('{}', 200);
      });

      final service = BookingService(client: mockClient);
      await service.cancelBooking('1');
    });

    test('createSlot posts to admin endpoint', () async {
      final time = DateTime.parse('2024-01-05T10:00:00.000Z');
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, '/api/bookings/slots');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['time'], time.toIso8601String());
        return http.Response('{}', 201);
      });

      final service = BookingService(client: mockClient);
      await service.createSlot(time);
    });

    test('deleteSlot sends DELETE', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('DELETE'));
        expect(request.url.path, '/api/bookings/slots/123');
        return http.Response('{}', 200);
      });

      final service = BookingService(client: mockClient);
      await service.deleteSlot('123');
    });

    test('throws on error status', () async {
      final mockClient =
          MockClient((_) async => http.Response('error', 500));
      final service = BookingService(client: mockClient);
      expect(service.fetchAvailableTimes(), throwsException);
    });
  });
}
