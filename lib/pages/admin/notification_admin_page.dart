import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../services/notification_service.dart';
import '../../utils/user_helpers.dart';

class NotificationAdminPage extends StatefulWidget {
  const NotificationAdminPage({super.key});

  @override
  State<NotificationAdminPage> createState() => _NotificationAdminPageState();
}

class _NotificationAdminPageState extends State<NotificationAdminPage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();

  bool _sending = false;
  String? _result;
  bool _broadcast = false;

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      int count;
      if (_broadcast) {
        count = await NotificationService().broadcastNotification(
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
        );
      } else {
        final token = await FirebaseMessaging.instance.getToken();
        if (token == null) {
          setState(() => _result = 'No device token available');
          return;
        }
        count = await NotificationService().sendNotification(
          tokens: [token],
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
        );
      }
      setState(() => _result = 'Sent to $count device(s)');
    } catch (e) {
      setState(() => _result = 'Error: $e');
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
      appBar: AppBar(title: const Text('Send Notification')),
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
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Broadcast to all devices'),
              value: _broadcast,
              onChanged: _sending
                  ? null
                  : (val) => setState(() => _broadcast = val),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sending ? null : _send,
              child: const Text('Send'),
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
