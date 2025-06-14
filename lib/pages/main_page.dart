import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'item_exchange_page.dart';
import 'maintenance_page.dart';
import 'booking_page.dart';
import 'admin/admin_home_page.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'post_item_page.dart';
import 'bulletin_board_page.dart';
import 'services_page.dart';
import 'notifications_page.dart';
import 'transit_page.dart';
import 'directory_page.dart';
import 'polls_page.dart';
import 'lost_found_page.dart';
import 'create_channel_page.dart';
import 'group_chat_page.dart';
import 'wiki_page.dart';
import 'clubs_page.dart';
import 'study_groups_page.dart';
import 'tutoring_page.dart';
import 'job_posts/job_posts_page.dart';
import 'documents_page.dart';
import 'gallery_page.dart';
import 'weather_page.dart';
import '../models/models.dart';
import '../services/event_service.dart';

class MainPage extends StatefulWidget {
  final CalendarPage? calendarPage;
  final BookingPage? bookingPage;
  final MaintenancePage? maintenancePage;
  final ItemExchangePage? itemExchangePage;
  final bool isAdmin;
  final VoidCallback? onLogout;
  const MainPage({
    super.key,
    this.calendarPage,
    this.maintenancePage,
    this.bookingPage,
    this.itemExchangePage,
    this.isAdmin = false,
    this.onLogout,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  static const List<String> _titles = [
    'Dashboard',
    'Map',
    'Calendar',
    'Booking',
    'Item Exchange',
    'Lost & Found',
    'Maintenance',
    'Transit',
    'Directory',
    'Polls',
    'Wiki',
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(onNavigate: _onDashboardNavigate, isAdmin: widget.isAdmin),
      const MapPage(),
      widget.calendarPage ?? CalendarPage(isAdmin: widget.isAdmin),
      widget.bookingPage ?? const BookingPage(),
      widget.itemExchangePage ?? const ItemExchangePage(),
      const LostFoundPage(),
      widget.maintenancePage ?? const MaintenancePage(),
      const TransitPage(),
      const DirectoryPage(),
      const PollsPage(),
      const WikiPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'settings') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              } else if (val == 'profile') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              } else if (val == 'logout' && widget.onLogout != null) {
                widget.onLogout!();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              if (widget.onLogout != null)
                const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: _pages[_currentIndex],
      floatingActionButton: _fabCallback() != null
          ? FloatingActionButton(
              onPressed: _fabCallback(),
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              child: Icon(_fabIcon()),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        height: 60,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Booking'),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Exchange',
          ),
          NavigationDestination(icon: Icon(Icons.help), label: 'Lost'),
          NavigationDestination(icon: Icon(Icons.build), label: 'Maintenance'),
          NavigationDestination(
            icon: Icon(Icons.directions_bus),
            label: 'Transit',
          ),
          NavigationDestination(icon: Icon(Icons.people), label: 'Directory'),
          NavigationDestination(icon: Icon(Icons.poll), label: 'Polls'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Wiki'),
        ],
      ),
    );
  }

  IconData _fabIcon() {
    switch (_currentIndex) {
      case 0:
        return Icons.notifications;
      case 1:
        return Icons.place;
      case 2:
        return Icons.event;
      case 3:
        return Icons.book_online;
      case 4:
        return Icons.add_shopping_cart;
      default:
        return Icons.add;
    }
  }

  VoidCallback? _fabCallback() {
    switch (_currentIndex) {
      case 0:
        return () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          );
        };
      case 1:
        return () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No map action')));
        };
      case 2:
        if (!widget.isAdmin) return null;
        return () async {
          await showAddEventDialog(context, (
            title,
            date,
            location,
            interval,
            until,
            category,
          ) async {
            final service = EventService();
            await service.createEvent(
              CalendarEvent(
                title: title,
                date: date,
                location: location,
                repeatInterval: interval,
                repeatUntil: until,
                category: category,
              ),
            );
          });
        };
      case 3:
        return null;
      case 4:
        return () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostItemPage()),
          );
        };
      default:
        return null;
    }
  }

  void _onDashboardNavigate(int index) {
    setState(() => _currentIndex = index);
  }
}

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
                  onTap: () => _navigate(1),
                ),
                DashboardCard(
                  icon: Icons.calendar_today,
                  label: 'Calendar',
                  colorScheme: colorScheme,
                  onTap: () => _navigate(2),
                ),
                DashboardCard(
                  icon: Icons.schedule,
                  label: 'Booking',
                  colorScheme: colorScheme,
                  onTap: () => _navigate(3),
                ),
                DashboardCard(
                  icon: Icons.swap_horiz,
                  label: 'Exchange',
                  colorScheme: colorScheme,
                  onTap: () => _navigate(4),
                ),
                DashboardCard(
                  icon: Icons.help,
                  label: 'Lost & Found',
                  colorScheme: colorScheme,
                  onTap: () => _navigate(5),
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
                  onTap: () => _navigate(6),
                ),
                DashboardCard(
                  icon: Icons.directions_bus,
                  label: 'Transit',
                  colorScheme: colorScheme,
                  onTap: () => _navigate(7),
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
                    if (channel != null) {
                      // ignore: use_build_context_synchronously
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
                  onTap: () => _navigate(10),
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

  void _navigate(int index) {
    onNavigate(index);
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
