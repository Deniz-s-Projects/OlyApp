import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/providers/user_providers.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('oly_currentuser_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    if (await Hive.boxExists('userBox')) {
      await Hive.deleteBoxFromDisk('userBox');
    }
    await Hive.openBox<User>('userBox');
  });

  test('returns null when userBox has no current user', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(currentUserProvider), isNull);
  });

  test('reflects the user already in the box on first read', () async {
    final box = Hive.box<User>('userBox');
    await box.put(
      'currentUser',
      User(id: '1', name: 'Anna Schmidt', email: 'anna@example.com'),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(currentUserProvider)?.name, 'Anna Schmidt');
    expect(container.read(currentUserFirstNameProvider), 'Anna');
  });

  test('auto-refreshes when the box is updated after first read', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(currentUserProvider), isNull);

    final box = Hive.box<User>('userBox');
    await box.put(
      'currentUser',
      User(id: '1', name: 'Ben Müller', email: 'ben@example.com'),
    );

    // The Hive watch stream is async — give the listener a tick to fire.
    await Future<void>.delayed(Duration.zero);

    expect(container.read(currentUserProvider)?.name, 'Ben Müller');
  });

  test('auto-clears when the box entry is deleted', () async {
    final box = Hive.box<User>('userBox');
    await box.put(
      'currentUser',
      User(id: '1', name: 'Carla', email: 'carla@example.com'),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(currentUserProvider)?.name, 'Carla');

    await box.delete('currentUser');
    await Future<void>.delayed(Duration.zero);

    expect(container.read(currentUserProvider), isNull);
  });
}
