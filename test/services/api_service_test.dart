import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'package:oly_app/services/api_service.dart';

void main() {
  group('ApiService', () {
    setUp(() {
      ApiService.onUnauthorized = null;
    });

    tearDown(() {
      ApiService.onUnauthorized = null;
    });

    test('injects Bearer token from tokenSource', () async {
      String? capturedAuth;
      final client = MockClient((req) async {
        capturedAuth = req.headers['Authorization'];
        return http.Response('{}', 200);
      });
      final service = ApiService(
        client: client,
        tokenSource: () => 'tok-123',
      );

      await service.get<dynamic>('/anything', (j) => j);

      expect(capturedAuth, 'Bearer tok-123');
    });

    test('omits Authorization header when tokenSource returns null', () async {
      String? capturedAuth;
      final client = MockClient((req) async {
        capturedAuth = req.headers['Authorization'];
        return http.Response('{}', 200);
      });
      final service = ApiService(client: client, tokenSource: () => null);

      await service.get<dynamic>('/anything', (j) => j);

      expect(capturedAuth, isNull);
    });

    test('401 throws UnauthorizedException and fires onUnauthorized', () async {
      var hookFired = 0;
      ApiService.onUnauthorized = () => hookFired++;
      final client = MockClient(
        (_) async => http.Response('{"error":"expired"}', 401),
      );
      final service = ApiService(client: client, tokenSource: () => 't');

      await expectLater(
        service.get<dynamic>('/x', (j) => j),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(hookFired, 1);
    });

    test('TimeoutException is mapped to a generic exception', () async {
      // MockClient that never responds within the configured timeout.
      final client = MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return http.Response('{}', 200);
      });
      final service = ApiService(
        client: client,
        tokenSource: () => null,
        timeout: const Duration(milliseconds: 20),
      );

      await expectLater(
        service.get<dynamic>('/slow', (j) => j),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('timed out'),
          ),
        ),
      );
    });

    test('errors surface the server-provided error string', () async {
      final client = MockClient(
        (_) async => http.Response('{"error":"boom"}', 500),
      );
      final service = ApiService(client: client, tokenSource: () => null);

      await expectLater(
        service.get<dynamic>('/x', (j) => j),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('boom'),
          ),
        ),
      );
    });

    test('post/put/delete also trigger 401 hook', () async {
      var hookFired = 0;
      ApiService.onUnauthorized = () => hookFired++;
      final client = MockClient((_) async => http.Response('', 401));
      final service = ApiService(client: client, tokenSource: () => 't');

      for (final f in [
        () => service.post<dynamic>('/x', {}, (j) => j),
        () => service.put<dynamic>('/x', {}, (j) => j),
        () => service.delete<dynamic>('/x', (j) => j),
      ]) {
        await expectLater(f(), throwsA(isA<UnauthorizedException>()));
      }
      expect(hookFired, 3);
    });
  });
}
