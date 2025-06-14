import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/calendar_page.dart';
import 'package:oly_app/pages/map_page.dart';
import 'package:oly_app/services/event_service.dart';
import 'package:oly_app/services/map_service.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FakeEventService extends EventService {
  final List<CalendarEvent> events = [];
  FakeEventService();
  @override
  Future<List<CalendarEvent>> fetchEvents() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return events;
  }
  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    final newEvent = event.id != null
        ? event
        : CalendarEvent(
            id: events.length + 1,
            title: event.title,
            date: event.date,
            description: event.description,
            attendees: event.attendees,
            location: event.location,
            category: event.category,
          );
    events.add(newEvent);
    return newEvent;
  }

  @override
  Future<void> rsvpEvent(String eventId) async {
    final index = events.indexWhere((e) => e.id.toString() == eventId);
    if (index != -1) {
      final e = events[index];
      events[index] = CalendarEvent(
        id: e.id,
        title: e.title,
        date: e.date,
        description: e.description,
        attendees: [...e.attendees, 'u1'],
        location: e.location,
        category: e.category,
      );
    }
  }

  @override
  Future<List<String>> fetchAttendees(String eventId) async {
    final e = events.firstWhere((ev) => ev.id.toString() == eventId);
    return e.attendees;
  }
}

class ErrorEventService extends EventService {
  @override
  Future<List<CalendarEvent>> fetchEvents() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    throw Exception('fail');
  }
}

void main() {
  testWidgets('Add event displays in list', (tester) async {
    final service = FakeEventService();
    await tester.pumpWidget(
      MaterialApp(home: CalendarPage(service: service, isAdmin: true)),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('No events for this day.'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Meeting');
    await tester.enterText(find.byType(TextField).at(1), 'building1');
    await tester.enterText(find.byType(TextField).at(2), 'social');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Meeting'), findsOneWidget);
  });

  testWidgets('Shows snackbar on load error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CalendarPage(service: ErrorEventService())),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Failed to load events'), findsOneWidget);
  });

  testWidgets('RSVP button updates attendee count', (tester) async {
    final service = FakeEventService();
    service.events.add(
      CalendarEvent(id: 1, title: 'Party', date: DateTime.now()),
    );
    await tester.pumpWidget(MaterialApp(home: CalendarPage(service: service)));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Attendees: 0'), findsOneWidget);

    await tester.tap(find.text('RSVP'));
    await tester.pumpAndSettle();

    expect(find.text('Attendees: 1'), findsOneWidget);
  });

  testWidgets('Tapping event shows attendees dialog', (tester) async {
    final service = FakeEventService();
    service.events.add(
      CalendarEvent(
        id: 1,
        title: 'Party',
        date: DateTime.now(),
        attendees: const ['1'],
        location: 'building1',
      ),
    );
    MapService.defaultClient = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/pins');
      return http.Response(
        jsonEncode({
          'data': [
            {
              'id': 'building1',
              'title': 'Dorm',
              'lat': 0,
              'lon': 0,
              'category': 'building',
            },
          ],
        }),
        200,
      );
    });

    await tester.pumpWidget(MaterialApp(home: CalendarPage(service: service)));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(find.text('Attendees'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.textContaining('Location:'), findsOneWidget);

    await tester.tap(find.text('View on Map'));
    await tester.pumpAndSettle();
    expect(find.byType(MapPage), findsOneWidget);

    MapService.defaultClient = http.Client();
  });
}
