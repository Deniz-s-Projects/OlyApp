import '../models/models.dart';

String _formatDate(DateTime date) {
  final utc = date.toUtc();
  final y = utc.year.toString().padLeft(4, '0');
  final m = utc.month.toString().padLeft(2, '0');
  final d = utc.day.toString().padLeft(2, '0');
  final h = utc.hour.toString().padLeft(2, '0');
  final min = utc.minute.toString().padLeft(2, '0');
  final s = utc.second.toString().padLeft(2, '0');
  return '${y}${m}${d}T$h$min${s}Z';
}

/// Returns an ICS formatted string representing [event].
String calendarEventToIcs(CalendarEvent event) {
  final start = event.date;
  final end = start.add(const Duration(hours: 1));
  final buffer =
      StringBuffer()
        ..writeln('BEGIN:VCALENDAR')
        ..writeln('VERSION:2.0')
        ..writeln('PRODID:-//OlyApp//EN')
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:${event.id ?? event.hashCode}@olyapp')
        ..writeln('DTSTAMP:${_formatDate(DateTime.now())}')
        ..writeln('DTSTART:${_formatDate(start)}')
        ..writeln('DTEND:${_formatDate(end)}')
        ..writeln('SUMMARY:${event.title}');
  if (event.description != null) {
    buffer.writeln('DESCRIPTION:${event.description}');
  }
  if (event.location != null) {
    buffer.writeln('LOCATION:${event.location}');
  }
  buffer
    ..writeln('END:VEVENT')
    ..writeln('END:VCALENDAR');
  return buffer.toString();
}
