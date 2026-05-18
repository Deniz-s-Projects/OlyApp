import 'package:flutter/material.dart';
import 'package:oly_app/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../providers/emergency_contacts_providers.dart';
import '../services/emergency_contact_service.dart';
import '../widgets/async_state_view.dart';
import '../widgets/empty_state.dart';

class EmergencyContactsPage extends StatelessWidget {
  final EmergencyContactService? service;
  const EmergencyContactsPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _EmergencyContactsBody();
    }
    return ProviderScope(
      overrides: [
        emergencyContactServiceProvider.overrideWithValue(service!),
      ],
      child: const _EmergencyContactsBody(),
    );
  }
}

class _EmergencyContactsBody extends ConsumerWidget {
  const _EmergencyContactsBody();

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(emergencyContactsProvider);
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsEmergencyContacts)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(emergencyContactsProvider),
        child: AsyncStateView<List<EmergencyContact>>(
          value: contactsAsync,
          errorTitle: l.errorContacts,
          onRetry: () => ref.invalidate(emergencyContactsProvider),
          isEmpty: (contacts) => contacts.isEmpty,
          empty: EmptyState(
            icon: Icons.contact_phone_outlined,
            title: l.emptyEmergencyContacts,
          ),
          data: (contacts) => ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final c = contacts[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(c.name),
                  subtitle: Text(c.description ?? c.phone),
                  trailing: IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () => _call(c.phone),
                  ),
                  onTap: () => _call(c.phone),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
