import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/admin/maintenance_admin_page.dart';
import 'package:oly_app/services/maintenance_service.dart';
import 'package:hive/hive.dart';
import 'dart:io';

class FakeMaintenanceService extends MaintenanceService {
  final List<MaintenanceRequest> requests;
  FakeMaintenanceService(this.requests);
  @override
  Future<List<MaintenanceRequest>> fetchRequests() async => requests;
}

void main() {
  late Directory dir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>('userBox');
    await Hive.box<User>('userBox').put(
      'currentUser',
      User(id: '1', name: 'Admin', email: 'a@test.com', isAdmin: true),
    );
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  testWidgets('Dropdown filters tickets by status', (tester) async {
    final service = FakeMaintenanceService([
      MaintenanceRequest(
        id: 1,
        userId: '1',
        subject: 'OpenTicket',
        description: 'd',
        status: 'open',
        createdAt: DateTime.now(),
      ),
      MaintenanceRequest(
        id: 2,
        userId: '2',
        subject: 'ClosedTicket',
        description: 'd',
        status: 'closed',
        createdAt: DateTime.now(),
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: MaintenanceAdminPage(service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('OpenTicket'), findsOneWidget);
    expect(find.text('ClosedTicket'), findsNothing);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Closed').last);
    await tester.pumpAndSettle();

    expect(find.text('OpenTicket'), findsNothing);
    expect(find.text('ClosedTicket'), findsOneWidget);
  });
}
