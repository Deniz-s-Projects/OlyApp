import 'package:flutter/material.dart';

import '../../services/notification_service.dart';
import '../../utils/user_helpers.dart';

class EmergencyAlertPage extends StatefulWidget {
  const EmergencyAlertPage({super.key});

  @override
  State<EmergencyAlertPage> createState() => _EmergencyAlertPageState();
}

class _EmergencyAlertPageState extends State<EmergencyAlertPage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();

  bool _sending = false;
  String? _result;

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      final count = await NotificationService().broadcastNotification(
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
      );
      setState(() => _result = 'Sent to $count device(s)');
    } catch (e) {
      setState(() => _result = 'Error: \$e');
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Alert')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyCtrl,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sending ? null : _send,
              child: const Text('Send Alert'),
            ),
            if (_result != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_result!),
              ),
          ],
        ),
      ),
    );
  }
}
