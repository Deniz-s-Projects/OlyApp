import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oly_app/services/qr_service.dart';

void main() {
  group('QrService', () {
    test('fetchQrCode returns bytes', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/events/1/qr');
        return http.Response.bytes(
          Uint8List.fromList([1, 2, 3]),
          200,
          headers: {'content-type': 'image/png'},
        );
      });
      final service = QrService(client: mockClient);
      final bytes = await service.fetchQrCode(1);
      expect(bytes, isA<Uint8List>());
      expect(bytes.length, 3);
    });

    test('checkIn posts to endpoint', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/events/1/checkin');
        return http.Response('{}', 200);
      });
      final service = QrService(client: mockClient);
      await service.checkIn(1);
    });
  });
}
