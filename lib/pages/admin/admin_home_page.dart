import 'package:flutter/material.dart';
import 'event_admin_page.dart';
import 'maintenance_admin_page.dart';
import 'notification_admin_page.dart';
import 'emergency_alert_page.dart';
import 'bulletin_admin_page.dart';
import 'booking_admin_page.dart';
import 'map_admin_page.dart';
import 'poll_admin_page.dart';
import 'poll_list_admin_page.dart';
import 'analytics_page.dart';
import 'monthly_stats_page.dart';
import 'gallery_admin_page.dart';
import 'user_admin_page.dart';
import '../../utils/user_helpers.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Admin access required')));
      });
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Tools')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EventAdminPage()),
                );
              },
              child: const Text('Manage Events'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BulletinAdminPage()),
                );
              },
              child: const Text('Bulletin Posts'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MaintenanceAdminPage(),
                  ),
                );
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
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmergencyAlertPage()),
                );
              },
              child: const Text('Emergency Alert'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingAdminPage()),
                );
              },
              child: const Text('Booking Slots'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapAdminPage()),
                );
              },
              child: const Text('Map Pins'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PollAdminPage()),
                );
              },
              child: const Text('Create Poll'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PollListAdminPage()),
                );
              },
              child: const Text('Manage Polls'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GalleryAdminPage()),
                );
              },
              child: const Text('Upload Gallery Image'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserAdminPage()),
                );
              },
              child: const Text('Manage Users'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsPage()),
                );
              },
              child: const Text('Analytics'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MonthlyStatsPage()),
                );
              },
              child: const Text('Monthly Charts'),
            ),
          ],
        ),
      ),
    );
  }
}
