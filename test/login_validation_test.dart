import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('empty email', () {
      expect(validateEmail(''), 'Email is required');
    });

    test('invalid email', () {
      expect(validateEmail('invalid'), 'Enter a valid email');
    });

    test('valid email', () {
      expect(validateEmail('test@example.com'), isNull);
    });
  });

  group('validatePassword', () {
    test('empty password', () {
      expect(validatePassword(''), 'Password is required');
    });

    test('too short password', () {
      expect(validatePassword('123'), 'Password must be at least 6 characters');
    });

    test('valid password', () {
      expect(validatePassword('123456'), isNull);
    });
  });
}
