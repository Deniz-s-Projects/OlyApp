import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/calendar_providers.dart';
import 'booking_page.dart';
import 'bulletin_board_page.dart';
import 'calendar_page.dart';
import 'dashboard_page.dart';
import 'item_exchange_page.dart';
import 'maintenance_page.dart';
import 'map_page.dart';
import 'nav_target.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

export 'nav_target.dart';

class MainPage extends ConsumerStatefulWidget {
  /// Test-only injection points: provide pre-built pages whose services have
  /// been overridden. Production callers should rely on [ProviderScope].
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
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  NavTarget _current = NavTarget.home;

  late final Map<NavTarget, Widget> _pages = {
    NavTarget.home: DashboardPage(
      onNavigate: _onDashboardNavigate,
      isAdmin: widget.isAdmin,
      injectedCalendarPage: widget.calendarPage,
      injectedBookingPage: widget.bookingPage,
      injectedMaintenancePage: widget.maintenancePage,
      injectedItemExchangePage: widget.itemExchangePage,
    ),
    NavTarget.map: const MapPage(),
    NavTarget.calendar:
        widget.calendarPage ?? CalendarPage(isAdmin: widget.isAdmin),
    NavTarget.bulletin: const BulletinBoardPage(),
    NavTarget.profile: const ProfilePage(),
  };

  String _title(NavTarget t) => switch (t) {
        NavTarget.home => 'Dashboard',
        NavTarget.map => 'Map',
        NavTarget.calendar => 'Calendar',
        NavTarget.bulletin => 'Bulletin',
        NavTarget.profile => 'Profile',
      };

  IconData _icon(NavTarget t) => switch (t) {
        NavTarget.home => Icons.home_outlined,
        NavTarget.map => Icons.map_outlined,
        NavTarget.calendar => Icons.calendar_today_outlined,
        NavTarget.bulletin => Icons.campaign_outlined,
        NavTarget.profile => Icons.person_outline,
      };

  IconData _selectedIcon(NavTarget t) => switch (t) {
        NavTarget.home => Icons.home,
        NavTarget.map => Icons.map,
        NavTarget.calendar => Icons.calendar_today,
        NavTarget.bulletin => Icons.campaign,
        NavTarget.profile => Icons.person,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title(_current)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'settings') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              } else if (val == 'logout' && widget.onLogout != null) {
                widget.onLogout!();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              if (widget.onLogout != null)
                const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: _pages[_current],
      floatingActionButton: _buildFab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: NavTarget.values.indexOf(_current),
        onDestinationSelected: (index) =>
            setState(() => _current = NavTarget.values[index]),
        destinations: [
          for (final t in NavTarget.values)
            NavigationDestination(
              icon: Icon(_icon(t)),
              selectedIcon: Icon(_selectedIcon(t)),
              label: _title(t),
            ),
        ],
      ),
    );
  }

  Widget? _buildFab() {
    switch (_current) {
      case NavTarget.home:
        return FloatingActionButton(
          heroTag: 'homeFab',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          ),
          child: const Icon(Icons.notifications),
        );
      case NavTarget.calendar:
        if (!widget.isAdmin) return null;
        return FloatingActionButton(
          heroTag: 'calendarFab',
          onPressed: () async {
            await showAddEventDialog(context, (
              title,
              date,
              location,
              interval,
              until,
              category,
            ) async {
              final service = ref.read(eventServiceProvider);
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
          },
          child: const Icon(Icons.event),
        );
      case NavTarget.map:
      case NavTarget.bulletin:
      case NavTarget.profile:
        return null;
    }
  }

  void _onDashboardNavigate(NavTarget target) {
    setState(() => _current = target);
  }
}
