import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:oly_app/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../models/models.dart';
import '../providers/locale_provider.dart';
import '../providers/storage_providers.dart';
import '../providers/user_providers.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import 'emergency_contacts_page.dart';
import 'suggestion_box_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  final UserService? service;
  const SettingsPage({super.key, this.service});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _listed = false;
  bool _eventNotif = true;
  bool _announcementNotif = true;
  late User _user;

  UserService _resolveService() {
    final UserService service =
        widget.service ?? ref.read(userServiceProvider);
    return service;
  }

  @override
  void initState() {
    super.initState();
    final settingsBox = ref.read(settingsStorageProvider);
    final stored =
        settingsBox.get('themeMode', defaultValue: 'system') as String;
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.system,
    );
    _eventNotif =
        settingsBox.get('eventNotifications', defaultValue: true) as bool;
    _announcementNotif =
        settingsBox.get('announcementNotifications', defaultValue: true)
            as bool;
    _user = ref.read(userStorageProvider).get('currentUser')!;
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
      final user = await _resolveService().updateProfile(updated);
      await ref.read(userStorageProvider).put('currentUser', user);
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
    final l = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.appBarSettings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l.settingsTheme),
            trailing: DropdownButton<ThemeMode>(
              value: _themeMode,
              onChanged: (mode) {
                if (mode == null) return;
                setState(() => _themeMode = mode);
                OlyApp.of(context)?.updateThemeMode(mode);
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l.settingsThemeSystem),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l.settingsThemeLight),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l.settingsThemeDark),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(l.settingsLanguage),
            trailing: DropdownButton<String>(
              value: currentLocale?.languageCode ?? 'system',
              onChanged: (val) {
                if (val == null) return;
                final next = val == 'system' ? null : Locale(val);
                ref.read(localeProvider.notifier).set(next);
              },
              items: [
                DropdownMenuItem(
                  value: 'system',
                  child: Text(l.settingsLanguageSystem),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text(l.settingsLanguageEnglish),
                ),
                DropdownMenuItem(
                  value: 'de',
                  child: Text(l.settingsLanguageGerman),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(l.settingsAppearInDirectory),
            value: _listed,
            onChanged: _updateListed,
          ),
          SwitchListTile(
            title: Text(l.settingsEventReminders),
            value: _eventNotif,
            onChanged: (val) async {
              setState(() => _eventNotif = val);
              await ref
                  .read(settingsStorageProvider)
                  .put('eventNotifications', val);
              if (val) await _registerTokenIfNeeded();
            },
          ),
          SwitchListTile(
            title: Text(l.settingsAnnouncements),
            value: _announcementNotif,
            onChanged: (val) async {
              setState(() => _announcementNotif = val);
              await ref
                  .read(settingsStorageProvider)
                  .put('announcementNotifications', val);
              if (val) await _registerTokenIfNeeded();
            },
          ),
          ListTile(
            title: Text(l.settingsEmergencyContacts),
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
            title: Text(l.settingsSuggestionBox),
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
