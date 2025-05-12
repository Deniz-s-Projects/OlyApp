import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Map<DateTime, List<Event>> _events = {};
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    // TODO: load existing events into _events map
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  void _addEvent() async {
    await _showAddEventDialog(context, (title, date) {
      final dayKey = DateTime(date.year, date.month, date.day);
      if (_events.containsKey(dayKey)) {
        _events[dayKey]!.add(Event(title));
      } else {
        _events[dayKey] = [Event(title)];
      }
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(

      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: _onDaySelected,
            onFormatChanged: _onFormatChanged,
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
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
                  color: cs.primaryContainer, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(
                  color: cs.secondary, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(
                  color: cs.secondaryContainer, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                if (events.isEmpty) {
                  return const Center(child: Text('No events for this day.'));
                }
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (ctx, idx) {
                    final event = events[idx];
                    return ListTile(
                      leading: const Icon(Icons.event_note),
                      title: Text(event.title),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.secondary,
        foregroundColor: cs.onSecondary,
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Event {
  final String title;
  Event(this.title);
  @override
  String toString() => title;
}

Future<void> _showAddEventDialog(
    BuildContext context,
    void Function(String title, DateTime date) onConfirm,
    ) async {
  final textCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add Event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: textCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
            onPressed: () async {
              final picked = await showDatePicker(
                context: ctx,
                initialDate: selectedDate,
                firstDate: DateTime.utc(2020),
                lastDate: DateTime.utc(2030),
              );
              if (picked != null) selectedDate = picked;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (textCtrl.text.isNotEmpty) {
              onConfirm(textCtrl.text, selectedDate);
              Navigator.pop(ctx);
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
