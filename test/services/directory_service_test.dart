import 'dart:io';

import 'package:test/test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import 'package:oly_app/services/directory_service.dart';
import 'package:oly_app/models/models.dart';

void main() {
  group('DirectoryService caching', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp();
      Hive.init(dir.path);
      Hive.registerAdapter(UserAdapter());
      await Hive.openBox('directoryBox');
    });

    tearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('returns cached users when request fails', () async {
      final box = Hive.box('directoryBox');
      await box.put('users_', [
        User(name: 'Cached', email: 'c@example.com')
            .toJson(),
      ]);

      final mockClient = MockClient((_) async => http.Response('err', 500));
      final service = DirectoryService(client: mockClient);
      final users = await service.fetchUsers();
      expect(users, hasLength(1));
      expect(users.first.name, 'Cached');
    });
  });
}
