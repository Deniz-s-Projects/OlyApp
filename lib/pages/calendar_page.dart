import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/map_pin.dart';
import '../models/models.dart';
import '../providers/calendar_providers.dart';
import '../services/event_service.dart';
import '../services/map_service.dart';
import '../services/qr_service.dart';
import '../utils/ics_generator.dart';
import '../widgets/async_state_view.dart';
import '../widgets/empty_state.dart';
import 'map_page.dart';
import 'qr_scanner_page.dart';

class CalendarPage extends StatelessWidget {
  final EventService? service;
  final bool isAdmin;
  const CalendarPage({super.key, this.service, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    final body = _CalendarBody(isAdmin: isAdmin);
    if (service == null) return body;
    return ProviderScope(
      overrides: [eventServiceProvider.overrideWithValue(service!)],
      child: body,
    );
  }
}

class _CalendarBody extends ConsumerStatefulWidget {
  final bool isAdmin;
  const _CalendarBody({required this.isAdmin});

  @override
  ConsumerState<_CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends ConsumerState<_CalendarBody> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<CalendarEvent> _eventsForDay(DateTime day) {
    final map = ref.read(eventsByDayProvider);
    return map[DateTime(day.year, day.month, day.day)] ?? const [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() => _calendarFormat = format);
  }

  Future<void> _addEvent() async {
    await showAddEventDialog(
      context,
      (title, date, location, interval, until, category) async {
        await ref.read(eventServiceProvider).createEvent(
              CalendarEvent(
                title: title,
                date: date,
                location: location.isNotEmpty ? location : null,
                repeatInterval: interval,
                repeatUntil: until,
                category: category.isNotEmpty ? category : null,
              ),
            );
        ref.invalidate(eventsProvider);
      },
    );
  }

  Future<void> _rsvp(CalendarEvent event) async {
    if (event.id == null) return;
    try {
      await ref.read(eventServiceProvider).rsvpEvent(event.id!.toString());
      ref.invalidate(eventsProvider);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to RSVP')),
      );
    }
  }

  Future<void> _showEventDetails(CalendarEvent event) async {
    if (event.id == null) return;
    final service = ref.read(eventServiceProvider);
    try {
      final attendees = await service.fetchAttendees(event.id!.toString());
      List<EventComment> comments = [];
      try {
        comments = await service.fetchComments(event.id!);
      } catch (_) {
        // ignore comment loading errors
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
                      child: Text(
                          'Location: ${pin?.title ?? event.location}'),
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
                      child:
                          Image.memory(qrImage, width: 150, height: 150),
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
                  final comment = await service.addComment(
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
      // Refresh attendee counts etc. after the dialog closes.
      if (mounted) ref.invalidate(eventsProvider);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load attendees')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final eventsAsync = ref.watch(eventsProvider);
    final categories = ref.watch(calendarCategoriesProvider);
    final selectedCategory = ref.watch(calendarCategoryProvider);

    return Scaffold(
      body: Column(
        children: [
          TableCalendar<CalendarEvent>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _eventsForDay,
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
              onPressed: () => ref.invalidate(eventsProvider),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: categories.contains(selectedCategory)
                  ? selectedCategory
                  : 'All',
              isExpanded: true,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                ref.read(calendarCategoryProvider.notifier).set(val);
              },
            ),
          ),
          Expanded(
            child: AsyncStateView<List<CalendarEvent>>(
              value: eventsAsync,
              errorTitle: 'Failed to load events',
              onRetry: () => ref.invalidate(eventsProvider),
              isEmpty: (_) => _eventsForDay(_selectedDay).isEmpty,
              empty: const EmptyState(
                icon: Icons.event_busy,
                title: 'No events for this day',
              ),
              data: (_) {
                final selectedEvents = _eventsForDay(_selectedDay);
                return ListView.builder(
                  itemCount: selectedEvents.length,
                  itemBuilder: (ctx, idx) {
                    final event = selectedEvents[idx];
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
