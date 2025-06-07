import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/study_group_service.dart';
import '../utils/user_helpers.dart';

class StudyGroupsPage extends StatefulWidget {
  final StudyGroupService? service;
  const StudyGroupsPage({super.key, this.service});

  @override
  State<StudyGroupsPage> createState() => _StudyGroupsPageState();
}

class _StudyGroupsPageState extends State<StudyGroupsPage> {
  late final StudyGroupService _service;
  List<StudyGroup> _groups = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? StudyGroupService();
    _load();
  }

  Future<void> _load() async {
    final groups = await _service.fetchGroups();
    if (mounted) setState(() => _groups = groups);
  }

  Future<void> _toggle(StudyGroup group) async {
    if (group.id == null) return;
    final isMember = group.memberIds.contains(currentUserId());
    final updated = isMember
        ? await _service.leaveGroup(group.id!)
        : await _service.joinGroup(group.id!);
    if (!mounted) return;
    setState(() {
      final idx = _groups.indexWhere((g) => g.id == updated.id);
      if (idx != -1) _groups[idx] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Groups')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: _groups.length,
          itemBuilder: (context, index) {
            final group = _groups[index];
            final isMember = group.memberIds.contains(currentUserId());
            return ListTile(
              title: Text(group.topic),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (group.description != null) Text(group.description!),
                  if (group.meetingTime != null)
                    Text('Next: ${group.meetingTime}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _toggle(group),
                child: Text(isMember ? 'Leave' : 'Join'),
              ),
            );
          },
        ),
      ),
    );
  }
}
