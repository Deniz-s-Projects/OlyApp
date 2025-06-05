import '../models/models.dart';
import 'api_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EventService extends ApiService {
  EventService({super.client});

  Future<List<CalendarEvent>> fetchEvents() async {
    final box = Hive.isBoxOpen('eventsBox') ? Hive.box('eventsBox') : null;
    try {
      final events = await get('/events', (json) {
        final list = (json['data'] as List<dynamic>);
        return list
            .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      await box?.put('events', events.map((e) => e.toJson()).toList());
      return events;
    } catch (e) {
      final cached =
          box?.get('events', defaultValue: const <dynamic>[]) as List?;
      if (cached == null || cached.isEmpty) {
        rethrow;
      }
      return cached
          .map((e) => CalendarEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    return post('/events', event.toJson(), (json) {
      return CalendarEvent.fromJson(json['data'] as Map<String, dynamic>);
    });
  }

  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    return put(
      '/events/${event.id}',
      event.toJson(),
      (json) => CalendarEvent.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<void> rsvpEvent(int eventId, int userId) async {
    await post('/events/$eventId/rsvp', {'userId': userId}, (_) => null);
  }

  Future<List<int>> fetchAttendees(int eventId) async {
    return get('/events/$eventId/attendees', (json) {
      final list = json['data'] as List<dynamic>;
      return list.map((e) => e as int).toList();
    });
  }

  Future<void> deleteEvent(int id) async {
    await delete('/events/$id', (_) => null);
  }
}
