import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/utils/ics_generator.dart';

void main() {
  test('calendarEventToIcs outputs valid lines', () {
    final event = CalendarEvent(
      id: 1,
      title: 'Meeting',
      date: DateTime.utc(2024, 1, 1, 12, 0),
      description: 'Discuss plans',
      location: 'Room 1',
    );
    final ics = calendarEventToIcs(event);
    expect(ics, contains('BEGIN:VEVENT'));
    expect(ics, contains('SUMMARY:Meeting'));
    expect(ics, contains('DESCRIPTION:Discuss plans'));
    expect(ics, contains('LOCATION:Room 1'));
    expect(ics, contains('END:VEVENT'));
  });

  test('slugify sanitizes file names', () {
    expect(slugify('My Event @ Home!'), 'my_event_home');
  });
}
