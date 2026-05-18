import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/booking_providers.dart';
import '../services/booking_service.dart';

class BookingPage extends StatelessWidget {
  /// Optional service override. Mainly used by widget tests; production
  /// callers rely on the top-level [ProviderScope] in main.dart.
  final BookingService? service;
  const BookingPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _BookingBody();
    }
    return ProviderScope(
      overrides: [bookingServiceProvider.overrideWithValue(service!)],
      child: const _BookingBody(),
    );
  }
}

class _BookingBody extends ConsumerStatefulWidget {
  const _BookingBody();

  @override
  ConsumerState<_BookingBody> createState() => _BookingBodyState();
}

class _BookingBodyState extends ConsumerState<_BookingBody> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  Map<DateTime, List<DateTime>> _groupByDay(List<DateTime> slots) {
    final map = <DateTime, List<DateTime>>{};
    for (final s in slots) {
      final key = DateTime(s.year, s.month, s.day);
      map.putIfAbsent(key, () => []).add(s);
    }
    return map;
  }

  Future<void> _book(DateTime slot) async {
    final controller = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Book Slot'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Book'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(bookingServiceProvider).createBooking(slot, controller.text);
      if (!mounted) return;
      ref.invalidate(availableSlotsProvider);
      ref.invalidate(myBookingsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create booking')),
      );
    }
  }

  Future<void> _cancel(String id) async {
    try {
      await ref.read(bookingServiceProvider).cancelBooking(id);
      if (!mounted) return;
      ref.invalidate(myBookingsProvider);
      ref.invalidate(availableSlotsProvider);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel booking')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Two independent async sources (slots + bookings) interleaved with
    // a calendar widget — doesn't map cleanly to AsyncStateView. We
    // surface load errors as inline list rows instead of transient
    // SnackBars, which the user might miss.
    final slotsAsync = ref.watch(availableSlotsProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);
    final allSlots = slotsAsync.valueOrNull ?? const <DateTime>[];
    final bookings = bookingsAsync.valueOrNull ??
        const <Map<String, dynamic>>[];
    final slotsByDay = _groupByDay(allSlots);
    final slots = slotsByDay[DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
        )] ??
        const <DateTime>[];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: cs.primary),
              rightChevronIcon: Icon(Icons.chevron_right, color: cs.primary),
              titleTextStyle: TextStyle(
                color: cs.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: cs.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('My Bookings',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (bookingsAsync.hasError)
                  ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text('Could not load your bookings'),
                    trailing: TextButton(
                      onPressed: () => ref.invalidate(myBookingsProvider),
                      child: const Text('Retry'),
                    ),
                  )
                else if (bookingsAsync.isLoading && bookings.isEmpty)
                  const ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: Text('Loading bookings…'),
                  )
                else if (bookings.isEmpty)
                  const ListTile(title: Text('No bookings yet.'))
                else
                  ...bookings.map((b) {
                    final time = b['time'] as DateTime;
                    final label =
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                    return ListTile(
                      title: Text(label),
                      trailing: TextButton(
                        onPressed: () => _cancel(b['_id'] as String),
                        child: const Text('Cancel'),
                      ),
                    );
                  }),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Available Slots',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (slotsAsync.hasError)
                  ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text('Could not load slots'),
                    trailing: TextButton(
                      onPressed: () => ref.invalidate(availableSlotsProvider),
                      child: const Text('Retry'),
                    ),
                  )
                else if (slotsAsync.isLoading && allSlots.isEmpty)
                  const ListTile(
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: Text('Loading slots…'),
                  )
                else if (slots.isEmpty)
                  const ListTile(title: Text('No slots available.'))
                else
                  ...slots.map((slot) {
                    final label =
                        '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';
                    return ListTile(
                      title: Text(label),
                      trailing: TextButton(
                        onPressed: () => _book(slot),
                        child: const Text('Book'),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
