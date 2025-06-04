import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/maintenance_service.dart';

class MaintenanceAdminPage extends StatefulWidget {
  final MaintenanceService? service;
  const MaintenanceAdminPage({super.key, this.service});

  @override
  State<MaintenanceAdminPage> createState() => _MaintenanceAdminPageState();
}

class _MaintenanceAdminPageState extends State<MaintenanceAdminPage> {
  late final MaintenanceService _service;
  List<MaintenanceRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? MaintenanceService();
    _load();
  }

  Future<void> _load() async {
    final reqs = await _service.fetchRequests();
    setState(() => _requests = reqs);
  }

  Future<void> _close(MaintenanceRequest req) async {
    await _service.updateStatus(req.id!, 'closed');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Tickets')),
      body: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (ctx, i) {
          final r = _requests[i];
          return ListTile(
            title: Text(r.subject),
            subtitle: Text('Status: ${r.status}'),
            trailing: r.status != 'closed'
                ? IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _close(r),
                  )
                : null,
          );
        },
      ),
    );
  }
}
