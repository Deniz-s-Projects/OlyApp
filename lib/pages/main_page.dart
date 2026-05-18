import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oly_app/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/calendar_providers.dart';
import '../providers/route_request_provider.dart';
import '../services/notification_service.dart';
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
  StreamSubscription<RouteRequest>? _routeSub;

  @override
  void initState() {
    super.initState();
    // Subscribe once per MainPage mount. Tests that don't initialise
    // Firebase will throw on the first `getInitialMessage()` call inside
    // routeRequests; swallow that so the widget can still render.
    _routeSub = NotificationService().routeRequests.listen(
      (req) {
        if (!mounted) return;
        ref.read(routeRequestProvider.notifier).state = req;
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _routeSub?.cancel();
    super.dispose();
  }

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

  String _title(BuildContext context, NavTarget t) {
    final l = AppLocalizations.of(context);
    return switch (t) {
      NavTarget.home => l.navHome,
      NavTarget.map => l.navMap,
      NavTarget.calendar => l.navCalendar,
      NavTarget.bulletin => l.navBulletin,
      NavTarget.profile => l.navProfile,
    };
  }

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
    // React to push-notification taps: when a new RouteRequest arrives,
    // jump to that tab and clear the provider so re-mounts of MainPage
    // don't re-trigger it.
    ref.listen<RouteRequest?>(routeRequestProvider, (_, next) {
      if (next == null) return;
      setState(() => _current = next.target);
      ref.read(routeRequestProvider.notifier).state = null;
    });

    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_title(context, _current)),
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
              PopupMenuItem(value: 'settings', child: Text(l.appBarSettings)),
              if (widget.onLogout != null)
                PopupMenuItem(value: 'logout', child: Text(l.appBarLogout)),
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
              label: _title(context, t),
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
          tooltip: AppLocalizations.of(context).a11yViewNotifications,
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
          tooltip: AppLocalizations.of(context).a11yAddEvent,
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
