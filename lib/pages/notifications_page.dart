import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<NotificationRecord>('notificationsBox');
    final notifications = box.values.toList().cast<NotificationRecord>();
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, i) {
                final n = notifications[i];
                return ListTile(
                  title: Text(n.title ?? ''),
                  subtitle: Text(n.body ?? ''),
                );
              },
            ),
    );
  }
}
