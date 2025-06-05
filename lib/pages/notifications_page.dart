import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final List<Map<String, String?>> notifications;
  const NotificationsPage({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, i) {
                final n = notifications[i];
                return ListTile(
                  title: Text(n['title'] ?? ''),
                  subtitle: Text(n['body'] ?? ''),
                );
              },
            ),
    );
  }
}
