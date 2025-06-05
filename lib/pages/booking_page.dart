import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/booking_service.dart';

class BookingPage extends StatefulWidget {
  final BookingService? service;
  const BookingPage({super.key, this.service});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late final BookingService _service;
  final Map<DateTime, List<DateTime>> _slots = {};
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? BookingService();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    try {
      final slots = await _service.fetchAvailableTimes();
      if (!mounted) return;
      setState(() {
        _slots.clear();
        for (final s in slots) {
          final key = DateTime(s.year, s.month, s.day);
          _slots.putIfAbsent(key, () => []).add(s);
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load slots')),
      );
    }
  }

  List<DateTime> _getSlotsForDay(DateTime day) {
    return _slots[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
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
    if (confirm == true) {
      try {
        await _service.createBooking(slot, controller.text);
        if (!mounted) return;
        setState(() {
          final key = DateTime(slot.year, slot.month, slot.day);
          _slots[key]?.remove(slot);
        });
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
  }

  @override
  Widget build(BuildContext context) {
    final slots = _getSlotsForDay(_selectedDay);
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
            child: slots.isEmpty
                ? const Center(child: Text('No slots available.'))
                : ListView.builder(
                    itemCount: slots.length,
                    itemBuilder: (ctx, i) {
                      final slot = slots[i];
                      final label =
                          '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';
                      return ListTile(
                        title: Text(label),
                        trailing: TextButton(
                          onPressed: () => _book(slot),
                          child: const Text('Book'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
