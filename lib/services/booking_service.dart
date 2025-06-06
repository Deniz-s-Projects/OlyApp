import 'api_service.dart';

class BookingService extends ApiService {
  BookingService({super.client});

  Future<List<DateTime>> fetchAvailableTimes() async {
    return get('/bookings/slots', (json) {
      final list = json['data'] as List<dynamic>;
      return list.map((e) => DateTime.parse(e as String)).toList();
    });
  }

  Future<List<Map<String, dynamic>>> fetchSlotsForAdmin() async {
    return get('/bookings/slots/manage', (json) {
      final list = json['data'] as List<dynamic>;
      return list.map<Map<String, dynamic>>((e) {
        final map = Map<String, dynamic>.from(e as Map);
        map['time'] = DateTime.parse(map['time'] as String);
        return map;
      }).toList();
    });
  }

  /// Fetch all booking slots including reserved ones (admin only).
  Future<List<Map<String, dynamic>>> fetchAllBookings() async {
    return get('/bookings', (json) {
      final list = json['data'] as List<dynamic>;
      return list.map<Map<String, dynamic>>((e) {
        final map = Map<String, dynamic>.from(e as Map);
        map['time'] = DateTime.parse(map['time'] as String);
        return map;
      }).toList();
    });
  }

  Future<void> createSlot(DateTime time) async {
    await post('/bookings/slots', {
      'time': time.toIso8601String(),
    }, (_) => null);
  }

  Future<void> deleteSlot(String id) async {
    await delete('/bookings/slots/$id', (_) => null);
  }

  Future<void> updateSlot(String id, DateTime time) async {
    await put('/bookings/slots/$id', {
      'time': time.toIso8601String(),
    }, (_) => null);
  }

  Future<void> createBooking(DateTime time, String name) async {
    await post('/bookings', {
      'time': time.toIso8601String(),
      'name': name,
    }, (_) => null);
  }

  Future<List<Map<String, dynamic>>> fetchMyBookings() async {
    return get('/bookings/my', (json) {
      final list = json['data'] as List<dynamic>;
      return list.map<Map<String, dynamic>>((e) {
        final map = Map<String, dynamic>.from(e as Map);
        map['time'] = DateTime.parse(map['time'] as String);
        return map;
      }).toList();
    });
  }

  Future<void> cancelBooking(String id) async {
    await delete('/bookings/$id', (_) => null);
  }
}
