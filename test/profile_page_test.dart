import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:hive/hive.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/profile_page.dart';

void main() {
  late Directory dir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>('userBox');
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  testWidgets('Edits persist and reload', (tester) async {
    await mockNetworkImagesFor(() async {
      final box = Hive.box<User>('userBox');
      await box.put('currentUser', User(name: 'Old', email: 'old@test.com'));

      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      await tester.pump();

      Finder nameField() => find.bySemanticsLabel('Name');
      Finder emailField() => find.bySemanticsLabel('Email');
      Finder avatarField() => find.bySemanticsLabel('Avatar URL');

      expect(tester.widget<TextFormField>(nameField()).controller!.text, 'Old');
      expect(
        tester.widget<TextFormField>(emailField()).controller!.text,
        'old@test.com',
      );

      await tester.enterText(nameField(), 'New Name');
      await tester.enterText(emailField(), 'new@example.com');
      await tester.enterText(avatarField(), 'http://example.com/avatar.png');
      await tester.tap(find.text('Save'));
      await tester.pump();

      final saved = box.get('currentUser')!;
      expect(saved.name, 'New Name');
      expect(saved.email, 'new@example.com');
      expect(saved.avatarUrl, 'http://example.com/avatar.png');

      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      await tester.pump();

      expect(
        tester.widget<TextFormField>(nameField()).controller!.text,
        'New Name',
      );
      expect(
        tester.widget<TextFormField>(emailField()).controller!.text,
        'new@example.com',
      );
      expect(
        tester.widget<TextFormField>(avatarField()).controller!.text,
        'http://example.com/avatar.png',
      );
    });
  });
}
