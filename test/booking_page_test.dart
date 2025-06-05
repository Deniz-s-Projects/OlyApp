import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/pages/booking_page.dart';
import 'package:oly_app/services/booking_service.dart';

class FakeBookingService extends BookingService {
  final List<DateTime> slots;
  FakeBookingService(this.slots);

  @override
  Future<List<DateTime>> fetchAvailableTimes() async => slots;

  @override
  Future<void> createBooking(DateTime time, String name) async {
    slots.remove(time);
  }
}

class ErrorBookingService extends BookingService {
  @override
  Future<List<DateTime>> fetchAvailableTimes() async => throw Exception('fail');
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

    expect(find.text('10:00'), findsNothing);
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
