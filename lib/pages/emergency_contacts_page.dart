import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../providers/emergency_contacts_providers.dart';
import '../services/emergency_contact_service.dart';

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
    ref.listen<AsyncValue<List<EmergencyContact>>>(emergencyContactsProvider,
        (prev, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load contacts')),
        );
      }
    });
    final contacts =
        ref.watch(emergencyContactsProvider).valueOrNull ??
            const <EmergencyContact>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(emergencyContactsProvider),
        child: ListView.builder(
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
    );
  }
}
