import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../utils/user_helpers.dart';

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
    if (!currentUserIsAdmin()) {
      Future.microtask(() {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin access required')),
        );
      });
    } else {
      _service = widget.service ?? BookingService();
      _load();
    }
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
    if (!mounted) return;
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (!mounted) return;
    if (time == null) return;
    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    await _service.createSlot(dt);
    if (!mounted) return;
    _load();
  }

  Future<void> _delete(String id) async {
    await _service.deleteSlot(id);
    _load();
  }

  Future<void> _edit(String id, DateTime current) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: current,
    );
    if (!mounted) return;
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (!mounted) return;
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    await _service.updateSlot(id, dt);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _edit(slot['_id'] as String, time),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _delete(slot['_id'] as String),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
