import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/pages/booking_page.dart';
import 'package:oly_app/services/booking_service.dart';

class FakeBookingService extends BookingService {
  final List<DateTime> slots;
  FakeBookingService(this.slots);
  final List<Map<String, dynamic>> bookings = [];

  @override
  Future<List<DateTime>> fetchAvailableTimes() async => slots;

  @override
  Future<void> createBooking(DateTime time, String name) async {
    slots.remove(time);
    bookings.add({'_id': '1', 'time': time, 'name': name});
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMyBookings() async => bookings;

  @override
  Future<void> cancelBooking(String id) async {
    bookings.removeWhere((b) => b['_id'] == id);
  }
}

class ErrorBookingService extends BookingService {
  @override
  Future<List<DateTime>> fetchAvailableTimes() async => throw Exception('fail');

  @override
  Future<List<Map<String, dynamic>>> fetchMyBookings() async => [];
}

void main() {
  testWidgets('Booking a slot removes it from list', (tester) async {
    final now = DateTime.now();
    final slot = DateTime(now.year, now.month, now.day, 10);
    final service = FakeBookingService([slot]);
    await tester.pumpWidget(MaterialApp(home: BookingPage(service: service)));
    await tester.pumpAndSettle();

    expect(find.text('10:00'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Book').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'John');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Book'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'Book'), findsNothing);
    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    expect(find.text('Booking confirmed'), findsOneWidget);
  });

  testWidgets('Shows snackbar on load error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: BookingPage(service: ErrorBookingService())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Failed to load slots'), findsOneWidget);
  });
}
