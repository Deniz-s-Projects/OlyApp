import 'package:flutter/material.dart';

import '../models/models.dart';
import 'admin/admin_home_page.dart';
import 'bulletin_board_page.dart';
import 'clubs_page.dart';
import 'create_channel_page.dart';
import 'documents_page.dart';
import 'gallery_page.dart';
import 'group_chat_page.dart';
import 'job_posts/job_posts_page.dart';
import 'services_page.dart';
import 'study_groups_page.dart';
import 'tutoring_page.dart';
import 'weather_page.dart';

class DashboardPage extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  final bool isAdmin;
  const DashboardPage({
    super.key,
    required this.onNavigate,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: StatusCard(
                    icon: Icons.inbox,
                    label: '0 Replies',
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    iconColor: colorScheme.primary,
                    textColor: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatusCard(
                    icon: Icons.event,
                    label: 'BierStube',
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    iconColor: colorScheme.primary,
                    textColor: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DashboardCard(
                  icon: Icons.map,
                  label: 'Map',
                  colorScheme: colorScheme,
                  onTap: () => onNavigate(1),
                ),
                DashboardCard(
                  icon: Icons.calendar_today,
                  label: 'Calendar',
                  colorScheme: colorScheme,
                  onTap: () => onNavigate(2),
                ),
                DashboardCard(
                  icon: Icons.schedule,
                  label: 'Booking',
                  colorScheme: colorScheme,
                  onTap: () => onNavigate(3),
                ),
                DashboardCard(
                  icon: Icons.swap_horiz,
                  label: 'Exchange',
                  colorScheme: colorScheme,
                  onTap: () => onNavigate(4),
                ),
                DashboardCard(
                  icon: Icons.help,
                  label: 'Lost & Found',
                  colorScheme: colorScheme,
                  onTap: () => onNavigate(5),
                ),
                DashboardCard(
                  icon: Icons.message,
                  label: 'Bulletin',
                  colorScheme: colorScheme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BulletinBoardPage(),
                    ),
                  ),
                ),
                DashboardCard(
                  icon: Icons.build,
                  label: 'Maintenance',
                  colorScheme: colorScheme,
                  onTap: () => onNavigate(6),
                ),
                DashboardCard(
                  icon: Icons.directions_bus,
                  label: 'Transit',
                  colorScheme: colorScheme,
                  onTap: () => onNavigate(7),
                ),
                DashboardCard(
                  icon: Icons.miscellaneous_services,
                  label: 'Services',
                  colorScheme: colorScheme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ServicesPage()),
                  ),
                ),
                DashboardCard(
                  icon: Icons.forum,
                  label: 'Channels',
                  colorScheme: colorScheme,
                  onTap: () async {
                    final channel = await Navigator.push<ChatChannel>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateChannelPage(),
                      ),
                    );
                    if (channel != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupChatPage(channel: channel),
                        ),
                      );
                    }
                  },
                ),
                DashboardCard(
                  icon: Icons.group,
                  label: 'Clubs',
                  colorScheme: colorScheme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClubsPage()),
                  ),
                ),
                DashboardCard(
                  icon: Icons.school,
                  label: 'Study Groups',
                  colorScheme: colorScheme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudyGroupsPage()),
                  ),
                ),
                DashboardCard(
                  icon: Icons.menu_book_outlined,
                  label: 'Tutoring',
                  colorScheme: colorScheme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TutoringPage()),
                  ),
                ),
                DashboardCard(
                  icon: Icons.work,
                  label: 'Jobs',
                  colorScheme: colorScheme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JobPostsPage()),
                  ),
                ),
                DashboardCard(
                  icon: Icons.description,
                  label: 'Documents',
                  colorScheme: colorScheme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DocumentsPage()),
                  ),
                ),
                DashboardCard(
                  icon: Icons.photo,
                  label: 'Gallery',
                  colorScheme: colorScheme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GalleryPage()),
                  ),
                ),
                DashboardCard(
                  icon: Icons.cloud,
                  label: 'Weather',
                  colorScheme: colorScheme,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WeatherPage()),
                  ),
                ),
                DashboardCard(
                  icon: Icons.menu_book,
                  label: 'Wiki',
                  colorScheme: colorScheme,
                  onTap: () => onNavigate(10),
                ),
                if (isAdmin)
                  DashboardCard(
                    icon: Icons.admin_panel_settings,
                    label: 'Admin',
                    colorScheme: colorScheme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminHomePage()),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  const StatusCard({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  const DashboardCard({
    super.key,
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
