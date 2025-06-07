import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../services/emergency_contact_service.dart';

class EmergencyContactsPage extends StatefulWidget {
  final EmergencyContactService? service;
  const EmergencyContactsPage({super.key, this.service});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  late final EmergencyContactService _service;
  List<EmergencyContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? EmergencyContactService();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _service.fetchContacts();
      if (mounted) setState(() => _contacts = list);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load contacts')));
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            final c = _contacts[index];
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
