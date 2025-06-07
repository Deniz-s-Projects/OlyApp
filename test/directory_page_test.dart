import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/directory_page.dart';
import 'package:oly_app/services/directory_service.dart';

class FakeDirectoryService extends DirectoryService {
  final List<User> users;
  FakeDirectoryService([this.users = const []]);

  @override
  Future<List<User>> fetchUsers({String? search}) async => users;
}

void main() {
  testWidgets('Displays empty message when no users', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: DirectoryPage(service: FakeDirectoryService())),
    );
    await tester.pumpAndSettle();

    expect(find.text('No residents found.'), findsOneWidget);
  });
}
