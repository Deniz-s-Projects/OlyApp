import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/event_service.dart';

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
    _service = widget.service ?? EventService();
    _load();
  }

  Future<void> _load() async {
    final events = await _service.fetchEvents();
    setState(() => _events = events);
  }

  Future<void> _editEvent(CalendarEvent event) async {
    final controller = TextEditingController(text: event.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Event'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final updated = CalendarEvent(
          id: event.id, title: result, date: event.date, description: event.description);
      await _service.updateEvent(updated);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Events')),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (ctx, i) {
          final e = _events[i];
          return ListTile(
            title: Text(e.title),
            onTap: () => _editEvent(e),
          );
        },
      ),
    );
  }
}
