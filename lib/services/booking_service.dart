import 'api_service.dart';

class BookingService extends ApiService {
  BookingService({super.client});

  Future<List<DateTime>> fetchAvailableTimes() async {
    return get('/bookings/slots', (json) {
      final list = json['data'] as List<dynamic>;
      return list.map((e) => DateTime.parse(e as String)).toList();
    });
  }

  Future<void> createBooking(DateTime time, String name) async {
    await post('/bookings', {
      'time': time.toIso8601String(),
      'name': name,
    }, (_) => null);
  }
}
