import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/login_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:hive/hive.dart';

class FakeGoogleAuth implements GoogleSignInAuthentication {
  @override
  String get accessToken => 'gAccess';
  @override
  String get idToken => 'gId';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGoogleAccount implements GoogleSignInAccount {
  @override
  Future<GoogleSignInAuthentication> get authentication async =>
      FakeGoogleAuth();

  @override
  String get email => 'google@example.com';

  @override
  String? get displayName => 'Google User';

  @override
  String? get photoUrl => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGoogleSignIn extends GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() async => FakeGoogleAccount();
}

Future<HttpServer> _startServer({required bool success}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);
  server.listen((req) async {
    if (req.method == 'POST' && req.uri.path == '/api/auth/login') {
      if (success) {
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(
          jsonEncode({
            'token': 'token123',
            'user': {
              'id': 1,
              'name': 'Test',
              'email': 'test@example.com',
              'avatarUrl': null,
              'isAdmin': false,
            },
          }),
        );
      } else {
        req.response.statusCode = 401;
        req.response.write('error');
      }
    } else {
      req.response.statusCode = 404;
    }
    await req.response.close();
  });
  return server;
}

class FakeAppleCredential extends AuthorizationCredentialAppleID {
  const FakeAppleCredential()
    : super(
        userIdentifier: '1',
        givenName: 'Apple',
        familyName: 'User',
        email: 'apple@example.com',
        authorizationCode: 'code',
        identityToken: 'appleToken',
        state: 'ok',
      );
}

void main() {
  late Directory dir;

  setUpAll(() {
    Hive.registerAdapter(UserAdapter());
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    await Hive.openBox('authBox');
    await Hive.openBox<User>('userBox');
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  testWidgets('successful login stores token and user', (tester) async {
    await tester.runAsync(() async {
      final server = await _startServer(success: true);

      bool called = false;
      await tester.pumpWidget(
        MaterialApp(home: LoginPage(onLoginSuccess: () => called = true)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'pass');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(Hive.box('authBox').get('token'), 'token123');
      final user = Hive.box<User>('userBox').get('currentUser');
      expect(user?.email, 'test@example.com');
      expect(called, isTrue);

      await server.close(force: true);
    });
  });

  testWidgets('failed login shows snackbar', (tester) async {
    await tester.runAsync(() async {
      final server = await _startServer(success: false);
      await tester.pumpWidget(
        MaterialApp(home: LoginPage(onLoginSuccess: () {})),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'bad@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);

      await server.close(force: true);
    });
  });

  testWidgets('google and apple sign in callbacks', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            onLoginSuccess: () {},
            googleSignIn: FakeGoogleSignIn(),
            appleSignIn: () async => const FakeAppleCredential(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(ElevatedButton, Icons.login));
      await tester.pumpAndSettle();

      expect(Hive.box('authBox').get('token'), 'gId');
      var user = Hive.box<User>('userBox').get('currentUser');
      expect(user?.email, 'google@example.com');

      await Hive.box('authBox').clear();
      await Hive.box<User>('userBox').clear();

      await tester.tap(find.widgetWithIcon(ElevatedButton, Icons.apple));
      await tester.pumpAndSettle();

      expect(Hive.box('authBox').get('token'), 'appleToken');
      user = Hive.box<User>('userBox').get('currentUser');
      expect(user?.email, 'apple@example.com');
    });
  });
}
