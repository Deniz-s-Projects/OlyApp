import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:oly_app/main.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/main_page.dart';
import 'package:oly_app/pages/login_page.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox('authBox');
    await Hive.openBox<User>('userBox');
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  testWidgets('Loads MainPage when credentials exist', (tester) async {
    final authBox = Hive.box('authBox');
    await authBox.put('token', 'token');
    final userBox = Hive.box<User>('userBox');
    await userBox.put('currentUser', User(name: 'Test', email: 't@test.com'));

    await tester.pumpWidget(const OlyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MainPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  }, skip: true);
}
