import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/security_report_service.dart';
import '../../utils/user_helpers.dart';

class SecurityReportAdminPage extends StatefulWidget {
  final SecurityReportService? service;
  const SecurityReportAdminPage({super.key, this.service});

  @override
  State<SecurityReportAdminPage> createState() => _SecurityReportAdminPageState();
}

class _SecurityReportAdminPageState extends State<SecurityReportAdminPage> {
  late final SecurityReportService _service;
  List<SecurityReport> _reports = [];

  @override
  void initState() {
    super.initState();
    if (!currentUserIsAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin access required')),
        );
      });
    } else {
      _service = widget.service ?? SecurityReportService();
      _load();
    }
  }

  Future<void> _load() async {
    final list = await _service.fetchReports();
    if (!mounted) return;
    setState(() => _reports = list);
  }

  Future<void> _delete(SecurityReport r) async {
    if (r.id == null) return;
    await _service.deleteReport(r.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Security Reports')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _reports.isEmpty
            ? const Center(child: Text('No reports'))
            : ListView.builder(
                itemCount: _reports.length,
                itemBuilder: (_, i) {
                  final r = _reports[i];
                  return ListTile(
                    title: Text(r.location),
                    subtitle: Text('${r.description}\n${r.timestamp}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _delete(r),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
