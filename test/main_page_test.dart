import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/pages/calendar_page.dart';
import 'package:oly_app/pages/main_page.dart';
import 'package:oly_app/pages/maintenance_page.dart';
import 'package:oly_app/pages/item_exchange_page.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/services/event_service.dart';
import 'package:oly_app/services/maintenance_service.dart';
import 'package:oly_app/pages/post_item_page.dart';
import 'package:oly_app/services/item_service.dart';

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

class FakeItemService extends ItemService {
  final List<Item> items;
  FakeItemService([this.items = const []]);
  @override
  Future<List<Item>> fetchItems() async => items;
}

void main() {
  testWidgets('Bottom navigation changes pages and FAB visibility', (
    tester,
  ) async {
    final fakeEventService = FakeEventService();
    final fakeMaintenanceService = FakeMaintenanceService();

    await tester.pumpWidget(
      MaterialApp(
        home: MainPage(
          calendarPage: CalendarPage(service: fakeEventService),
          maintenancePage: MaintenancePage(service: fakeMaintenanceService),
          onLogout: () {},
          notifications: const [],
        ),
      ),
    );

    // Starts on Dashboard
    expect(find.widgetWithText(AppBar, 'Dashboard'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Navigate to Calendar tab
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.calendar_today),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Calendar'), findsOneWidget);
    // No FABs visible for regular user.
    expect(find.byType(FloatingActionButton), findsNothing);

    // Navigate to Maintenance tab
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.build),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Maintenance'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('Admin card visible for admins', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainPage(isAdmin: true, onLogout: null, notifications: []),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('Admin card hidden for regular user', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainPage(onLogout: null, notifications: [])),
    );
    await tester.pumpAndSettle();
    expect(find.text('Admin'), findsNothing);
  });

  testWidgets('FAB on calendar tab opens add event dialog', (tester) async {
    final fakeEventService = FakeEventService();

    await tester.pumpWidget(
      MaterialApp(
        home: MainPage(
          calendarPage: CalendarPage(service: fakeEventService),
          isAdmin: true,
          onLogout: () {},
          notifications: const [],
        ),
      ),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.calendar_today),
      ),
    );
    await tester.pumpAndSettle();

    final fab = find.widgetWithIcon(FloatingActionButton, Icons.event);
    expect(fab, findsOneWidget);

    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.text('Add Event'), findsOneWidget);
  });

  testWidgets('FAB on exchange tab opens PostItemPage', (tester) async {
    final fakeItemService = FakeItemService();
    await tester.pumpWidget(
      MaterialApp(
        home: MainPage(
          itemExchangePage: ItemExchangePage(service: fakeItemService),
          onLogout: null,
          notifications: const [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.swap_horiz),
      ),
    );
    await tester.pumpAndSettle();

    final fab = find.widgetWithIcon(
      FloatingActionButton,
      Icons.add_shopping_cart,
    );
    expect(fab, findsOneWidget);

    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.byType(PostItemPage), findsOneWidget);
  });
}
