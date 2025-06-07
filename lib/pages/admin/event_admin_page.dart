import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/event_service.dart';
import '../calendar_page.dart' show showAddEventDialog;
import '../../utils/user_helpers.dart';

class EventAdminPage extends StatefulWidget {
  final EventService? service;
  const EventAdminPage({super.key, this.service});

  @override
  State<EventAdminPage> createState() => _EventAdminPageState();
}

class _EventAdminPageState extends State<EventAdminPage> {
  late final EventService _service;
  List<CalendarEvent> _events = [];

  @override
  void initState() {
    super.initState();
    if (!currentUserIsAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Admin access required')));
      });
    } else {
      _service = widget.service ?? EventService();
      _load();
    }
  }

  Future<void> _load() async {
    final events = await _service.fetchEvents();
    setState(() => _events = events);
  }

  Future<void> _editEvent(CalendarEvent event) async {
    final titleCtrl = TextEditingController(text: event.title);
    final locCtrl = TextEditingController(text: event.location ?? '');
    final catCtrl = TextEditingController(text: event.category ?? '');
    DateTime selectedDate = event.date;
    String interval = event.repeatInterval ?? 'none';
    DateTime? until = event.repeatUntil;
    final updated = await showDialog<CalendarEvent>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
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
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
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
                  onChanged: (val) => setState(() => interval = val ?? 'none'),
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
                        initialDate: until ?? selectedDate,
                        firstDate: selectedDate,
                        lastDate: DateTime.utc(2035),
                      );
                      if (picked != null) setState(() => until = picked);
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  Navigator.pop(
                    ctx,
                    CalendarEvent(
                      id: event.id,
                      title: titleCtrl.text,
                      date: selectedDate,
                      description: event.description,
                      attendees: event.attendees,
                      location:
                          locCtrl.text.isNotEmpty ? locCtrl.text : null,
                      repeatInterval:
                          interval == 'none' ? null : interval,
                      repeatUntil: until,
                      category: catCtrl.text.isNotEmpty ? catCtrl.text : null,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (updated != null) {
      await _service.updateEvent(updated);
      _load();
    }
  }

  Future<void> _deleteEvent(int id) async {
    await _service.deleteEvent(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Events')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showAddEventDialog(
            context,
            (title, date, location, interval, until, category) async {
            await _service.createEvent(
              CalendarEvent(
                title: title,
                date: date,
                location: location,
                repeatInterval: interval,
                repeatUntil: until, 
                category: category,
              ),
            );
            _load();
          });
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (ctx, i) {
          final e = _events[i];
          return ListTile(
            title: Text(e.title),
            onTap: () => _editEvent(e),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editEvent(e),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteEvent(e.id!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
