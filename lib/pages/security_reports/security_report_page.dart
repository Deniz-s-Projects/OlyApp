import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/security_report_service.dart';
import '../../utils/user_helpers.dart';

class SecurityReportPage extends StatefulWidget {
  final SecurityReportService? service;
  const SecurityReportPage({super.key, this.service});

  @override
  State<SecurityReportPage> createState() => _SecurityReportPageState();
}

class _SecurityReportPageState extends State<SecurityReportPage> {
  late final SecurityReportService _service;
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _locCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SecurityReportService();
  }

  Future<void> _submit() async {
    final desc = _descCtrl.text.trim();
    final loc = _locCtrl.text.trim();
    if (desc.isEmpty || loc.isEmpty) return;
    try {
      await _service.createReport(SecurityReport(
        reporterId: currentUserId(),
        description: desc,
        location: loc,
      ));
      if (!mounted) return;
      _descCtrl.clear();
      _locCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit')),
      );
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Security Issue'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _locCtrl,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: const Text('Submit')),
          ],
        ),
      ),
    );
  }
}
