import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/storage_providers.dart';
import '../widgets/empty_state.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = ref.watch(notificationsStorageProvider);
    final notifications = box.values.toList();
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.appBarNotifications)),
      body: notifications.isEmpty
          ? EmptyState(
              icon: Icons.notifications_none,
              title: l.emptyNotifications,
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, i) {
                final n = notifications[i];
                return ListTile(
                  title: Text(n.title ?? ''),
                  subtitle: Text(n.body ?? ''),
                );
              },
            ),
    );
  }
}
