import 'package:flutter_test/flutter_test.dart';

int add(int a, int b) => a + b;

void main() {
  test('adds two numbers', () {
    expect(add(2, 3), 5);
    expect(add(-1, 1), 0);
    expect(add(0, 0), 0);
  });
}
