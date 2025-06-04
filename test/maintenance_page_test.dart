import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/maintenance_page.dart';
import 'package:oly_app/services/maintenance_service.dart';

class FakeMaintenanceService extends MaintenanceService {
  FakeMaintenanceService();
  @override
  Future<List<MaintenanceRequest>> fetchRequests() async => [];
}

class ErrorMaintenanceService extends MaintenanceService {
  @override
  Future<List<MaintenanceRequest>> fetchRequests() async =>
      throw Exception('fail');
}

void main() {
  testWidgets('Switches between request and conversations tabs', (tester) async {
    final service = FakeMaintenanceService();
    await tester.pumpWidget(MaterialApp(home: MaintenancePage(service: service)));
    await tester.pumpAndSettle();

    // Form visible on start
    expect(find.byType(TextField), findsNWidgets(2));

    // Switch to conversations
    await tester.tap(find.text('Conversations'));
    await tester.pumpAndSettle();
    expect(find.text('No conversations yet.'), findsOneWidget);
  });

  testWidgets('Shows snackbar on ticket load error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MaintenancePage(service: ErrorMaintenanceService())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Failed to load tickets'), findsOneWidget);
  });
}
