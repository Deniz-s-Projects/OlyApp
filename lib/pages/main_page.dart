import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'item_exchange_page.dart';
import 'maintenance_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  static const List<String> _titles = [
    'Dashboard',
    'Calendar',
    'Item Exchange',
    'Maintenance',
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(onNavigate: _onDashboardNavigate),
      const CalendarPage(),
      const ItemExchangePage(),
      const MaintenancePage(),
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
      ),
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex != 3
          ? FloatingActionButton(
        onPressed: () {
          // TODO: implement quick actions per tab
        },
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
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Exchange'),
          NavigationDestination(icon: Icon(Icons.build), label: 'Maintenance'),
        ],
      ),
    );
  }

  IconData _fabIcon() {
    switch (_currentIndex) {
      case 0:
        return Icons.notifications;
      case 1:
        return Icons.event;
      case 2:
        return Icons.add_shopping_cart;
      default:
        return Icons.add;
    }
  }

  void _onDashboardNavigate(int index) {
    setState(() => _currentIndex = index);
  }
}

class DashboardPage extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const DashboardPage({super.key, required this.onNavigate});

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
                  icon: Icons.calendar_today,
                  label: 'Calendar',
                  colorScheme: colorScheme,
                  onTap: () => _navigate(1),
                ),
                DashboardCard(
                  icon: Icons.swap_horiz,
                  label: 'Exchange',
                  colorScheme: colorScheme,
                  onTap: () => _navigate(2),
                ),
                DashboardCard(
                  icon: Icons.build,
                  label: 'Maintenance',
                  colorScheme: colorScheme,
                  onTap: () => _navigate(3),
                ),
                // add more cards here
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
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: textColor),
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
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}