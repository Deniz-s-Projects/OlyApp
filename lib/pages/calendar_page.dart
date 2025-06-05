import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/models.dart';
import '../services/event_service.dart';
import '../services/map_service.dart';
import 'map_page.dart';
import '../models/map_pin.dart';
import 'package:latlong2/latlong.dart';

class CalendarPage extends StatefulWidget {
  final EventService? service;
  final bool isAdmin;
  const CalendarPage({super.key, this.service, this.isAdmin = false});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final EventService _service;
  final Map<DateTime, List<CalendarEvent>> _events = {};
  late final ValueNotifier<List<CalendarEvent>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? EventService();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _loadEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _service.fetchEvents();
      if (!mounted) return;
      setState(() {
        _events.clear();
        for (final e in events) {
          final key = DateTime(e.date.year, e.date.month, e.date.day);
          _events.putIfAbsent(key, () => []).add(e);
        }
        _selectedEvents.value = _getEventsForDay(_selectedDay);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load events')));
    }
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
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
    await showAddEventDialog(context, (title, date, location) async {
      final event = await _service.createEvent(
        CalendarEvent(
          title: title,
          date: date,
          location: location.isNotEmpty ? location : null,
        ),
      );
      final dayKey = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      if (_events.containsKey(dayKey)) {
        _events[dayKey]!.add(event);
      } else {
        _events[dayKey] = [event];
      }
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    });
  }

  Future<void> _rsvp(CalendarEvent event) async {
    if (event.id == null) return;
    try {
      await _service.rsvpEvent(event.id!, 1);
      final attendees = await _service.fetchAttendees(event.id!);
      if (!mounted) return;
      setState(() {
        final updated = CalendarEvent(
          id: event.id,
          title: event.title,
          date: event.date,
          description: event.description,
          attendees: attendees,
          location: event.location,
        );
        final dayKey = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
        );
        final list = _events[dayKey];
        if (list != null) {
          final index = list.indexWhere((e) => e.id == event.id);
          if (index != -1) list[index] = updated;
        }
        _selectedEvents.value = _getEventsForDay(_selectedDay);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to RSVP')));
    }
  }

  Future<void> _showEventDetails(CalendarEvent event) async {
    if (event.id == null) return;
    try {
      final attendees = await _service.fetchAttendees(event.id!);
      final comments = await _service.fetchComments(event.id!);
      MapPin? pin;
      if (event.location != null) {
        final pins = await MapService().fetchPins();
        for (final p in pins) {
          if (p.id == event.location) {
            pin = p;
            break;
          }
        }
      }
      if (!mounted) return;
      final commentCtrl = TextEditingController();
      await showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text(event.title),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(attendees.isEmpty ? 'None' : attendees.join(', ')),
                  if (event.location != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Location: ${pin?.title ?? event.location}'),
                    ),
                  const SizedBox(height: 8),
                  const Text('Comments:'),
                  for (final c in comments)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(c.content),
                    ),
                  TextField(
                    controller: commentCtrl,
                    decoration:
                        const InputDecoration(hintText: 'Add comment...'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  final text = commentCtrl.text.trim();
                  if (text.isEmpty) return;
                  final comment = await _service
                      .addComment(EventComment(eventId: event.id!, content: text));
                  setState(() {
                    comments.add(comment);
                    commentCtrl.clear();
                  });
                },
                child: const Text('Post'),
              ),
              if (pin != null)
                TextButton(
                  onPressed: () {
                    final p = pin!;
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapPage(
                          center: LatLng(p.lat, p.lon),
                          service: MapService(),
                        ),
                      ),
                    );
                  },
                  child: const Text('View on Map'),
                ),
            ],
          ),
        ),
      );
      setState(() {
        final updated = CalendarEvent(
          id: event.id,
          title: event.title,
          date: event.date,
          description: event.description,
          attendees: attendees,
          location: event.location,
        );
        final dayKey = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
        );
        final list = _events[dayKey];
        if (list != null) {
          final index = list.indexWhere((e) => e.id == event.id);
          if (index != -1) list[index] = updated;
        }
        _selectedEvents.value = _getEventsForDay(_selectedDay);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load attendees')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Column(
        children: [
          TableCalendar<CalendarEvent>(
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
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: cs.secondary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: cs.secondaryContainer,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadEvents,
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<CalendarEvent>>(
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
                      subtitle: Text('Attendees: ${event.attendees.length}'),
                      trailing: TextButton(
                        onPressed: () => _rsvp(event),
                        child: const Text('RSVP'),
                      ),
                      onTap: () => _showEventDetails(event),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              backgroundColor: cs.secondary,
              foregroundColor: cs.onSecondary,
              onPressed: _addEvent,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

Future<void> showAddEventDialog(
  BuildContext context,
  void Function(String title, DateTime date, String location) onConfirm,
) async {
  final textCtrl = TextEditingController();
  final locCtrl = TextEditingController();
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
          TextField(
            controller: locCtrl,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            ),
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (textCtrl.text.isNotEmpty) {
              onConfirm(textCtrl.text, selectedDate, locCtrl.text);
              Navigator.pop(ctx);
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
