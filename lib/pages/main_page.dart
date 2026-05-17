import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/calendar_providers.dart';
import 'booking_page.dart';
import 'calendar_page.dart';
import 'dashboard_page.dart';
import 'directory_page.dart';
import 'item_exchange_page.dart';
import 'lost_found_page.dart';
import 'maintenance_page.dart';
import 'map_page.dart';
import 'notifications_page.dart';
import 'polls_page.dart';
import 'post_item_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'transit_page.dart';
import 'wiki_page.dart';

class MainPage extends ConsumerStatefulWidget {
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
