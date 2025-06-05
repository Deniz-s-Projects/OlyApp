import 'package:flutter/material.dart';
import 'event_admin_page.dart';
import 'maintenance_admin_page.dart';
import 'notification_admin_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EventAdminPage()));
              },
              child: const Text('Manage Events'),
            ),
            const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MaintenanceAdminPage()));
                },
                child: const Text('Maintenance Tickets'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationAdminPage(),
                    ),
                  );
                },
                child: const Text('Send Notification'),
              )
          ],
        ),
      ),
    );
  }
}
