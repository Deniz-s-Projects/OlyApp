import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/maintenance_service.dart';
import '../../utils/user_helpers.dart';

class MaintenanceAdminPage extends StatefulWidget {
  final MaintenanceService? service;
  const MaintenanceAdminPage({super.key, this.service});

  @override
  State<MaintenanceAdminPage> createState() => _MaintenanceAdminPageState();
}

class _MaintenanceAdminPageState extends State<MaintenanceAdminPage> {
  late final MaintenanceService _service;
  List<MaintenanceRequest> _allRequests = [];
  List<MaintenanceRequest> _requests = [];
  String _statusFilter = 'open';

  @override
  void initState() {
    super.initState();
    if (!currentUserIsAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Admin access required')));
      });
    } else {
      _service = widget.service ?? MaintenanceService();
      _load();
    }
  }

  Future<void> _load() async {
    final reqs = await _service.fetchRequests();
    setState(() {
      _allRequests = reqs;
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_statusFilter == 'all') {
      _requests = List.from(_allRequests);
    } else {
      _requests = _allRequests.where((r) => r.status == _statusFilter).toList();
    }
  }

  Future<void> _close(MaintenanceRequest req) async {
    await _service.updateStatus(req.id!, 'closed');
    _load();
  }

  Future<void> _edit(MaintenanceRequest req) async {
    final subjCtrl = TextEditingController(text: req.subject);
    final descCtrl = TextEditingController(text: req.description);
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit Request'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: subjCtrl,
                    decoration: const InputDecoration(labelText: 'Subject'),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                    minLines: 2,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (result == true) {
      final updated = MaintenanceRequest(
        id: req.id,
        userId: req.userId,
        subject: subjCtrl.text.trim(),
        description: descCtrl.text.trim(),
        createdAt: req.createdAt,
        status: req.status,
        imageUrl: req.imageUrl,
      );
      await _service.updateRequest(updated);
      _load();
    }
  }

  Future<void> _delete(int id) async {
    await _service.deleteRequest(id);
    setState(() {
      _allRequests.removeWhere((r) => r.id == id);
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Tickets')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButton<String>(
              value: _statusFilter,
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  _statusFilter = val;
                  _applyFilter();
                });
              },
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'open', child: Text('Open')),
                DropdownMenuItem(value: 'closed', child: Text('Closed')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (ctx, i) {
                final r = _requests[i];
                return ListTile(
                  title: Text(r.subject),
                  subtitle: Text('Status: ${r.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (r.status != 'closed')
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => _close(r),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _edit(r),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _delete(r.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
