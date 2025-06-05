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

    test('throws on error status', () async {
      final mockClient =
          MockClient((_) async => http.Response('error', 500));
      final service = BookingService(client: mockClient);
      expect(service.fetchAvailableTimes(), throwsException);
    });
  });
}
