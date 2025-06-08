import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:oly_app/main.dart';
import 'package:oly_app/models/models.dart';

void main() {
  late Directory dir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(NotificationRecordAdapter());
    await Hive.openBox('settingsBox');
    await Hive.openBox('authBox');
    await Hive.openBox<User>('userBox');
    await Hive.openBox<NotificationRecord>('notificationsBox');
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  testWidgets(
    'theme persists across restart',
    (tester) async {
      await tester.pumpWidget(const OlyApp());
      await tester.pump();

    final state = tester.state<OlyAppState>(find.byType(OlyApp));
      state.updateThemeMode(ThemeMode.dark);
      await tester.pump();

    expect(
      (tester.widget(find.byType(MaterialApp)) as MaterialApp).themeMode,
      ThemeMode.dark,
    );

      await tester.pumpWidget(Container());
      await tester.pump();

      await tester.pumpWidget(const OlyApp());
      await tester.pump();

      expect(
        (tester.widget(find.byType(MaterialApp)) as MaterialApp).themeMode,
        ThemeMode.dark,
      );
    },
    timeout: const Timeout(Duration(seconds: 10)),
    skip: true,
  );
}
