import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/pages/calendar_page.dart';
import 'package:oly_app/pages/main_page.dart';
import 'package:oly_app/pages/maintenance_page.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/services/event_service.dart';
import 'package:oly_app/services/maintenance_service.dart';

class FakeEventService extends EventService {
  final List<CalendarEvent> events = [];
  FakeEventService();
  @override
  Future<List<CalendarEvent>> fetchEvents() async => events;
  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    events.add(event);
    return event;
  }
}

class FakeMaintenanceService extends MaintenanceService {
  FakeMaintenanceService();
  @override
  Future<List<MaintenanceRequest>> fetchRequests() async => [];
}

void main() {
  testWidgets('Bottom navigation changes pages and FAB visibility', (tester) async {
    final fakeEventService = FakeEventService();
    final fakeMaintenanceService = FakeMaintenanceService();

    await tester.pumpWidget(MaterialApp(
      home: MainPage(
        calendarPage: CalendarPage(service: fakeEventService),
        maintenancePage: MaintenancePage(service: fakeMaintenanceService),
        onLogout: () {},
      ),
    ));

    // Starts on Dashboard
    expect(find.widgetWithText(AppBar, 'Dashboard'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Navigate to Calendar tab
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.calendar_today)));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Calendar'), findsOneWidget);
    // Calendar page includes its own FAB so at least one is present.
    expect(find.byType(FloatingActionButton), findsWidgets);

    // Navigate to Maintenance tab
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.build)));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Maintenance'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('Admin card visible for admins', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainPage(isAdmin: true, onLogout: null)));
    await tester.pumpAndSettle();

    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('Admin card hidden for regular user', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainPage(onLogout: null)));
    await tester.pumpAndSettle();
    expect(find.text('Admin'), findsNothing);
  });
}
