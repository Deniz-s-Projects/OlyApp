import '../models/models.dart';
import 'api_service.dart';

class EventService extends ApiService {
  EventService({super.client});

  Future<List<CalendarEvent>> fetchEvents() async {
    return get('/events', (json) {
      final list = (json['data'] as List<dynamic>);
      return list
          .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    return post('/events', event.toJson(), (json) {
      return CalendarEvent.fromJson(json['data'] as Map<String, dynamic>);
    });
  }

  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    return post(
      '/events/${event.id}',
      event.toJson(),
      (json) =>
          CalendarEvent.fromJson(json['data'] as Map<String, dynamic>),
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
}
