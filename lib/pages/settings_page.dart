import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import '../main.dart';
import '../services/user_service.dart';
import 'emergency_contacts_page.dart';

class SettingsPage extends StatefulWidget {
  final UserService? service;
  const SettingsPage({super.key, this.service});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _listed = false;
  late final UserService _service;
  late User _user;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? UserService();
    final settingsBox = Hive.box('settingsBox');
    _darkMode = settingsBox.get('themeMode', defaultValue: 'light') == 'dark';
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
        ],
      ),
    );
  }
}
