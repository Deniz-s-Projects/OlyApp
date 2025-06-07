import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import '../main.dart';
import '../services/user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';
import 'emergency_contacts_page.dart';
import 'suggestion_box_page.dart';

class SettingsPage extends StatefulWidget {
  final UserService? service;
  const SettingsPage({super.key, this.service});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _listed = false;
  bool _eventNotif = true;
  bool _announcementNotif = true;
  late final UserService _service;
  late User _user;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? UserService();
    final settingsBox = Hive.box('settingsBox');
    _darkMode = settingsBox.get('themeMode', defaultValue: 'light') == 'dark';
    _eventNotif =
        settingsBox.get('eventNotifications', defaultValue: true) as bool;
    _announcementNotif =
        settingsBox.get('announcementNotifications', defaultValue: true)
            as bool;
    final userBox = Hive.box<User>('userBox');
    _user = userBox.get('currentUser')!;
    _listed = _user.isListed;
  }

  Future<void> _updateListed(bool val) async {
    setState(() => _listed = val);
    final updated = User(
      id: _user.id,
      name: _user.name,
      email: _user.email,
      avatarUrl: _user.avatarUrl,
      isAdmin: _user.isAdmin,
      isListed: val,
      bio: _user.bio,
      room: _user.room,
    );
    try {
      final user = await _service.updateProfile(updated);
      await Hive.box<User>('userBox').put('currentUser', user);
      if (mounted) setState(() => _user = user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _registerTokenIfNeeded() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await NotificationService().registerToken(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (val) {
              setState(() => _darkMode = val);
              final mode = val ? ThemeMode.dark : ThemeMode.light;
              OlyApp.of(context)?.updateThemeMode(mode);
            },
          ),
          SwitchListTile(
            title: const Text('Appear in Directory'),
            value: _listed,
            onChanged: _updateListed,
          ),
          SwitchListTile(
            title: const Text('Event Reminders'),
            value: _eventNotif,
            onChanged: (val) async {
              setState(() => _eventNotif = val);
              await Hive.box('settingsBox').put('eventNotifications', val);
              if (val) await _registerTokenIfNeeded();
            },
          ),
          SwitchListTile(
            title: const Text('Announcements'),
            value: _announcementNotif,
            onChanged: (val) async {
              setState(() => _announcementNotif = val);
              await Hive.box(
                'settingsBox',
              ).put('announcementNotifications', val);
              if (val) await _registerTokenIfNeeded();
            },
          ),
          ListTile(
            title: const Text('Emergency Contacts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmergencyContactsPage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Suggestion Box'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SuggestionBoxPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
