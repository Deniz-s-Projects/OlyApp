import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/booking_service.dart';

/// Single source of truth for the [BookingService] instance.
/// Overridden in tests via [ProviderScope.overrides].
final bookingServiceProvider =
    Provider<BookingService>((ref) => BookingService());

/// All bookable slots returned by the server. The UI groups them by day.
///
/// `dependencies: [bookingServiceProvider]` lets nested `ProviderScope`
/// overrides of [bookingServiceProvider] flow through correctly.
final availableSlotsProvider = FutureProvider<List<DateTime>>(
  (ref) async {
    final service = ref.watch(bookingServiceProvider);
    return service.fetchAvailableTimes();
  },
  dependencies: [bookingServiceProvider],
);

/// The current user's confirmed bookings.
final myBookingsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final service = ref.watch(bookingServiceProvider);
    return service.fetchMyBookings();
  },
  dependencies: [bookingServiceProvider],
);
