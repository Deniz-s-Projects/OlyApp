import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:hive/hive.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/profile_page.dart';
import 'package:oly_app/services/user_service.dart';

class FakeUserService extends UserService {
  User? updated;
  @override
  Future<User> updateProfile(User user) async {
    updated = user;
    return user;
  }
}

void main() {
  late Directory dir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>('userBox');
    await Hive.openBox('settingsBox');
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  testWidgets('Edits persist and reload', (tester) async {
    await mockNetworkImagesFor(() async {
      // ── Wrap everything (Hive I/O + widget pumps) in a single runAsync:
      await tester.runAsync(() async {
        // 1) Insert the “Old” user into Hive on the real event loop:
        final box = Hive.box<User>('userBox');
        await box.put(
          'currentUser',
          User(name: 'Old', email: 'old@test.com', isListed: false),
        );

        final service = FakeUserService();

        // 2) Pump ProfilePage:
        await tester.pumpWidget(
          MaterialApp(home: ProfilePage(service: service)),
        );
        // Give 300ms for any images/animations to complete (instead of pumpAndSettle):
        await tester.pump(const Duration(milliseconds: 300));

        final nameFieldTf = find.byType(TextFormField).at(0);
        final emailFieldTf = find.byType(TextFormField).at(1);

        final nameEditableFinder = find.descendant(
          of: nameFieldTf,
          matching: find.byType(EditableText),
        );
        final emailEditableFinder = find.descendant(
          of: emailFieldTf,
          matching: find.byType(EditableText),
        );

        // 5) Verify the initial text is “Old” / “old@test.com”:
        final nameEditable = tester.widget<EditableText>(nameEditableFinder);
        final emailEditable = tester.widget<EditableText>(emailEditableFinder);
        expect(nameEditable.controller.text, 'Old');
        expect(emailEditable.controller.text, 'old@test.com');

        // 6) Enter new text into each field and tap “Save”:
        await tester.enterText(nameEditableFinder, 'New Name');
        await tester.enterText(emailEditableFinder, 'new@example.com');
        await tester.tap(find.text('Save'));
        // Wait 300ms for any save‐animation or Hive write to complete:
        await tester.pump(const Duration(milliseconds: 300));

        // 7) Verify that service was called and Hive wrote the updated user:
        expect(service.updated!.name, 'New Name');
        expect(service.updated!.email, 'new@example.com');

        final saved = Hive.box<User>('userBox').get('currentUser')!;
        expect(saved.name, 'New Name');
        expect(saved.email, 'new@example.com');

        // 8) Re‐pump the ProfilePage and give it time to rebuild:
        await tester.pumpWidget(
          MaterialApp(home: ProfilePage(service: service)),
        );
        await tester.pump(const Duration(milliseconds: 300));

        // 9) Finally, confirm that the text fields now show “New Name” / “new@example.com”:
        final reloadedNameEditable = tester.widget<EditableText>(
          nameEditableFinder,
        );
        final reloadedEmailEditable = tester.widget<EditableText>(
          emailEditableFinder,
        );
        expect(reloadedNameEditable.controller.text, 'New Name');
        expect(reloadedEmailEditable.controller.text, 'new@example.com');
      });
    });
  });
}
