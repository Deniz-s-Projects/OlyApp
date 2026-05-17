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
      expect(validatePassword('Aa1!'), 'Password must be at least 8 characters');
    });

    test('missing letter', () {
      expect(validatePassword('12345678'), 'Password must contain a letter');
    });

    test('missing digit', () {
      expect(validatePassword('abcdefgh'), 'Password must contain a number');
    });

    test('valid password', () {
      expect(validatePassword('Passw0rd'), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('empty confirmation', () {
      expect(validateConfirmPassword('', 'password'), 'Please confirm password');
    });

    test('mismatch confirmation', () {
      expect(
          validateConfirmPassword('abc', 'password'), 'Passwords do not match');
    });

    test('matching confirmation', () {
      expect(validateConfirmPassword('password', 'password'), isNull);
    });
  });
}
