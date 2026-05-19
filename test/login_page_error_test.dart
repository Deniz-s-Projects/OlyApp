import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:oly_app/l10n/generated/app_localizations.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/login_page.dart';
import 'package:oly_app/services/auth_service.dart';

class FakeAuthService extends AuthService {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    throw Exception('Invalid credentials');
  }
}

void main() {
  late Directory dir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
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

  testWidgets('shows server error on invalid credentials', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: LoginPage(onLoginSuccess: () {}, service: FakeAuthService()),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
    // Password must satisfy client-side validation (>=8 chars, letter + digit).
    await tester.enterText(find.byType(TextFormField).at(1), 'Wrongpwd1');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}
