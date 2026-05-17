import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/study_groups_providers.dart';
import '../services/study_group_service.dart';
import '../utils/user_helpers.dart';

class StudyGroupsPage extends StatelessWidget {
  final StudyGroupService? service;
  const StudyGroupsPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _StudyGroupsBody();
    }
    return ProviderScope(
      overrides: [studyGroupServiceProvider.overrideWithValue(service!)],
      child: const _StudyGroupsBody(),
    );
  }
}

class _StudyGroupsBody extends ConsumerWidget {
  const _StudyGroupsBody();

  Future<void> _toggle(WidgetRef ref, StudyGroup group) async {
    if (group.id == null) return;
    final me = currentUserId();
    final isMember = group.memberIds.contains(me);
    final service = ref.read(studyGroupServiceProvider);
    if (isMember) {
      await service.leaveGroup(group.id!);
    } else {
      await service.joinGroup(group.id!);
    }
    ref.invalidate(studyGroupsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups =
        ref.watch(studyGroupsProvider).valueOrNull ?? const <StudyGroup>[];
    final me = currentUserId();
    return Scaffold(
      appBar: AppBar(title: const Text('Study Groups')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(studyGroupsProvider),
        child: ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final isMember = group.memberIds.contains(me);
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
                onPressed: () => _toggle(ref, group),
                child: Text(isMember ? 'Leave' : 'Join'),
              ),
            );
          },
        ),
      ),
    );
  }
}
