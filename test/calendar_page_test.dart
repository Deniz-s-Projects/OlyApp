import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/calendar_page.dart';
import 'package:oly_app/services/event_service.dart';

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

void main() {
  testWidgets('Add event displays in list', (tester) async {
    final service = FakeEventService();
    await tester.pumpWidget(MaterialApp(home: CalendarPage(service: service)));
    await tester.pumpAndSettle();

    expect(find.text('No events for this day.'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Meeting');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Meeting'), findsOneWidget);
  });
}
