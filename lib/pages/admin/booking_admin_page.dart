import 'package:flutter/material.dart';
import '../../services/booking_service.dart';

class BookingAdminPage extends StatefulWidget {
  final BookingService? service;
  const BookingAdminPage({super.key, this.service});

  @override
  State<BookingAdminPage> createState() => _BookingAdminPageState();
}

class _BookingAdminPageState extends State<BookingAdminPage> {
  late final BookingService _service;
  List<Map<String, dynamic>> _slots = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? BookingService();
    _load();
  }

  Future<void> _load() async {
    final slots = await _service.fetchSlotsForAdmin();
    setState(() => _slots = slots);
  }

  Future<void> _addSlot() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    await _service.createSlot(dt);
    _load();
  }

  Future<void> _delete(String id) async {
    await _service.deleteSlot(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Booking Slots')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSlot,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _slots.length,
        itemBuilder: (ctx, i) {
          final slot = _slots[i];
          final time = slot['time'] as DateTime;
          final label =
              '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          return ListTile(
            title: Text(label),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _delete(slot['_id'] as String),
            ),
          );
        },
      ),
    );
  }
}
