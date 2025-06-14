import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/models.dart';
import '../services/event_service.dart';
import '../services/map_service.dart';
import '../utils/ics_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'map_page.dart';
import '../models/map_pin.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';
import '../services/qr_service.dart';
import 'qr_scanner_page.dart';

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
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  bool _loading = false;

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
    setState(() => _loading = true);
    try {
      final events = await _service.fetchEvents();
      if (!mounted) return;
      setState(() {
        _events.clear();
        _categories = ['All'];
        for (final e in events) {
          final key = DateTime(e.date.year, e.date.month, e.date.day);
          _events.putIfAbsent(key, () => []).add(e);
          if (e.category != null && !_categories.contains(e.category)) {
            _categories.add(e.category!);
          }
        }
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = 'All';
        }
        _selectedEvents.value = _getEventsForDay(_selectedDay);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load events')));
    }
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final list = _events[DateTime(day.year, day.month, day.day)] ?? [];
    return list
        .where(
          (e) => _selectedCategory == 'All' || e.category == _selectedCategory,
        )
        .toList();
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
    await showAddEventDialog(
      context,
      (title, date, location, interval, until, category) async {
      final event = await _service.createEvent(
        CalendarEvent(
          title: title,
          date: date,
          location: location.isNotEmpty ? location : null,
          repeatInterval: interval,
          repeatUntil: until, 
          category: category.isNotEmpty ? category : null,
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
      if (event.category != null && !_categories.contains(event.category)) {
        _categories.add(event.category!);
      }
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    });
  }

  Future<void> _rsvp(CalendarEvent event) async {
    if (event.id == null) return;
    try {
      await _service.rsvpEvent(event.id!.toString());
      final attendees = await _service.fetchAttendees(event.id!.toString());
      if (!mounted) return;
      setState(() {
        final updated = CalendarEvent(
          id: event.id,
          title: event.title,
          date: event.date,
          description: event.description,
          attendees: attendees,
          location: event.location,
          category: event.category,
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
      final attendees = await _service.fetchAttendees(event.id!.toString());
      List<EventComment> comments = [];
      try {
        comments = await _service.fetchComments(event.id!);
      } catch (_) {
        // Ignore comment loading errors
      }
      Uint8List? qrImage;
      if (widget.isAdmin) {
        try {
          qrImage = await QrService().fetchQrCode(event.id!);
        } catch (_) {}
      }
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
                  const Text('Attendees'),
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
                  if (qrImage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Image.memory(qrImage, width: 150, height: 150),
                    ),
                  if (!widget.isAdmin)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  QrScannerPage(service: QrService()),
                            ),
                          );
                        },
                        child: const Text('Check in'),
                      ),
                    ),
                  TextField(
                    controller: commentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add comment...',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final ics = calendarEventToIcs(event);
                  final dir = await getTemporaryDirectory();
                  final file = File(
                    '${dir.path}/event_${event.id ?? slugify(event.title)}.ics',
                  );
                  await file.writeAsString(ics);
                  await Share.shareXFiles([
                    XFile(file.path),
                  ], text: event.title);
                },
                child: const Text('Share'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  final text = commentCtrl.text.trim();
                  if (text.isEmpty) return;
                  final comment = await _service.addComment(
                    EventComment(eventId: event.id!, content: text),
                  );
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
          category: event.category,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  _selectedCategory = val;
                  _selectedEvents.value = _getEventsForDay(_selectedDay);
                });
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ValueListenableBuilder<List<CalendarEvent>>(
                    valueListenable: _selectedEvents,
                    builder: (context, events, _) {
                      if (events.isEmpty) {
                        return const Center(
                            child: Text('No events for this day.'));
                      }
                      return ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (ctx, idx) {
                          final event = events[idx];
                          return ListTile(
                            leading: const Icon(Icons.event_note),
                            title: Text(event.title),
                            subtitle:
                                Text('Attendees: ${event.attendees.length}'),
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
  void Function(
    String title,
    DateTime date,
    String location,
    String? repeatInterval,
    DateTime? repeatUntil,
    String category,
  ) onConfirm,
 
) async {
  final textCtrl = TextEditingController();
  final locCtrl = TextEditingController();
  final catCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String interval = 'none';
  DateTime? until;
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
          TextField(
            controller: catCtrl,
            decoration: const InputDecoration(labelText: 'Category'),
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
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: interval,
            items: const [
              DropdownMenuItem(value: 'none', child: Text('No Repeat')),
              DropdownMenuItem(value: 'daily', child: Text('Daily')),
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
            ],
            onChanged: (val) => interval = val ?? 'none',
          ),
          if (interval != 'none')
            TextButton.icon(
              icon: const Icon(Icons.repeat),
              label: Text(
                until == null
                    ? 'Repeat Until'
                    : '${until!.day}/${until!.month}/${until!.year}',
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: selectedDate,
                  firstDate: selectedDate,
                  lastDate: DateTime.utc(2035),
                );
                if (picked != null) until = picked;
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
              onConfirm(
                textCtrl.text,
                selectedDate,
                locCtrl.text, 
                interval == 'none' ? null : interval,
                until, 
                catCtrl.text,
              );
              Navigator.pop(ctx);
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
